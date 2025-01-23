import { LightningElement,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import sibOverideStandard from '@salesforce/resourceUrl/SIBOveride';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SibProductConfigurator extends LightningElement {

    @track config = {};

    @track isSupportedProductTypeBundle = false;
    @track isSupportedProductTypeSubscriptionProduct = false;
    @track isSupportedProductTypeUsageProduct = false;
    @track isSubscriptionActionTypeNew = false;
    @track isSubscriptionActionTypeAmend = false;
    @track isSubscriptionActionTypeRenew = false;
    @track isSubscriptionActionTypeCancellationSupport = false;
    @track subscriptionAutomatedRenewals = false;
    @track automatedRenewalPeriod;
    @track autoRenewal = false;
    customTextBoxLabel = 'Please specify the custom service:';

    @track productService;
    @track productSearchService;
    @track cartService;
    @track pricingService;
    @track subscriptionService;
    @track inventoryService;
    @track relatedProductService;
    @track quoteService;

    @track isCustomForCatalogEnabled = false;
    @track isCustomForSearchEnabled = false;
    @track isCustomForCartEnabled = false;
    @track isCustomForPricingEnabled = false;
    @track isCustomForSubscriptionEnabled = false;
    @track isCustomForInventoryEnabled = false;
    @track isCustomForRelatedProductEnabled = false;
    @track isCustomForQuoteEnabled = false;

    @track customServiceValue;
    @track customServiceValueForSearch;
    @track customServiceValueForCart;
    @track externalPricingEngine;
    @track customServiceValueForSubscription;
    @track customServiceValueForInventory;
    @track customServiceValueForRelatedProduct;
    @track customServiceValueForQuote;

    @track prodOptions= [
        { label: 'B2B', value: 'SIB_B2BProductService' , checked: false },
        { label: 'CPQ', value: 'SIB_CPQProductService' , checked: false },
        { label: 'RLM', value: 'SIB_RLMProductService' , checked: false },
        { label: 'Custom', value: 'CustomService' , checked: false }
    ];

    @track relatedProductOptions= [
        { label: 'B2B', value: 'SIB_B2BRelatedProductService' , checked: false },
        { label: 'CPQ', value: 'SIB_CPQRelatedProductService' , checked: false },
        { label: 'RLM', value: 'SIB_RLMRelatedProductService' , checked: false },
        { label: 'Custom', value: 'CustomService' , checked: false }
    ];

    @track searchOptions= [
        { label: 'B2B', value: 'SIB_B2BProductSearchService' , checked: false },
        { label: 'CPQ', value: 'SIB_CPQProductSearchService' , checked: false },
        { label: 'RLM', value: 'SIB_RLMProductSearchService' , checked: false },
        { label: 'Custom', value: 'CustomService', checked: false }
    ];

    @track cartOptions= [
        { label: 'B2B', value: 'SIB_B2BCartService' , checked: false },
        { label: 'CPQ', value: 'SIB_CPQCartService' , checked: false },
        { label: 'RLM', value: 'SIB_RLMCartService' , checked: false },
        { label: 'Custom', value: 'CustomService', checked: false }
    ];

    @track priceOptions= [
            { label: 'B2B', value: 'SIB_B2BPricingService' , checked: false },
            { label: 'CPQ', value: 'SIB_CPQPricingService' , checked: false },
            { label: 'RLM', value: 'SIB_RLMPricingService' , checked: false },
            { label: 'External Pricing Engine', value: 'External Pricing Engine' , checked: false }
        ];

    @track subOptions= [
            { label: 'B2B', value: 'SIB_B2BSubscription' , checked: false },
            { label: 'CPQ', value: 'SIB_CPQSubscription' , checked: false },
            { label: 'RLM', value: 'SIB_RLMSubscription' , checked: false },
            { label: 'Custom', value: 'SIB_CustomSubscription' , checked: false }
        ];

    @track quoteOptions= [
            { label: 'B2B', value: 'SIB_B2BQuotesService' , checked: false },
            { label: 'CPQ', value: 'SIB_CPQQuotesService' , checked: false },
            { label: 'RLM', value: 'SIB_RLMQuotesService' , checked: false },
            { label: 'Custom', value: 'CustomService' , checked: false }
        ];
    
    @track inventoryOptions= [
            { label: 'OmniChannel Inventory', value: 'OmniChannel Inventory' , checked: false },
            { label: 'Custom', value: 'Custom' , checked: false },
        ];
        
    connectedCallback() {
        
        this.loadConfig();
        
        Promise.all([
            loadStyle(this, sibOverideStandard)
        ]).then(() => {
             console.log('style loaded');
        });
    }

    async loadConfig() {
        try {
            const data = await getConfig({configType:'STOREFRONT'});
            if (data) {

                this.config = JSON.parse(data);
                console.log('this.config:'+JSON.stringify(this.config));

                this.productService = this.config.productService;
                this.prodOptions.forEach(option => {
                    if(this.config.isProductServiceCustom){
                        this.isCustomForCatalogEnabled = true;
                        this.customServiceValue = this.config.productService;
                        option.checked = true;
                    }else{
                        this.isCustomForCatalogEnabled = false;
                        this.customServiceValue = '';
                        option.checked = option.value === this.config.productService;
                    }
                });
                
                this.productSearchService = this.config.productSearchService;
                this.searchOptions.forEach(option => {
                    if(this.config.isProductSearchServiceCustom){
                        this.isCustomForSearchEnabled = true;
                        this.customServiceValueForSearch = this.config.productSearchService;
                        option.checked = true;
                    }else{
                        this.isCustomForSearchEnabled = false;
                        this.customServiceValueForSearch = '';
                        option.checked = option.value === this.config.productSearchService;
                    }
                });

                this.relatedProductService = this.config.relatedProductService;
                this.relatedProductOptions.forEach(option => {
                    if(this.config.isRelatedProductServiceCustom){
                        this.isCustomForRelatedProductEnabled = true;
                        this.customServiceValue = this.config.relatedProductService;
                        option.checked = true;
                    }else{
                        this.isCustomForRelatedProductEnabled = false;
                        this.customServiceValue = '';
                        option.checked = option.value === this.config.relatedProductService;
                    }
                });

                this.cartService = this.config.cartService;
                this.cartOptions.forEach(option => {
                    if(this.config.isCartServiceCustom){
                        this.isCustomForCartEnabled = true;
                        this.customServiceValueForCart = this.config.cartService;
                        option.checked = true;
                    }else{
                        this.isCustomForCartEnabled = false;
                        this.customServiceValueForCart = '';
                        option.checked = option.value === this.config.cartService;
                    }
                });
                
                this.pricingService = this.config.pricingService;
                this.priceOptions.forEach(option => {
                    if(this.config.isPricingServiceCustom){
                        this.isCustomForPricingEnabled = true;
                        this.externalPricingEngine = this.config.pricingService;
                        option.checked = true;
                    }else{
                        this.isCustomForPricingEnabled = false;
                        this.externalPricingEngine = '';
                        option.checked = option.value === this.config.pricingService;
                    }
                });

                this.subscriptionService = this.config.subscriptionService;
                this.subOptions.forEach(option => {
                    if(this.config.isSubscriptionServiceCustom){
                        this.isCustomForSubscriptionEnabled = true;
                        this.customServiceValueForSubscription = this.config.subscriptionService;
                        option.checked = true;
                    }else{
                        this.isCustomForSubscriptionEnabled = false;
                        this.customServiceValueForSubscription = '';
                        option.checked = option.value === this.config.subscriptionService;
                    }
                });

                this.quoteService = this.config.quoteService;
                this.quoteOptions.forEach(option => {
                    if(this.config.isQuoteServiceCustom){
                        this.isCustomForQuoteEnabled = true;
                        this.customServiceValueForQuote = this.config.quoteService;
                        option.checked = true;
                    }else{
                        this.isCustomForQuoteEnabled = false;
                        this.customServiceValueForQuote = '';
                        option.checked = option.value === this.config.quoteService;
                    }
                });

                this.inventoryService = this.config.inventoryService;
                this.inventoryOptions.forEach(option => {
                    if(this.config.isInventoryServiceCustom){
                        this.isCustomForInventoryEnabled = true;
                        this.customServiceValueForInventory = this.config.inventoryService;
                        option.checked = true;
                    }else{
                        this.isCustomForInventoryEnabled = false;
                        this.customServiceValueForInventory = '';
                        option.checked = option.value === this.config.inventoryService;
                    }
                });

                this.isSupportedProductTypeBundle = this.config.isSupportedProductTypeBundle;
                this.isSupportedProductTypeSubscriptionProduct = this.config.isSupportedProductTypeSubscriptionProduct;
                this.isSupportedProductTypeUsageProduct = this.config.isSupportedProductTypeUsageProduct;
                this.isSubscriptionActionTypeNew = this.config.isSubscriptionActionTypeNew;
                this.isSubscriptionActionTypeAmend = this.config.isSubscriptionActionTypeAmend;
                this.isSubscriptionActionTypeRenew = this.config.isSubscriptionActionTypeRenew;
                this.isSubscriptionActionTypeCancellationSupport = this.config.isSubscriptionActionTypeCancellationSupport;
                this.subscriptionAutomatedRenewals = this.config.subscriptionAutomatedRenewals;
                if(this.subscriptionAutomatedRenewals){
                    this.autoRenewal = true;
                    this.automatedRenewalPeriod = this.config.automatedRenewalPeriod;
                }
            }
        } catch (error) {
            console.error('Error loading config:', error);
        }
    }

    handleCatalogConfigChange(event){

        let selectedTargetValue = event.target.value;

        this.prodOptions.forEach(option => {
            option.checked = option.value === selectedTargetValue;
        });
        
        const key = event.target.dataset.id;
        if(key==='Custom'){
            this.isCustomForCatalogEnabled = true;
        }else{
            this.isCustomForCatalogEnabled = false;
            const configKey = event.target.dataset.config;
            this.config[configKey] = selectedTargetValue;
            let customKey = 'isProductServiceCustom';
            this.config[customKey] = false;
        }
    }

    handleCustomForCatalogChange(event){
        const configKey = event.target.dataset.config;
        this.customServiceValue = event.target.value;
        this.config[configKey] = event.target.value;
        let customKey = 'isProductServiceCustom';
        this.config[customKey] = true;
    }

    handleSearchConfigChange(event){

        const selectedTargetValue = event.target.value;
        
        this.searchOptions.forEach(option => {
            option.checked = option.value === selectedTargetValue;
        });

        const key = event.target.dataset.id;
        if(key==='Custom'){
            this.isCustomForSearchEnabled = true;
        }else{
            this.isCustomForSearchEnabled = false;
            const configKey = event.target.dataset.config;
            this.config[configKey] = selectedTargetValue;
            let customKey = 'isProductSearchServiceCustom';
            this.config[customKey] = false;
        }
    }

    handleCustomForSearchChange(event){
        const configKey = event.target.dataset.config;
        this.customServiceValueForSearch = event.target.value;
        this.config[configKey] = event.target.value;
        let customKey = 'isProductSearchServiceCustom';
        this.config[customKey] = true;
    }

    handleCartConfigChange(event){

        const selectedTargetValue = event.target.value;
        
        this.cartOptions.forEach(option => {
            option.checked = option.value === selectedTargetValue;
        });

        const key = event.target.dataset.id;
        if(key==='Custom'){
            this.isCustomForCartEnabled = true;
        }else{
            this.isCustomForCartEnabled = false;
            const configKey = event.target.dataset.config;
            this.config[configKey] = selectedTargetValue;
            let customKey = 'isCartServiceCustom';
            this.config[customKey] = false;
        }
    }

    handleCustomForCartChange(event){
        const configKey = event.target.dataset.config;
        this.customServiceValueForCart = event.target.value;
        this.config[configKey] = event.target.value;
        let customKey = 'isCartServiceCustom';
        this.config[customKey] = true;
    }

    handleRelatedProductConfigChange(event){

        const selectedTargetValue = event.target.value;
        
        this.relatedProductOptions.forEach(option => {
            option.checked = option.value === selectedTargetValue;
        });

        const key = event.target.dataset.id;
        if(key==='Custom'){
            this.isCustomForRelatedProductEnabled = true;
        }else{
            this.isCustomForRelatedProductEnabled = false;
            const configKey = event.target.dataset.config;
            this.config[configKey] = selectedTargetValue;
            let customKey = 'isRelatedProductServiceCustom';
            this.config[customKey] = false;
        }
    }

    handleCustomForRelatedProductChange(event){
        const configKey = event.target.dataset.config;
        this.customServiceValueForRelatedProduct = event.target.value;
        this.config[configKey] = event.target.value;
        let customKey = 'isRelatedProductServiceCustom';
        this.config[customKey] = true;
    }

    handleQuoteConfigChange(event){

        const selectedTargetValue = event.target.value;
        
        this.quoteOptions.forEach(option => {
            option.checked = option.value === selectedTargetValue;
        });

        const key = event.target.dataset.id;
        if(key==='Custom'){
            this.isCustomForQuoteEnabled = true;
        }else{
            this.isCustomForQuoteEnabled = false;
            const configKey = event.target.dataset.config;
            this.config[configKey] = selectedTargetValue;
            let customKey = 'isQuoteServiceCustom';
            this.config[customKey] = false;
        }
    }

    handleCustomForQuoteChange(event){
        const configKey = event.target.dataset.config;
        this.customServiceValueForQuote = event.target.value;
        this.config[configKey] = event.target.value;
        let customKey = 'isQuoteServiceCustom';
        this.config[customKey] = true;
    }

    handleSupportedProductTypeChange(event){
        const key = event.target.dataset.id;
        
        const isChecked = event.target.checked;
        
        this.config[key] = isChecked;
        
    }
    
    handlePricingConfigTypeChange(event){
        const key = event.target.dataset.id;

        const selectedTargetValue = event.target.value;
        
        this.priceOptions.forEach(option => {
            option.checked = option.value === selectedTargetValue;
        });

        if(key==='External Pricing Engine'){
            this.isCustomForPricingEnabled = true;
        }else{
            this.isCustomForPricingEnabled = false;
            const configKey = event.target.dataset.config;
            this.config[configKey] = selectedTargetValue;
            let customKey = 'isPricingServiceCustom';
            this.config[customKey] = false;
        }
    }

    handleCustomPricingConfigTypeChange(event){
        const configKey = event.target.dataset.config;
        this.externalPricingEngine = event.target.value;
        this.config[configKey] = event.target.value;
        let customKey = 'isPricingServiceCustom';
        this.config[customKey] = true;
    }

    handleSubscriptionTypeChange(event){
        const key = event.target.dataset.id;

        const selectedTargetValue = event.target.value;
        
        this.subOptions.forEach(option => {
            option.checked = option.value === selectedTargetValue;
        });

        if(key==='Custom'){
            this.isCustomForSubscriptionEnabled = true;
        }else{
            this.isCustomForSubscriptionEnabled = false;
            const configKey = event.target.dataset.config;
            this.config[configKey] = selectedTargetValue;
            let customKey = 'isSubscriptionServiceCustom';
            this.config[customKey] = false;
        }
    }

    handleCustomSubscriptionTypeChange(event){
        const configKey = event.target.dataset.config;
        this.customServiceValueForSubscription = event.target.value;
        this.config[configKey] = event.target.value;
        let customKey = 'isSubscriptionServiceCustom';
        this.config[customKey] = true;
    }

    handleSubActionTypeChange(event){
        const key = event.target.dataset.id;
        
        const isChecked = event.target.checked;
        
        this.config[key] = isChecked;
        
    }

    onChangeRenewal(event){
        const key = event.target.dataset.id;
        let isChecked  = event.target.checked;
        this.config[key] =  event.target.checked;
        if(isChecked){
            this.autoRenewal = true;
        }else{
            this.autoRenewal = false;
            this.automatedRenewalPeriod = '';
            let renewalPeriodKey = 'automatedRenewalPeriod';
            this.config[renewalPeriodKey] = '';
        }
    }

    handleRenewalPeriodChange(event){
        const key = event.target.dataset.id;
        this.automatedRenewalPeriod = event.target.value;
        this.config[key] = event.target.value;
    }

    handleInventoryConfigTypeChange(event){
        const key = event.target.dataset.id;

        const selectedTargetValue = event.target.value;
        
        this.inventoryOptions.forEach(option => {
            option.checked = option.value === selectedTargetValue;
        });

        if(key==='Custom'){
            this.isCustomForInventoryEnabled = true;
        }else{
            this.isCustomForInventoryEnabled = false;
            const configKey = event.target.dataset.config;
            this.config[configKey] = selectedTargetValue;
            let customKey = 'isInventoryServiceCustom';
            this.config[customKey] = false;
        }
    }

    handleCustomInventoryConfigTypeChange(event){
        const configKey = event.target.dataset.config;
        this.customServiceValueForInventory = event.target.value;
        this.config[configKey] = event.target.value;
        let customKey = 'isInventoryServiceCustom';
        this.config[customKey] = true;
    }

    @track billingValue = 'B2B';
    get billingOptions() {
        return [
            { label: 'B2B', value: 'B2B' },
            { label: 'External Billing', value: 'External Billing' },
        ];
    }

    handleBillingConfigTypeChange(event){
        const key = event.target.dataset.id;
    }

    @track revRecValue = 'RightRev';
    get revRecOptions() {
        return [
            { label: 'RightRev', value: 'RightRev' },
            { label: 'External Revenue Recognition', value: 'External Revenue Recognition' },
            { label: 'None', value: 'None' },
        ];
    }
    
    handleRevenueRecognitionChange(event){
        const key = event.target.dataset.id;
    }

    saveBillingAndInvoicingConfig(event){

    }

    @track metricValue = 'MRR';
    get metricOptions() {
        return [
            { label: 'Monthly Recurring Revenue (MRR)', value: 'MRR' },
            { label: 'Annual Recurring Revenue (ARR)', value: 'ARR' },
            { label: 'Churn Rate', value: 'Churn Rate' },
            { label: 'Total Contract Value (TCV)', value: 'TCV' },
            { label: 'Lifetime Value (LTV)', value: 'LTV' },
        ];
    }

    @track paymentValue = 'CyberSource';
    get paymentOptions() {
        return [
            { label: 'CyberSource', value: 'CyberSource' },
            { label: 'Stripe', value: 'Stripe' },
        ];
    }

    @track taxValue = 'Avalara';
    get taxOptions() {
        return [
            { label: 'Avalara', value: 'Avalara' },
            { label: 'Other', value: 'Other' },
        ];
    }

    @track shippingValue = 'FedEX';
    get shippingOptions() {
        return [
            { label: 'FedEX', value: 'FedEX' },
            { label: 'UPS', value: 'UPS' }
        ];
    }

    handleSave(event) {
        console.log('New Config Object to update:'+JSON.stringify(this.config));

        const keyOrder = Object.keys(this.config);

        updateConfig({ configStr: JSON.stringify(this.config),keyOrder: JSON.stringify(keyOrder),configId:'STOREFRONT'})
            .then(result => {
                if (result.status === 'success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Configuration updated successfully',
                            variant: 'success'
                        })
                    );

                    //this.config = {};
                    this.loadConfig();
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
        this.config = {};
        this.loadConfig();
    }

}