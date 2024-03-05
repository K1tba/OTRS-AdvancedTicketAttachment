# --
# Copyright (C) 2012-2023 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::ru_AdvancedTicketAttachment;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Kernel/Config/Files/AdvancedTicketAttachment.xml
    $Self->{Translation}->{'Frontend module registration for attachment deletion module.'} = '';
    $Self->{Translation}->{'Enables the feature to delete attachments, including from the "Attachments" widget.'} = 'Включает функцию удаления вложений, в том числе из виджета "Прикрепленные файлы".';
    $Self->{Translation}->{'Delete ticket attachments.'} = 'Удалить вложения заявки.';
    $Self->{Translation}->{'Delete Ticket Attachments'} = 'Удалить Вложения Заявки';
    $Self->{Translation}->{'Frontend module registration for attachment rename module.'} = '';
    $Self->{Translation}->{'Enables the feature to rename attachments, including from the "Attachments" widget.'} = 'Включает функцию переименования вложений, в том числе из виджета "Прикрепленные файлы".';
    $Self->{Translation}->{'Rename ticket attachments.'} = 'Переименовать вложения заявки.';
    $Self->{Translation}->{'Rename Ticket Attachments'} = 'Переименовать Вложения Заявки';

    # Kernel/Output/HTML/Templates/Standard/AgentTicketAttachmentRename.tt:
    $Self->{Translation}->{'Rename Attachment'} = 'Переименовать вложение';
    $Self->{Translation}->{'Options'} = 'Опции';
    $Self->{Translation}->{'Rename to'} = 'Переименовать в';
    $Self->{Translation}->{'Invalid filename!'} = 'Недопустимое имя файла!';

    # Kernel/Output/HTML/Templates/Standard/AgentTicketZoom/AttachmentList.tt
    $Self->{Translation}->{'Filter for attachments list'} = 'Фильтр для списка вложений';
    $Self->{Translation}->{'The file name has been copied.'} = 'Имя файла было скопировано.';
    $Self->{Translation}->{'This operation will permanently delete the file you selected.'} = 'Данная операция безвозвратно удалит выбранный вами файл.';
    $Self->{Translation}->{'Do you really want to delete it?'} = 'Вы действительно хотите его удалить?';
    $Self->{Translation}->{'Deleting the attachment. This may take a while...'} = 'Удаление вложения. Это может занять некоторое время...';
    $Self->{Translation}->{'Copy file name'} = 'Копировать имя файла';
    $Self->{Translation}->{'Rename'} = 'Переименовать';

    # Kernel/Modules/AgentTicketAttachmentDelete.pm
    $Self->{Translation}->{'Attachment deletion is not allowed!'} = 'Удаление вложений запрещено!';

    # Kernel/Modules/AgentTicketAttachmentRename.pm
    $Self->{Translation}->{'Attachment rename is not allowed!'} = 'Переименование вложения запрещено!';
    $Self->{Translation}->{'Article not found'} = 'Сообщение/заметка не найдена';
    $Self->{Translation}->{'Sorry, you need "rw permissions" to do this action!'} = 'Извините, для выполнения этого действия вам нужны "разрешения rw"!';

    # HistoryComments (TicketAttachments.sopm) 
    $Self->{Translation}->{'Rename an attachment'} = 'Переименовать вложение';
    $Self->{Translation}->{'Delete an attachment'} = 'Удалить вложение';

    push @{ $Self->{JavaScriptStrings} // [] }, (
    'Deleting the attachment. This may take a while...',
    'The file name has been copied.',
    );

}

1;