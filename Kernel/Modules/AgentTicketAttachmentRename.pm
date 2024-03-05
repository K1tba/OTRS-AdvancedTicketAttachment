# --
# Copyright (C) 2012-2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketAttachmentRename;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed object
    my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $MainObject    = $Kernel::OM->Get('Kernel::System::Main');

    my %GetParam;

    # get params
    for my $Key (qw(TicketID ArticleID FileID NewFilename)) {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key ) || '';
    }

    # check needed stuff
    if ( !$GetParam{TicketID} || !$GetParam{ArticleID} ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No TicketID or ArticleID is given!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # check needed stuff
    if ( !$ConfigObject->Get( 'Attachment::Rename' ) ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Attachment rename is not allowed!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # check if the user belongs to a group
    # that is allowed to rename attachments
    my $AccessOK = $TicketObject->TicketPermission(
        Type     => 'rw',
        TicketID => $GetParam{TicketID},
        UserID   => $Self->{UserID}
    );

    my $BackendObject = $ArticleObject->BackendForArticle(
        TicketID  => $GetParam{TicketID},
        ArticleID => $GetParam{ArticleID},
    );

    my %Article = $BackendObject->ArticleGet(
        TicketID  => $GetParam{TicketID},
        ArticleID => $GetParam{ArticleID},
    );

    if ( !%Article ) {
        return $LayoutObject->ErrorScreen(
            Message => 'Article not found!',
            Comment => 'Please contact the admin.',
        );
    }

    # error screen, don't show ticket
    if ( !$AccessOK ) {
        my $Output = $LayoutObject->Header(
            Type  => 'Small',
            Value => $Article{TicketNumber},
        );

        $Output .= $LayoutObject->Warning(
            Message => 'Sorry, you need "rw permissions" to do this action!',
            Comment => 'Please change the owner first.',
        );

        $Output .= $LayoutObject->Footer(
            Type => 'Small',
        );

        return $Output;
    }

    my $StorageModule = $Kernel::OM->Get( $BackendObject->{ArticleStorageModule} );

    if ( $Self->{Subaction} eq 'Rename' ) {
        my $CheckFilename = $MainObject->FilenameCleanUp(
            Filename => $GetParam{NewFilename},
            Type     => 'Local',
        );

        my $Success;
        if ( $CheckFilename eq $GetParam{NewFilename} ) {
            $Success = $StorageModule->AttachmentRename(
                TicketID    => $GetParam{TicketID},
                ArticleID   => $GetParam{ArticleID},
                FileID      => $GetParam{FileID},
                NewFilename => $GetParam{NewFilename},
                UserID      => $Self->{UserID},
            );
        }

        if ( !$Success ) {
            $GetParam{NewFilenameInvalid} = 'ServerError';
        }
        else {

            # return output
            return $LayoutObject->PopupClose(
                URL => "Action=AgentTicketZoom;TicketID=$GetParam{TicketID};ArticleID=$GetParam{ArticleID}",
            );
        }
    }

    my $Output = $LayoutObject->Header(
        Type  => 'Small',
        Value => $Article{TicketNumber},
    );

    my %Data = $StorageModule->AttachmentInfoGet( %GetParam );

    $Output .= $LayoutObject->Output(
         TemplateFile => 'AgentTicketAttachmentRename',
         Data         => {
             %GetParam,
             AttachmentID => $Data{FileID},
             Filename     => $Data{Filename},
         }, 
    );

    $Output .= $LayoutObject->Footer(
        Type => 'Small',
    );

    return $Output;
}

1;
