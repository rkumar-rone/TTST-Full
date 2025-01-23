import { LightningElement, track} from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SibSignupAdminConfigScreen extends LightningElement {
    @track config;

    activeSections = ['individualConfigs'];

    @track showPasswordFields = false;

    connectedCallback() {
        this.loadConfig();
    }

    async loadConfig() {
        try {
            const data = await getConfig({configType:'SIGNUP'});
            if (data) {
                this.config = JSON.parse(data);
                this.showPasswordFields = this.config.showPasswordFields;
            }
        } catch (error) {
            console.error('Error loading config:', error);
        }
    }

    handleShowPasswordChange(event) {
        const key = event.target.dataset.id;
        this.config[key] = event.target.checked;
    }

    handleSave() {

        // Extract the keys from this.config to maintain the order
        const keyOrder = Object.keys(this.config);
        console.log('keyOrder:'+JSON.stringify(keyOrder));

        updateConfig({ configStr: JSON.stringify(this.config),keyOrder: JSON.stringify(keyOrder),configId:'SignUp'})
            .then(result => {
                if (result.status === 'success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Configuration updated successfully',
                            variant: 'success'
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result.message,
                            variant: 'error'
                        })
                    );
                    console.error('Error updating config:', result.message);
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error'
                    })
                );
                console.error('Error updating config:', error);
            });
    }

    handleCancel() {
        console.log('updated config:'+JSON.stringify(this.config));
        if (this.originalConfig) {
            console.log('originalConfig:'+this.originalConfig);
            this.config = JSON.parse(JSON.stringify(this.originalConfig));
            console.log('config:'+this.config);
        } else {
            console.error('Original config is not defined.');
        }
    }
}