import { LightningElement, wire, api } from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorTemplateSettings';

/**
 * @slot recommendations
 */

export default class SibCartContainer extends LightningElement {
    isCartPage = true;
    questStore;

    @wire(getConfig,  { })
    getConfigWired({ error, data }) {
        if (data) {
            this.questStore = data == 'templateTwo' ? true : false;
        } else if (error) {
            console.error(error);
        }
    };

    get displayCartPage(){
        return this.questStore != null;
    }
}