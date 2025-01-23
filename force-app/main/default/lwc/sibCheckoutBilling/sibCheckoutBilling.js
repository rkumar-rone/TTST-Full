import { LightningElement, api, track, wire} from 'lwc';
import { subscribe, publish, MessageContext, unsubscribe } from 'lightning/messageService';
import CHECKOUT_STATE_MESSAGE_CHANNEL from '@salesforce/messageChannel/sibMultiStepCheckoutMessages__c';
import getContactPointAddresses from '@salesforce/apex/SIB_AddressController.getContactPointAddresses';
import updateCartWithCPA from '@salesforce/apex/SIB_AddressController.updateCartWithCPA';
import checkoutApi from 'commerce/checkoutApi';

//state country picklist start
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';
//labels
import SIB_LBL_BILLING_SUCCESS from '@salesforce/label/c.SIB_BillingAddressSuccess';
import SIB_LBL_NEW_BILLING_ADDRESS from '@salesforce/label/c.SIB_NewBillingAddress';
import SIB_LBL_FIELD_VALIDATION from '@salesforce/label/c.SIB_BillingFieldValidationError';
import SIB_LBL_BILLING_SAVE_ERROR from '@salesforce/label/c.SIB_BillingAddressSaveError';
import SIB_LBL_BILLING_HEADING from '@salesforce/label/c.SIB_BillingHeading';
import SIB_LBL_BILLING_STREET_HEADING from '@salesforce/label/c.SIB_BillingFieldStreetHeading';
import SIB_LBL_BILLING_STREET_PLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldStreetPlaceholder';
import SIB_LBL_BILLING_CITY_HEADING from '@salesforce/label/c.SIB_BillingFieldCityHeading';
import SIB_LBL_BILLING_CITY_PLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldCityPlaceholder';
import SIB_LBL_BILLING_COUNTRY_HEADING from '@salesforce/label/c.SIB_BillingFieldCountryHeading';
import SIB_LBL_BILLING_COUNTRY_PLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldCountryPlaceholder';
import SIB_LBL_BILLING_STATE_HEADING from '@salesforce/label/c.SIB_BillingFieldStateHeading';
import SIB_LBL_BILLING_STATE_PLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldStatePlaceholder';
import SIB_LBL_BILLING_ZIP_HEADING from '@salesforce/label/c.SIB_BillingFieldZipHeading';
import SIB_LBL_BILLING_ZIP_PLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldZipPlaceholder';
import SIB_COUNTRIESREQUIRINGPOSTALCODE from '@salesforce/label/c.SIB_CountriesRequiringPostalCode';
import SIB_COUNTRIESREQUIRINGSTATE from '@salesforce/label/c.SIB_CountriesRequiringState';
import { applicationLogging, getCookie } from "c/sibUtils";

//state country picklist end

export default class SibCheckoutBilling extends LightningElement {
    @api billingSelectedOption;
    billingSelectedOptionLabel;

    @api checkoutConfig;
    @api checkoutDetails;

    @track _cartDetails;
    cartId;
    effectiveAccountId;
    isStencilLoading = true;
    firstLoad = true;
    checkForFreeCourse;
    @api 
    get cartDetails(){
        return this._cardDetails;
    }
    set cartDetails(value){
        this._cartDetails = value;
        if(value?.cartId!=null && value?.accountId!=null && this.firstLoad){
            this.firstLoad = false;
            this.cartId = value?.cartId;
            this.effectiveAccountId = value?.accountId;
            this.checkForFreeCourse = Number(value?.grandTotalAmount) > 0
            this.fetchCPA(value?.accountId);
        }
    }

    showEdit=false;

    @track enteredAddress = {};
    billingAddresses;
    @track billingOptions = [];
    @track showNewBillingAddressForm;
    countriesRequiringPostalCode = [];
    countriesRequiringState = [];

    stylingConstants = {
        errorTextField : 'sib-input-box-error',
    }

