# --
# Copyright (C) 2012-2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::AdvancedTicketAttachment;    ## no critic

use strict;
use warnings;

use Kernel::Output::Template::Provider;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::SysConfig',
);

=head1 NAME

var::packagesetup::AdvancedTicketAttachment - code to execute during package installation

=head1 DESCRIPTION

Functions for installing the AdvancedTicketAttachment package.

=head1 PUBLIC INTERFACE

=cut

=head2 new()

Create an object.

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CodeObject = $Kernel::OM->Get('var::packagesetup::AdvancedTicketAttachment');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # Force a reload of ZZZAuto.pm and ZZZAAuto.pm to get the fresh configuration values.
    for my $Module ( sort keys %INC ) {
        if ( $Module =~ m/ZZZAA?uto\.pm$/ ) {
            delete $INC{$Module};
        }
    }

    # Create common objects with fresh default config.
    $Kernel::OM->ObjectsDiscard();

    return $Self;
}

=head2 CodeInstall()

Run the code install part.

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    # create needed objects
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');
    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    my $Setting = $ConfigObject->Get('Loader::Module::AgentTicketZoom');

    for my $Key (qw(CSS JavaScript)) {
        if ( $Key eq 'CSS' && $Setting->{'002-Ticket'}->{$Key} ) {
            push @{$Setting->{'002-Ticket'}->{$Key}}, 'Core.AttachmentList.css';
        }
        elsif ( $Key eq 'JavaScript' && $Setting->{'002-Ticket'}->{$Key} ) {
            push @{$Setting->{'002-Ticket'}->{$Key}}, 'Core.Agent.AttachmentList.js';
        }
    }

    my %EffectiveValue = %{$Setting->{'002-Ticket'}};

    return 0 if !$SysConfigObject->SettingsSet(
        UserID   => 1,
        Comments => 'AdvancedTicketAttachment - install specific CSS and JS.',
        Settings => [
            {
                Name           => 'Loader::Module::AgentTicketZoom###002-Ticket',
                EffectiveValue => \%EffectiveValue,
                IsValid        => 1,
            },
        ],
    );

    return 1;
}

=head2 CodeReinstall()

Run the code reinstall part.

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

=head2 CodeUpgrade()

Run the code upgrade part.

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    return 1;
}

=head2 CodeUninstall()

Run the code uninstall part.

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    # create needed objects
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');
    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    my $Setting = $ConfigObject->Get('Loader::Module::AgentTicketZoom');

    for my $Key (qw(CSS JavaScript)) {

        my @Items = @{$Setting->{'002-Ticket'}->{$Key}};
        my $Index = 0;

        $Index++ until $Items[$Index] =~ /AttachmentList/i;
        splice(@Items, $Index, 1);

        $Setting->{'002-Ticket'}->{$Key} = ();
        for my $Item ( @Items ) {
            push @{$Setting->{'002-Ticket'}->{$Key}}, $Item;
        }
    }

    my %EffectiveValue = %{$Setting->{'002-Ticket'}};

    return 0 if !$SysConfigObject->SettingsSet(
        UserID   => 1,
        Comments => 'AdvancedTicketAttachment - uninstall specific CSS and JS.',
        Settings => [
            {
                Name           => 'Loader::Module::AgentTicketZoom###002-Ticket',
                EffectiveValue => \%EffectiveValue,
                IsValid        => 1,
            },
        ],
    );

    return 1;
}

1;

=end Internal:

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<https://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut