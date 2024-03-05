# --
# Copyright (C) 2012-2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::TicketZoom::AttachmentList;

use parent 'Kernel::Output::HTML::Base';

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed object
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my %Ticket = %{ $Param{Ticket} };

    # strip html and ascii attachments of content
    my %StripParams;
    if ( $LayoutObject->{BrowserRichText} ) {
        $StripParams{ExcludePlainText} = 1;
        $StripParams{ExcludeHTMLBody}  = 1;
        $StripParams{ExcludeInline}    = 1;
        $StripParams{OnlyHTMLBody}     = 0;
    }

    for my $Key (qw(Rename Delete)) {
        $Param{$Key} = $ConfigObject->Get( 'Attachment::' . $Key );
    }

    # check if additional functions are available to the user for this ticket
    my $AccessOk;
    if ( $Param{Delete} || $Param{Rename} ) {
        $AccessOk = $Kernel::OM->Get('Kernel::System::Ticket')->TicketPermission(
            Type     => 'rw',
            TicketID => $Ticket{TicketID},
            UserID   => $Self->{UserID},
            LogNo    => 1,
        );
    }

    # get all articles
    my @ArticleIndex = $ArticleObject->ArticleList(
        TicketID => $Ticket{TicketID},
    );

    my $Counter = 0;

    ARTICLE:
    for my $Article ( @ArticleIndex ) {

        my $BackendObject = $ArticleObject->BackendForArticle(
            TicketID  => $Ticket{TicketID},
            ArticleID => $Article->{ArticleID},
        );

        next ARTICLE if !$BackendObject->can('ArticleAttachmentIndex');

        # get article data
        my %Article = $BackendObject->ArticleGet(
            TicketID      => $Ticket{TicketID},
            ArticleID     => $Article->{ArticleID},
            DynamicFields => 0,
        );

        # get attachment index (without attachments)
        my %AttachmentIndex = $BackendObject->ArticleAttachmentIndex(
            TicketID  => $Ticket{TicketID},
            ArticleID => $Article->{ArticleID},
            UserID    => $Self->{UserID},
            %StripParams,
        );

        next ARTICLE if !%AttachmentIndex;

        for my $FileID ( sort keys %AttachmentIndex ) {

            # attachment info
            my %Attachment = (
                TicketID    => $Article{TicketID},
                ArticleID   => $Article{ArticleID},
                FileID      => $FileID,
                Filename    => $AttachmentIndex{$FileID}->{Filename},
                FileDate    => $Article{CreateTime},
                ContentType => $AttachmentIndex{$FileID}->{ContentType},
            );

            $LayoutObject->Block(
                Name => 'Attachment',
                Data => \%Attachment,
            );

            $Counter++;

            if ( $AccessOk ) {

                $LayoutObject->Block(
                    Name => 'OtherActions',
                );

                for my $Key (qw(Rename Delete)) {
                    if ( $Param{$Key} ) {
                        $LayoutObject->Block(
                            Name => $Key,
                            Data => \%Attachment,
                        );
                    }
                }
            }
        }
    }

    return {} if !$Counter;

    my $Output = $LayoutObject->Output(
        TemplateFile => 'AgentTicketZoom/AttachmentList',
        Data         => {
            TicketID => $Ticket{TicketID},
        },
    ); 

    return {
        Output => $Output,
    };
}

1;