    labels={
        SIB_LBL_BILLING_SUCCESS,
        SIB_LBL_NEW_BILLING_ADDRESS,
        SIB_LBL_FIELD_VALIDATION,
        SIB_LBL_BILLING_SAVE_ERROR,
        SIB_LBL_BILLING_HEADING,
        SIB_LBL_BILLING_STREET_HEADING,
        SIB_LBL_BILLING_STREET_PLACEHOLDER,
        SIB_LBL_BILLING_CITY_HEADING,
        SIB_LBL_BILLING_CITY_PLACEHOLDER,
        SIB_LBL_BILLING_COUNTRY_HEADING,
        SIB_LBL_BILLING_COUNTRY_PLACEHOLDER,
        SIB_LBL_BILLING_STATE_HEADING,
        SIB_LBL_BILLING_STATE_PLACEHOLDER,
        SIB_LBL_BILLING_ZIP_HEADING,
        SIB_LBL_BILLING_ZIP_PLACEHOLDER,
        SIB_COUNTRIESREQUIRINGPOSTALCODE,
        SIB_COUNTRIESREQUIRINGSTATE
    }

    //messagechannel objects
    subscription = null;
    isBillingReadOnly = true;

    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            CHECKOUT_STATE_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    connectedCallback(){
        this.subscribeToMessageChannel();
        let checkoutStage = getCookie("checkoutStage");
        if(checkoutStage && checkoutStage !== 'groupOrders') {
            this.showEdit = true;
        }
        if(checkoutStage && checkoutStage === 'billing') {
            this.isBillingReadOnly = false;
        } else {
            this.isBillingReadOnly = true;
        }
        
        // Split the custom label strings by comma and trim spaces to create arrays
        this.countriesRequiringPostalCode = this.labels.SIB_COUNTRIESREQUIRINGPOSTALCODE.split(',').map(country => country.trim());
        this.countriesRequiringState = this.labels.SIB_COUNTRIESREQUIRINGSTATE.split(',').map(country => country.trim());
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    handleMessage(message) {
        if(message.nextState === 'billing')
        {
            this.isBillingReadOnly = false;
            this.showEdit=true;
        }else
        {
            this.isBillingReadOnly = true;
        }
    }

    publishProceedToNextStep(){
        this.isBillingReadOnly = true;
        this.showToast(SIB_LBL_BILLING_SUCCESS, 'success');
        this.publishCheckoutState('payment');
    }

    publishCheckoutState(nextState) {
        const payload = { 
            nextState: nextState,
        };
        publish(this.messageContext, CHECKOUT_STATE_MESSAGE_CHANNEL, payload);
    }

    //state country picklist start
    //state-country dependent picklists
    _countries = [];
    _countryToStates = {};

    @wire(getObjectInfo, {objectApiName: ACCOUNT_OBJECT })
    accountInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$accountInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTRY_CODE
    })
    wiredCountires({ data }) {
        this._countries = data?.values;
        var i = 0;
        var tempCountries = [];
        if(this._countries !== undefined)
        {
            for(i = 0; i < this._countries.length; i++)
            {
                tempCountries.push(this._countries[i]);
            }
            this._countries = tempCountries;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: BILLING_STATE_CODE })
    wiredStates({ data }) {
        if (!data) {
            return;
        }
        const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));

        this._countryToStates = data.values.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForNumberToCountry[state.validFor[0]];

            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
        }, {});
    }

    get countries() {
        return this._countries;
    }

    get states() {
        if(this.enteredAddress) {
            return this._countryToStates[this.enteredAddress.CountryCode] || [];
        }
        return [];
    }

    get showStateRequired(){
        if(this.enteredAddress.CountryCode != null) {
            return this.states.length > 0 && this.countriesRequiringState?.includes(this.enteredAddress.CountryCode);
        }
        return true;
    }

    get showZipCodeRequired() {
        if(this.enteredAddress.CountryCode != null) {
            return this.countriesRequiringPostalCode?.includes(this.enteredAddress.CountryCode);
        }
        return true;
    }

    //update address inputs
    updateAddressInput(event) {
        this.enteredAddress[event.target.name] = event.target.value;

        let currentField = this.refs[event.target.name];

        if(currentField && (currentField?.value === '' || currentField?.value == null))
        {
            currentField?.classList?.add(this.stylingConstants.errorTextField);
        } else
        {
            if(currentField?.classList?.contains(this.stylingConstants.errorTextField))
            {
                currentField?.classList?.remove(this.stylingConstants.errorTextField);
            }
        }
    }

    handleCountryChange(event){
        this.enteredAddress.CountryCode = event.target.value;
        this.enteredAddress.StateCode = '';
        if(event?.target?.value && (event?.target?.value === '' || event?.target?.value == null ||
            event?.target?.value === this.labels.SIB_LBL_BILLING_COUNTRY_PLACEHOLDER))
        {
            this.refs?.CountryCode?.classList.add(this.stylingConstants.errorTextField);
        } else if(this.refs?.CountryCode?.classList.contains(this.stylingConstants.errorTextField))
        {
                this.refs?.CountryCode?.classList.remove(this.stylingConstants.errorTextField);
        }
    }

    handleStateChange(event) {
        this.enteredAddress.StateCode = event.target.value;
        if(event?.target?.value && (event?.target?.value === '' || event?.target?.value == null || event?.target?.value === this.labels.SIB_LBL_BILLING_STATE_PLACEHOLDER))
        {
            this.refs?.StateCode?.classList.add(this.stylingConstants.errorTextField);
        } else if(this.refs?.StateCode?.classList.contains(this.stylingConstants.errorTextField)){
                this.refs?.StateCode?.classList.remove(this.stylingConstants.errorTextField);
        }
    }

    fetchCPA(accountId){
        let dataMap={
            'AccountId':accountId,
            'AddressType':'Billing'
        }
        getContactPointAddresses({'dataMap':dataMap})
        .then(data => {
            if(data.isSuccess){
                if(data.Addresses){
                    this.populateBillingAddresses(data.Addresses,false);
                }
                else{
                    this.populateBillingAddresses(null,false);
                }
            }
        })
        .catch(error => {
            console.log(error);
        });
    }

    populateBillingAddresses(data,publishNextState){
        this.enteredAddress = {};
        this.billingOptions=[];
        if(data!=null)
        {
            this.billingAddresses = new Map(data.map(addr => [addr.Id, addr]));
            data.forEach(addr => {
                let street = addr.Street?addr.Street+', ' : '';
                let city = addr.City?addr.City+', ' : '';
                let state = addr.State?addr.State+', ' : '';
                let country = addr.Country?addr.Country+' ' : '';
                let postalCode = addr.PostalCode?addr.PostalCode : '';
                this.billingOptions.push({ label: street + city + state + country + postalCode, value: addr.Id });
            });
        }
        this.billingOptions.push({ label: SIB_LBL_NEW_BILLING_ADDRESS, value: 'new' });
        this.billingSelectedOption = this.billingOptions[0].value;
        this.billingSelectedLabel = this.billingOptions[0].label !== SIB_LBL_NEW_BILLING_ADDRESS ? this.billingOptions[0].label : '';
        if(this.billingSelectedOption === 'new')
        {
            this.showNewBillingAddressForm = true;
        }
        this.isStencilLoading = false;
        if(publishNextState)
        {
            this.publishProceedToNextStep();
        }
    }

    goNext(){
        if(this.billingSelectedOption === 'new')
        {
            let validAddress = this.validateAddress(this.enteredAddress);
            if(validAddress)
            {
                //update the contact point address
                this.enteredAddress.Id='';
                this.createAndLinkCPA(this.enteredAddress);
            }else
            {
                this.showToast(SIB_LBL_FIELD_VALIDATION, 'error');
            }
        } else
        {
            this.createAndLinkCPA(this.billingAddresses.get(this.billingSelectedOption));
        }
    }

    createAndLinkCPA(address) {
        this.isStencilLoading = true;
        let addressMap={
            'Id': address.Id?address.Id:null,
            'City': address.City,
            'CountryCode': address.CountryCode,
            'PostalCode': address.PostalCode,
            'StateCode': address.StateCode,
            'Street': address.Street,
            'AddressType': 'Billing',
            'ParentId': this.effectiveAccountId
        };
        let dataMap = {
            'CartId':this.cartId,
            'Address' :addressMap
        }
        updateCartWithCPA({'dataMap':dataMap})
        .then((result)=>
        {
            if(result.isSuccess)
            {
                let shippingId='';
                if(result.ShippingAddresses)
                {
                    result.ShippingAddresses.forEach((addr)=>{
                        if(addr.CountryCode === addressMap.CountryCode && addr.PostalCode === addressMap.PostalCode
                            && addr.Street === addressMap.Street && addr.City === addressMap.City
                            && addr.StateCode === addressMap.StateCode)
                        {
                            shippingId = addr.Id;
                        }
                    })
                }
                if(shippingId!=='')
                {
                    this.updateShippingAddress(result.Address,shippingId);
                }
                else
                {
                    this.updateShippingAddress(result.Address,null);
                }
                this.showNewBillingAddressForm=false;
                this.populateBillingAddresses(result.Addresses,true);
                if (result && result.log)
                {
                    applicationLogging(result.log);
                }
            }
            else{
                this.showToast(SIB_LBL_BILLING_SAVE_ERROR, 'error');
                this.isStencilLoading = false;
            }
        })
        .catch((error)=>{
            this.showToast(SIB_LBL_BILLING_SAVE_ERROR, 'error');
            console.error(error);
            this.isStencilLoading = false;
        })

    }

    updateShippingAddress(address,id) {
        let deliveryAddress={};
        if(id!=null){
            deliveryAddress = {
                addressId: address.Id
            };
            this.updateShippingWithApi(deliveryAddress);
        }
        else{
            deliveryAddress = {
                addressType : 'Shipping',
                city : address.City?address.City:null,
                country : address.CountryCode?address.CountryCode:null,
                name : address.Name? address.Name.replace('Billing','Shipping'):null ,
                postalCode : address.PostalCode?address.PostalCode:null,
                street : address.Street?address.Street:null,
                region : address.StateCode?address.StateCode:null
            };
            this.createShippingAddress(deliveryAddress);
        }
        
    }

    async createShippingAddress(address){
        const createCPAResult = await checkoutApi.createContactPointAddress(address);
        if(createCPAResult){
            let deliveryAddress={
                addressId: createCPAResult.addressId
            };
            this.updateShippingWithApi(deliveryAddress);
        }
    }

    async updateShippingWithApi(address){
        const updateShippingAddressResult = await checkoutApi.updateShippingAddress({"deliveryAddress":address});
        if(updateShippingAddressResult){
            const notifyResult = await checkoutApi.loadCheckout();
        }
    }

    validateAddress(add) {
        let isValid = true;
        let fieldsToValidate = ['Street', 'City'];
        //check other fields for validity
        fieldsToValidate?.forEach(fieldName => {
            let field = this.refs[fieldName];
            if(field && (field?.value === '' || field?.value === undefined))
            {
                field?.classList?.add(this.stylingConstants.errorTextField);
                isValid = false;
            }
        });

        // Get country, state, postalcode field reference
        let countryField = this.refs['CountryCode'];
        let stateField = this.refs['StateCode'];
        let postalCodeField = this.refs['PostalCode'];

        if(countryField && (countryField?.value === '' || countryField?.value === undefined || countryField?.value === this.labels.SIB_LBL_BILLING_COUNTRY_PLACEHOLDER))
        {
            countryField?.classList?.add(this.stylingConstants.errorTextField);
            stateField?.classList?.add(this.stylingConstants.errorTextField);
            postalCodeField?.classList?.add(this.stylingConstants.errorTextField);
            isValid = false;
        } else
        {
            stateField?.classList?.remove(this.stylingConstants.errorTextField);
            postalCodeField?.classList?.remove(this.stylingConstants.errorTextField);
        }
        if(this.countriesRequiringState.includes(countryField?.value) && stateField &&
            (stateField?.value === '' || stateField?.value === undefined || stateField?.value == null || stateField?.value === this.labels.SIB_LBL_BILLING_STATE_PLACEHOLDER))
        {
            stateField?.classList?.add(this.stylingConstants.errorTextField);
            isValid = false;
        }
        if(this.countriesRequiringPostalCode.includes(countryField?.value) && postalCodeField &&
            (postalCodeField?.value === '' || postalCodeField?.value === undefined || postalCodeField?.value === null))
        {
            postalCodeField?.classList?.add(this.stylingConstants.errorTextField);
            isValid = false;
        }
        return isValid;
    }

    handleBillingChange(event) {
        this.enteredAddress = {};
        this.billingSelectedOption = event.target.value;
        this.showNewBillingAddressForm = event.target.value === 'new';
    }

    showToast(message,type) {
        let field = document.querySelector('c-sib-show-toast-message');
        field.showToast(message,type,6000);
    }

    handleEdit() {
        this.publishCheckoutState('billing');
    }
}