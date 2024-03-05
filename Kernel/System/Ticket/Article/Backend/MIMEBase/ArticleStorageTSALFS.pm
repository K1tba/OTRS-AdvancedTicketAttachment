# --
# Copyright (C) 2012-2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageTSALFS;

use strict;
use warnings;

use File::Find;
use File::Basename;

use parent qw(Kernel::System::Ticket::Article::Backend::MIMEBase::ArticleStorageFS);

our @ObjectDependencies = qw(
    Kernel::System::DB
    Kernel::System::Log
    Kernel::System::Main
    Kernel::System::Ticket
);

sub AttachmentExists {
    my ( $Self, %Param ) = @_;
    
    # check needed stuff
    for my $Item (qw(ArticleID Filename)) {
        if ( !$Param{$Item} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Item!",
            );
            return;
        }
    }

    # get content path
    my $ContentPath = $Self->_ArticleContentPathGet(
        ArticleID => $Param{ArticleID}
    );
    my $File = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}/$Param{Filename}";

    if ( -f $File ) {
        return 1;
    }

    return;
}

sub AttachmentRename {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Item (qw(TicketID ArticleID FileID NewFilename UserID)) {
        if ( !$Param{$Item} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Item!",
            );
            return;
        }
    }

    # get attachment info 
    my %Data = $Self->AttachmentInfoGet( %Param );

    return if !%Data;
    return if !$Data{FileID} && !$Data{Filename};

    # check that the file exists
    my $Exists = $Self->AttachmentExists(
        ArticleID => $Param{ArticleID},
        Filename  => $Param{NewFilename},
    );

    if ( $Exists && !$Param{Force} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Attachment already exists!",
        );
        return;
    }

    # get main object
    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    # perform FilenameCleanUp here already to check for
    #   conflicting existing attachment files correctly
    $Param{NewFilename} = $MainObject->FilenameCleanUp(
        Filename => $Param{NewFilename},
        Type     => 'Local',
    );

    # get content path
    my $ContentPath = $Self->_ArticleContentPathGet(
        ArticleID => $Param{ArticleID}
    );

    # path building
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}";

    if ( -e $Path ) {

        my @List = $MainObject->DirectoryRead(
            Directory => $Path,
            Filter    => "*",
        );

        FILENAME:
        for my $Filename ( sort @List ) {
            next FILENAME if $Filename !~ m{\/\Q$Data{Filename}\E(?:\.content_(?:type|alternative|id)|\.disposition)?\z}xms;

            ( my $NewPath = $Filename ) =~ s{
                \Q$Data{Filename}\E
                (
                    \.content_(?:type|alternative|id)|
                    \.disposition
                )?
                \z
            }{$Param{NewFilename}$1}xms;

            if ( !rename $Filename, $NewPath ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Can't rename: $Filename to $Param{NewFilename}: $!!",
                );
            }
        }
    }

    # delete special article storage cache.
    if ( $Self->{ArticleStorageCache} ) {
        $Kernel::OM->Get('Kernel::System::Cache')->Delete(
            Type           => 'ArticleStorageFS_' . $Param{ArticleID},
            Key            => 'ArticleAttachmentIndexRaw',
            CacheInMemory  => 0,
            CacheInBackend => 1,
        );
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # add history entry
    $TicketObject->HistoryAdd(
        TicketID     => $Param{TicketID},
        ArticleID    => $Param{ArticleID},
        HistoryType  => 'AttachmentRename',
        Name         => "\%\%$Data{Filename}\%\%$Param{NewFilename}",
        CreateUserID => $Param{UserID},
    );

    # trigger event
    $TicketObject->EventHandler(
        Event => 'AttachmentRename',
        Data  => {
            TicketID  => $Param{TicketID},
            ArticleID => $Param{ArticleID},
            FileID    => $Data{FileID},
            Filename  => $Data{Filename},
        },
        UserID => $Param{UserID},
    );

    # rename attachment in filesystem
    # return if only delete in my backend
    return 1 if $Param{OnlyMyBackend};

    # get db object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # rename attachment in database
    return if !$DBObject->Do(
        SQL  => 'UPDATE article_data_mime_attachment SET filename = ? '
             . ' WHERE article_id = ? AND id = ?',
        Bind => [ \$Param{NewFilename}, \$Param{ArticleID}, \$Data{FileID} ],
    );

    return 1;
}

