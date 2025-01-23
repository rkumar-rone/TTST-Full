import { LightningElement, wire } from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorTemplateSettings';

export default class SibHeaderContainer extends LightningElement {

    // static renderMode = 'light';
    questStore;

    @wire(getConfig,  { })
    getConfigWired({ error, data }) {
        if (data) {
            this.questStore = data == 'templateTwo' ? true : false;
            // this.isConfigLoaded;
        } else if (error) {
            console.error(error);
        }
    };
}