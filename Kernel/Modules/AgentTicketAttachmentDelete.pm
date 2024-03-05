# --
# Copyright (C) 2012-2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketAttachmentDelete;

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

    my %GetParam;

    # get params
    for my $Key (qw(TicketID ArticleID FileID)) {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key ) || '';

        # check params
        if ( !$GetParam{$Key} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Message  => "No $Key for '$GetParam{$Key}'!",
                Priority => 'error',
            );
            return $LayoutObject->ErrorScreen();
        }
    }

    # check needed stuff
    if ( !$ConfigObject->Get( 'Attachment::Delete' ) ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Attachment deletion is not allowed!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # check permissions
    my $AccessOK = $TicketObject->TicketPermission(
        Type     => 'rw',
        TicketID => $GetParam{TicketID},
        UserID   => $Self->{UserID}
    );

    # error screen, don't show ticket
    if ( !$AccessOK ) {
        return $LayoutObject->NoPermission( WithHeader => 'yes' );
    }

    my $BackendObject = $ArticleObject->BackendForArticle(
        TicketID  => $GetParam{TicketID},
        ArticleID => $GetParam{ArticleID},
    );

    my $StorageModule = $Kernel::OM->Get( $BackendObject->{ArticleStorageModule} );

    my $Delete = $StorageModule->ArticleDeleteSingleAttachment(
        TicketID  => $GetParam{TicketID},
        ArticleID => $GetParam{ArticleID},
        FileID    => $GetParam{FileID},
        UserID    => $Self->{UserID},
    );

    if ( !$Delete ) {
        return $LayoutObject->ErrorScreen();
    }

    # return output
    return $LayoutObject->Attachment(
        ContentType => 'text/html',
        Content     => $Delete,
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
