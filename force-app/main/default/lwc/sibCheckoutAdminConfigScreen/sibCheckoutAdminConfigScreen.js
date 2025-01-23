import { LightningElement, track} from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SibCheckoutAdminConfigScreen extends LightningElement {
    @track config;

    @track isCreditCardOptionEnabled = false;
    @track isTaxProviderEnabled = false;
    @track isShippingProviderEnabled = false;
    @track allowPromoCode = false;

    activeSections = ['individualConfigs'];

    @track fields = [];

    @track displayLayoutOptions = [
        { label: 'Single Step Layout', value: 'OnePage', checked: false },
        { label: 'Multi Step Layout', value: 'MultiStep', checked: false }
    ];

    @track creditCardGatewayOptions = [
        { label: 'Stripe', value: 'Stripe', checked: false },
        { label: 'Cybersource', value: 'Cybersource', checked: false }
    ];

    @track taxProviderOptions = [
        { label: 'Avalara', value: 'Avalara', checked: false }
    ];

    @track availablePaymentOptions = [
        { label: 'Credit Card', value: 'cc', checked: false },
        { label: 'Purchase Order', value: 'po', checked: false }
    ];

    @track shippingProviderOptions = [
        { label: 'UPS', value: 'UPS', checked: false },
        { label: 'FedEx', value: 'FedEx', checked: false }
    ];

    connectedCallback() {
        this.loadConfig();
    }

    async loadConfig() {
        try {

            const data = await getConfig({configType:'CHECKOUT'});

            if (data) {

                this.config = JSON.parse(data);
                this.allowPromoCode = this.config.allowPromoCode;
                this.displayLayoutOptions.forEach(option => {
                    option.checked = option.value === this.config.displayLayout;
                });

                this.availablePaymentOptions.forEach(option => {
                    option.checked = this.config.availablePaymentMethods.includes(option.value);
                });

                this.availablePaymentOptions.forEach(option => {
                    option.checked = this.config.availablePaymentMethods.includes(option.value);
                });
                
                if(this.config.availablePaymentMethods.includes('cc')){
                    this.isCreditCardOptionEnabled = true;
                }else{
                    this.isCreditCardOptionEnabled = false;
                }

                this.creditCardGatewayOptions.forEach(option => {
                    option.checked = option.value === this.config.creditCardGateway;
                });

                this.isTaxProviderEnabled = this.config.isTaxProviderEnabled;

                this.taxProviderOptions.forEach(option => {
                    option.checked = option.value === this.config.taxProvider;
                });

                this.isShippingProviderEnabled = this.config.isShippingProviderEnabled;

                this.shippingProviderOptions.forEach(option => {
                    option.checked = this.config.shippingProvider.includes(option.value);
                });
                
            }

        } catch (error) {
            console.error('Error loading config:', error);
        }
    }
    handleRadioChange(event){
        const selectedTargetValue = event.target.value;
        const key = event.target.dataset.id;
        this.config[key] = selectedTargetValue;
    }

    handleCheckboxChange(event){
        
        const key = event.target.dataset.id;
        
        const checkedValue = event.target.value;
        
        const isChecked = event.target.checked;
        
        if (isChecked) {
            this.config[key].push(checkedValue);
        } else {
            this.config[key] = this.config[key].filter(value => value !== checkedValue);
        }

        if(key==='availablePaymentMethods'){
            this.availablePaymentOptions.forEach(option => {
                if(option.value===checkedValue){
                    if(!isChecked){
                        option.checked = false;
                    }else{
                        option.checked = true;
                    }
                } 
            });
            if(this.config.availablePaymentMethods.includes('cc')){
                this.isCreditCardOptionEnabled = true;
            }else{
                this.isCreditCardOptionEnabled = false;
            }
        }
    }

    handlePromoChange(event) { 
        const key = event.target.dataset.id;
        this.config[key] = event.target.checked;
    }

    handleProviderChange(event){
        const key = event.target.dataset.id;
        let isChecked = event.target.checked;
        if(key==='isShippingProviderEnabled'){
            this.isShippingProviderEnabled = isChecked;
        }else if(key==='isTaxProviderEnabled'){
            this.isTaxProviderEnabled = isChecked;
        }
        this.config[key] = isChecked;
    }
    
    handleSave() {
        console.log('New Config Object to update:'+JSON.stringify(this.config));

        // Extract the keys from this.config to maintain the order
        const keyOrder = Object.keys(this.config);
        //console.log('keyOrder:'+JSON.stringify(keyOrder));

        updateConfig({ configStr: JSON.stringify(this.config),keyOrder: JSON.stringify(keyOrder),configId:'CHECKOUT'})
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