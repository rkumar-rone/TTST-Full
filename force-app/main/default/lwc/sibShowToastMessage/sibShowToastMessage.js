/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 02-24-2024
 * @last modified by  : sthakur@rafter.one
**/
import { LightningElement, api } from 'lwc';

export default class SibShowToastMessage extends LightningElement {

    type;
    message;
    showToastBar = false;
    autoCloseTime = 60000;

    @api
    showToast(message,type,duration) {
        this.type = type;
        this.autoCloseTime = duration;
        this.message = message;
        this.showToastBar = true;
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }

    closeModel() {
        this.showToastBar = false;
        this.type = '';
        this.message = '';
    }

    get getIconName() {
        return 'utility:' + this.type;
    }
 
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
}