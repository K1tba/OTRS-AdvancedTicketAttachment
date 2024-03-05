// --
// Copyright (C) 2012-2023 Perl-Services.de, https://www.perl-services.de
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Agent.AttachmentList
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for AttachmentList module.
 */
 Core.Agent.AttachmentList = (function (TargetNS) {

    /*
    * @name Init
    * @memberof Core.Agent.AttachmentList
    * @function
    * @description
    *      This function initializes table filter.
    */
    TargetNS.Init = function () {

        Core.UI.Table.InitTableFilter($('#FilterAttachments'), $('#Attachments'));

        $('.CopyText').on('click', function copyTextClipboard(){

            var OriginText = $(this).text(),
                TitleTmp   = OriginText;

            navigator.clipboard.writeText(TitleTmp);

            $(this).fadeOut('fast', function () {
                $(this).css({'text-decoration' : 'none', 'color' : 'green', 'pointer-events' : 'none'});
                $(this).text(Core.Language.Translate("The file name has been copied.")).fadeIn('fast');    

                $(this).fadeOut('fast', function () {
                    $(this).css({'text-decoration' : '', 'color' : '', 'pointer-events' : ''});
                    $(this).text(OriginText).fadeIn('fast');
                });
            });
        });

        // delete postmaster filter
        TargetNS.InitAttachmentDelete();

    };

    /**
     * @name AttachmentDelete
     * @memberof Core.Agent.AttachmentList
     * @function
     * @description
     *      This function deletes postmaster filter on buton click.
     */
    TargetNS.InitAttachmentDelete = function () {
        $('.AttachmentDelete').on('click', function confirmDeletion() {
            var Data = {
                Action: 'AgentAttachmentDelete',
                TicketID: $(this).attr('data-ticket-id'),
                ArticleID: $(this).attr('data-article-id'),
                FileID: $(this).attr('data-file-id')
            };

            Core.UI.Dialog.ShowContentDialog(
                $('#DeleteAttachmentDialogContainer'),
                Core.Language.Translate('Delete'),
                '240px',
                'Center',
                true,
                [
                    {
                        Class: 'Primary',
                        Label: Core.Language.Translate("Confirm"),
                        Function: function () {
                            $('.Dialog .InnerContent .Center').text(Core.Language.Translate("Deleting the attachment. This may take a while..."));
                            $('.Dialog .Content .ContentFooter').remove();

                            Core.AJAX.FunctionCall(
                                Core.Config.Get('CGIHandle'),
                                Data,
                                function() {
                                   Core.App.InternalRedirect({
                                       Action: 'AgentTicketZoom',
                                       TicketID: Data.TicketID,
                                       ArticleID: Data.ArticleID
                                   });
                                }
                            );
                        }
                    },
                    {
                        Label: Core.Language.Translate("Cancel"),
                        Function: function () {
                            Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                        }
                    }
                ]
            );
            return false;
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.AttachmentList || {}));
