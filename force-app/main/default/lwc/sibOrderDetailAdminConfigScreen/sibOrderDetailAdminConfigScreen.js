import { LightningElement, track} from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SibOrderDetailAdminConfigScreen extends LightningElement {
    @track config;

    activeSections = ['individualConfigs'];
    
    @track pageType = '';
    @track objectApiName = '';

    @track fields = [];
    
    objectAPINameOptions = [
        { label: 'Order', value: 'Order'},
        { label: 'OrderSummary',value: 'OrderSummary'}
    ];

    connectedCallback() {
        this.loadConfig();
    }

    async loadConfig() {
        try {
            const data = await getConfig({configType:'ORDER DETAILS'});
            if (data) {
                this.config = JSON.parse(data);
                this.pageType = this.config.pageType;
                this.objectApiName = this.config.objectApiName;
            }
        } catch (error) {
            console.error('Error loading config:', error);
        }
    }

    handleChange(event) {
        const key = event.target.dataset.id;    
        this.config[key] = event.target.value;
    }

    handleObjectAPINameConfigChange(event){
        const key = event.target.dataset.id;

        let selectedValue = event.detail.value;

        const selectedOption = this.objectAPINameOptions.find(option => option.value === selectedValue);
        if (selectedOption) {
            this.config[key] = selectedOption.value;
        }
    }
    handleSave() {
        console.log('New Config Object to update:'+JSON.stringify(this.config));

        // Extract the keys from this.config to maintain the order
        const keyOrder = Object.keys(this.config);
        console.log('keyOrder:'+JSON.stringify(keyOrder));

        updateConfig({ configStr: JSON.stringify(this.config),keyOrder: JSON.stringify(keyOrder),configId:'ORDER DETAILS'})
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
        this.loadConfig();
    }
}