sub ArticleDeleteSingleAttachment {
    my ( $Self, %Param ) = @_;
    
    # check needed stuff
    for my $Item (qw(TicketID ArticleID UserID)) {
        if ( !$Param{$Item} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Item!",
            );
            return;
        }
    }

    # check needed stuff
    if ( !$Param{FileID} && !$Param{Filename} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need FileID or Filename!",
        );
        return;
    }

    # get attachment info 
    my %Data = $Self->AttachmentInfoGet( %Param );

    return if !%Data;
    return if !$Data{FileID} && !$Data{Filename};

    # get content path
    my $ContentPath = $Self->_ArticleContentPathGet(
        ArticleID => $Param{ArticleID}
    );

    # path building
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}";

    if ( -e $Path ) {

        # get main object
        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

        my @List = $MainObject->DirectoryRead(
            Directory => $Path,
            Filter    => "*",
            Silent    => 1,
        );

        FILENAME:
        for my $Filename ( sort @List ) {
            next FILENAME if $Filename !~ m{\/\Q$Data{Filename}\E (?:\.content_(?:type|alternative|id)|\.disposition)?\z}xms;
            next FILENAME if $Filename =~ m{\/plain\.txt$}xms;
            next FILENAME if $Filename =~ m{\/file-[12]$}xms;

            if ( !unlink "$Filename" ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Can't remove: $Filename: $!!",
                );
            }
        }
    }

    # delete special article storage cache.
    if ( $Self->{ArticleStorageCache} ) {
        $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
            Type => 'ArticleStorageFS_' . $Param{ArticleID},
        );
    }

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # add history entry
    $TicketObject->HistoryAdd(
        TicketID     => $Param{TicketID},
        ArticleID    => $Param{ArticleID},
        HistoryType  => 'AttachmentDelete',
        Name         => "\%\%$Data{Filename}",
        CreateUserID => $Param{UserID},
    );

    # trigger event
    $TicketObject->EventHandler(
        Event => 'SingleTicketAttachmentDelete',
        Data  => {
            TicketID  => $Param{TicketID},
            ArticleID => $Param{ArticleID},
            FileID    => $Data{FileID},
            Filename  => $Data{Filename},
        },
        UserID => $Param{UserID},
    );

    # return if only delete in my backend
    return 1 if $Param{OnlyMyBackend};

    # get db object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # delete attachments from db
    return if !$DBObject->Do(
        SQL  => 'DELETE FROM article_data_mime_attachment '
             . ' WHERE article_id = ? AND id = ?',
        Bind => [ \$Param{ArticleID}, \$Data{FileID} ],
    );

    return 1;
}

sub AttachmentInfoGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Item (qw(ArticleID)) {
        if ( !$Param{$Item} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Item!",
            );
            return;
        }
    }

    # get content path
    my $ContentPath = $Self->_ArticleContentPathGet(
        ArticleID => $Param{ArticleID}
    );

    # path building
    my $Path = "$Self->{ArticleDataDir}/$ContentPath/$Param{ArticleID}";

    my $FilenameToCheck = basename( $Param{Filename} // '' );

    my %Data;
    my $FileID = 0;

    if ( -e $Path ) {

        # get main object
        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

        my @List = $MainObject->DirectoryRead(
            Directory => $Path,
            Filter    => "*",
            Silent    => 1,
        );

        FILENAME:
        for my $Filename ( sort @List ) {
            my $FileSizeRaw = -s $Filename;

            # do not use control file
            next FILENAME if $Filename =~ m{(?:\.content_(?:alternative|type|id)|\.disposition)$}xms;
            next FILENAME if $Filename =~ m{\/plain\.txt$};

            if ( -e "$Filename.content_type" ) {

                if ( $Filename =~ m{\/file-2$}xms ) {
                    $FileID++;
                }

                next FILENAME if $Filename =~ m{\/file-[12]$}xms;

                # read content type
                my $ContentType = '';
                my $ContentID   = '';
                my $Disposition = '';
                my $Content = $MainObject->FileRead(
                    Location => "$Filename.content_type",
                );
                next FILENAME if !$Content;
                $ContentType = ${$Content};

                # read content id
                if ( -e "$Filename.content_id" ) {
                    my $Content = $MainObject->FileRead(
                        Location => "$Filename.content_id",
                    );
                    if ($Content) {
                        $ContentID = ${$Content};
                    }
                }

                # read disposition
                if ( -e "$Filename.disposition" ) {
                    my $Content = $MainObject->FileRead(
                        Location => "$Filename.disposition",
                    );
                    if ($Content) {
                        $Disposition = ${$Content};
                    }
                }

                next FILENAME if $Disposition && lc $Disposition eq 'inline';
                next FILENAME if $ContentID && $ContentType =~ m{image}ixms;

                # strip filename
                $Filename =~ s{^.*/}{};

                # add the info the the hash
                $FileID++;
                $Data{FileID}      = $FileID;
                $Data{Filename}    = $Filename;
                $Data{FilesizeRaw} = $FileSizeRaw;

                if ( $Param{FileID} && $Param{FileID} == $FileID ) {
                    last FILENAME;
                }
                elsif ( $FilenameToCheck && $FilenameToCheck eq basename($Filename) ) {
                    last FILENAME;
                }
            }
        }
    }

    return if !%Data;
    return if !$Data{FileID} && !$Data{Filename};

    return %Data;
}

1;
