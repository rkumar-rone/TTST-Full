import { LightningElement, api, track } from 'lwc';
import saveConfig from '@salesforce/apex/SIB_ConfiguratorController.saveConfiguratorColorSettings';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorColorSettings';

export default class SibStyleConfigurator extends LightningElement {

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
        this.container[event.target.name] = event.target.value;  
    }
    validateSaveConfig(event){
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            this.onSaveConfig();
            //alert('All form entries look valid. Ready to submit!');
        } else {
            //alert('Please update the invalid form entries and try again.');
        }
    }
    onSaveConfig(){
        console.log('Color config : '+JSON.stringify(this.container));
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