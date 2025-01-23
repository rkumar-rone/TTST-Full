import { LightningElement, track } from 'lwc';
import saveConfig from '@salesforce/apex/SIB_ConfiguratorController.saveConfiguratorTypographySettings';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorTypographySettings';

export default class SibTypographyConfigurator extends LightningElement {

    @track container = {};

    connectedCallback(){ 
        getConfig({})
         .then(result => {
              this.container = JSON.parse(result);
        })
        .catch(error => {
          window.console.log("error",error.message);
        });
    }

    onChangeConfig(event){
        this.container[event.target.name] = event.detail.value;  
    }

    validateSaveConfig(event){
        console.log('validateSaveConfig');
        const allValid = [
            ...this.template.querySelectorAll('lightning-slider'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            this.onSaveConfig();
           // alert('All form entries look valid. Ready to submit!');
        } else {
          // alert('Please update the invalid form entries and try again.');
        }
    }

    onSaveConfig(){
        saveConfig({
            settings: JSON.stringify(this.container)
        })
        .then(result => {
        window.console.log(result);
        this.handleCloseProdConfig();
        })
        .catch(error => {
        window.console.log("error",error);
        this.error = error.message;
        });
    }

}