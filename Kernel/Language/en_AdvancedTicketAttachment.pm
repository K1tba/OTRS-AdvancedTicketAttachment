# --
# Copyright (C) 2012-2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::en_AdvancedTicketAttachment;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Kernel/Config/Files/AdvancedTicketAttachment.xml
    $Self->{Translation}->{'Frontend module registration for attachment deletion module.'} = '';
    $Self->{Translation}->{'Enables the feature to delete attachments, including from the "Attachments" widget.'} = '';
    $Self->{Translation}->{'Delete ticket attachments.'} = '';
    $Self->{Translation}->{'Delete Ticket Attachments'} = '';
    $Self->{Translation}->{'Frontend module registration for attachment rename module.'} = '';
    $Self->{Translation}->{'Enables the feature to rename attachments, including from the "Attachments" widget.'} = '';
    $Self->{Translation}->{'Rename ticket attachments.'} = '';
    $Self->{Translation}->{'Rename Ticket Attachments'} = '';

    # Kernel/Output/HTML/Templates/Standard/AgentAttachmentRename.tt:
    $Self->{Translation}->{'Rename Attachment'} = '';
    $Self->{Translation}->{'Options'} = '';
    $Self->{Translation}->{'Rename to'} = '';
    $Self->{Translation}->{'Invalid filename!'} = '';

    # Kernel/Output/HTML/Templates/Standard/AgentTicketZoom/AttachmentList.tt
    $Self->{Translation}->{'Filter for attachments list'} = '';
    $Self->{Translation}->{'The file name has been copied.'} = '';
    $Self->{Translation}->{'This operation will permanently delete the file you selected.'} = '';
    $Self->{Translation}->{'Do you really want to delete it?'} = '';
    $Self->{Translation}->{'Deleting the attachment. This may take a while...'} = '';
    $Self->{Translation}->{'Copy file name'} = '';
    $Self->{Translation}->{'Rename'} = '';

    # Kernel/Modules/AgentAttachmentDelete.pm
    $Self->{Translation}->{'Attachment deletion is not allowed!'} = '';

    # Kernel/Modules/AgentAttachmentRename.pm
    $Self->{Translation}->{'Attachment rename is not allowed!'} = '';
    $Self->{Translation}->{'Article not found'} = '';
    $Self->{Translation}->{'Sorry, you need "rw permissions" to do this action!'} = '';

    # HistoryComments (TicketAttachments.sopm) 
    $Self->{Translation}->{'Rename an attachment'} = '';
    $Self->{Translation}->{'Delete an attachment'} = '';

    push @{ $Self->{JavaScriptStrings} // [] }, (
    'Deleting the attachment. This may take a while...',
    'The file name has been copied.',
    );

}

1;