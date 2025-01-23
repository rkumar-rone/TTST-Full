/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : Gaurav Setia
**/
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import microformScript from '@salesforce/resourceUrl/CybersourceMicroform';
import communityId from '@salesforce/community/Id';
import { getSessionContext } from 'commerce/contextApi';
import { useCheckoutComponent, CheckoutInformationAdapter} from 'commerce/checkoutApi';
import generateKey from '@salesforce/apex/SIB_CybersourceController.generateKey';
import authorizeCard from '@salesforce/apex/SIB_CybersourceController.proceedToPayment';
import { CartSummaryAdapter } from 'commerce/cartApi';
import { getCookie } from "c/sibUtils";

//state country picklist start
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';

//apex
import updatePaymentMethodOnCart from '@salesforce/apex/SIB_CybersourceController.updatePaymentMethodOnCart';
import capturePaymentAuthorization from '@salesforce/apex/SIB_CybersourceController.capturePaymentAuthorization';
import revertAuthorization from '@salesforce/apex/SIB_CybersourceController.revertAuthorization';
import updateCheckOutCartStatus from '@salesforce/apex/SIB_CartController.updateCheckOutCartStatus';


//images
import SIB_Icons from '@salesforce/resourceUrl/SIB_Icons';

//labels
import SIB_LBL_FILLINALLFIELDS from '@salesforce/label/c.SIB_FillInAllFields';
import SIB_LBL_CARDEXPIRED from '@salesforce/label/c.SIB_CreditCardExpired';
import SIB_LBL_ENTERCARDNUMBER from '@salesforce/label/c.SIB_EnterCardNumber';
import SIB_LBL_COULDNOTRETRIEVECHECKOUT from '@salesforce/label/c.SIB_CouldNotRetrieveCheckout';
import SIB_LBL_COULDNOTRETRIEVECART from '@salesforce/label/c.SIB_CouldNotRetrieveCart';
import SIB_LBL_MICROFLEXCREATIONERROR from '@salesforce/label/c.SIB_MicroflexCreationError';
import SIB_LBL_CARDINFORMATIONINCORRECT from '@salesforce/label/c.SIB_CardInformationIncorrect';
import SIB_LBL_CVVINVALID from '@salesforce/label/c.SIB_CvvIsInvalid';
import SIB_LBL_COULDNOTVERIFYCARD from '@salesforce/label/c.SIB_CouldNotVerifyCardInformation';
import SIB_LBL_COULDNOTAUTHORIZECARD from '@salesforce/label/c.SIB_CouldNotAuthorizeCard';
import SIB_LBL_COULDNOTCOMPLETEPAYMENT from '@salesforce/label/c.SIB_CouldNotCompletePayment';
import SIB_LBL_PAYMENTSUCCESSFUL from '@salesforce/label/c.SIB_PaymentSuccessfull';
import SIB_LBL_PAYMENTAUTHSUCCESS from'@salesforce/label/c.SIB_PaymentAuthorizationSuccessful';
import SIB_LBL_PROCESSINGPAYMENTPLEASEWAIT from '@salesforce/label/c.SIB_ProcessingPayment';
import SIB_LBL_SOMETHINGWENTWRONGPROCESSINGPAYMENT from '@salesforce/label/c.SIB_SOMETHINGWRONGWITHPAYMENT';
import SIB_LBL_FIRSTNAME from '@salesforce/label/c.SIB_Firstname';
import SIB_LBL_LASTNAME from '@salesforce/label/c.SIB_Lastname';
import SIB_LBL_STREETADDRESS from '@salesforce/label/c.SIB_BillingFieldStreetPlaceholder';
import SIB_LBL_CITYLABEL from '@salesforce/label/c.SIB_BillingFieldCityHeading';
import SIB_LBL_CITYPLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldCityPlaceholder';
import SIB_LBL_COUNTRYLABEL from '@salesforce/label/c.SIB_BillingFieldCountryHeading';
import SIB_LBL_COUNTRYPLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldCountryPlaceholder';
import SIB_LBL_STATELABEL from '@salesforce/label/c.SIB_BillingFieldStateHeading';
import SIB_LBL_STATEPLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldStatePlaceholder';
import SIB_LBL_POSTALLABEL from '@salesforce/label/c.SIB_BillingFieldZipHeading';
import SIB_LBL_POSTPLACEHOLDER from '@salesforce/label/c.SIB_BillingFieldZipPlaceholder'
import SIB_LBL_CARDNUMBERLABEL from '@salesforce/label/c.SIB_CardNumberLabel';
import SIB_LBL_CVVLABEL from '@salesforce/label/c.SIB_CVVLABEL';
import SIB_LBL_CVVPLACEHOLDER from '@salesforce/label/c.SIB_CvvPlaceholder';
import SIB_LBL_EXPIRYMONTHLABEL from '@salesforce/label/c.SIB_ExpiryMonthLabel';
import SIB_LBL_EXPIRYMONTHPLACEHOLDER from '@salesforce/label/c.SIB_ExpiryMonthPlaceholder';
import SIB_LBL_EXPIRYYEARLABEL from '@salesforce/label/c.SIB_ExpiryYearLabel';
import SIB_LBL_EXPIRYYEARPLACEHOLDER from '@salesforce/label/c.SIB_ExpiryYearPlaceholder';
import SIB_LBL_NEXTSTEPLABEL from '@salesforce/label/c.SIB_NextStepLabel';
import SIB_LBL_PAYLABEL from '@salesforce/label/c.SIB_Pay';
import SIB_LBL_PAYMENT from '@salesforce/label/c.SIB_Payment';
import SIB_COUNTRIESREQUIRINGPOSTALCODE from '@salesforce/label/c.SIB_CountriesRequiringPostalCode';
import SIB_COUNTRIESREQUIRINGSTATE from '@salesforce/label/c.SIB_CountriesRequiringState';
import SIB_SAMEASBILLINGADDRESS from '@salesforce/label/c.SIB_SameAsBillingAddress';
import SIB_ErrorMsgforInvalidMonth from '@salesforce/label/c.SIB_ErrorMsgforInvalidMonth';
import SIB_ErrorMsgforInvalidYear from '@salesforce/label/c.SIB_ErrorMsgforInvalidYear';
import SIB_GROUPRECIPIENTSMISMATCH from '@salesforce/label/c.SIB_GroupRecipientsMismatch';



export default class SibCybersourceCreditCard extends NavigationMixin(useCheckoutComponent(LightningElement)) {

    static renderMode = "light"; // the default is 'shadow'

    @api checkoutDetails;
    @api paymentConfig;
    @api paymentRendered;

    //boolean
    isPaymentComplete = false;
    isCCSelected = true;
    isPOSelected = false;
    isSameAsShippingAddress = true;
    isLoading = true;
    isCardNumberValid = false;
    isCvvValid = false;
    isCheckoutInfoLoaded = false;
    isCartInfoLoaded = false;
    isGroupOrderCart = false;
    isWaitlistedCart = false;
    isShowSpinner = false;
    isPaymentReadOnly = false;
    isPaymentInformationCompleted = false;
    isSameAsBillingAddress = true;
    isShippingAddressLoaded = false;

    //integer
    _checkoutMode = 1;
    
    microform;
    orderReferenceNumber;
    
    //text
    firstName = '';
    lastName = '';
    nickname = '';
    street = '';
    city = '';
    state = '';
    country = '';
    postalCode = '';
    expMonth = '01';
    expYear = '2023';
    effectiveAccountId;
    cardType = '';
    originalCardType = '';
    authorizationId = '';
    transientToken = '';
    processingPaymentMessage = '';

    //array
    monthOptions = [
        { label: '01', value: '01' },
        { label: '02', value: '02' },
        { label: '03', value: '03' },
        { label: '04', value: '04' },
        { label: '05', value: '05' },
        { label: '06', value: '06' },
        { label: '07', value: '07' },
        { label: '08', value: '08' },
        { label: '09', value: '09' },
        { label: '10', value: '10' },
        { label: '11', value: '11' },
        { label: '12', value: '12' }
    ];
    yearOptions = [];
    stateOptions = [];
    _countries = [];
    countriesRequiringPostalCode = [];
    countriesRequiringState = [];

    //tracked fields
    @track checkoutId;
    @track shippingAddress;
    @track errorMessages = [];
    @track billingAddress;
    @track grandTotalAmount;

    //objects
    mapParams = {};
    images = {
        amex : SIB_Icons + '/SIB_Icons/cc-amex.png',
        mastercard : SIB_Icons + '/SIB_Icons/cc-mastercard.png',
        visa : SIB_Icons + '/SIB_Icons/cc-visa.png',
        jcb : SIB_Icons + '/SIB_Icons/cc-jcb.svg',
        discover : SIB_Icons + '/SIB_Icons/cc-discover.svg',
        maestro : SIB_Icons +'/SIB_Icons/cc-maestro.svg'
    }
    cartSummary = {};
    _countryToStates = {};

    stylingConstants = {
        errorTextField : 'sib-input-box-error',
    }

    paymentAuthorization = {};  


    labels = {
        SIB_ErrorMsgforInvalidYear,
        SIB_ErrorMsgforInvalidMonth,
        SIB_LBL_FILLINALLFIELDS,
        SIB_LBL_CARDEXPIRED,
        SIB_LBL_ENTERCARDNUMBER,
        SIB_LBL_COULDNOTRETRIEVECHECKOUT,
        SIB_LBL_COULDNOTRETRIEVECART,
        SIB_LBL_MICROFLEXCREATIONERROR,
        SIB_LBL_CARDINFORMATIONINCORRECT,
        SIB_LBL_CVVINVALID,
        SIB_LBL_COULDNOTVERIFYCARD,
        SIB_LBL_COULDNOTAUTHORIZECARD,
        SIB_LBL_COULDNOTCOMPLETEPAYMENT,
        SIB_LBL_PAYMENTSUCCESSFUL,
        SIB_LBL_PAYMENTAUTHSUCCESS,
        SIB_LBL_PROCESSINGPAYMENTPLEASEWAIT,
        SIB_LBL_SOMETHINGWENTWRONGPROCESSINGPAYMENT,
        SIB_LBL_FIRSTNAME,
        SIB_LBL_LASTNAME,
        SIB_LBL_STREETADDRESS,
        SIB_LBL_CITYLABEL,
        SIB_LBL_CITYPLACEHOLDER,
        SIB_LBL_COUNTRYLABEL,
        SIB_LBL_COUNTRYPLACEHOLDER,
        SIB_LBL_STATELABEL,
        SIB_LBL_STATEPLACEHOLDER,
        SIB_LBL_POSTALLABEL,
        SIB_LBL_POSTPLACEHOLDER,
        SIB_LBL_CARDNUMBERLABEL,
        SIB_LBL_CVVLABEL,
        SIB_LBL_CVVPLACEHOLDER,
        SIB_LBL_EXPIRYMONTHLABEL,
        SIB_LBL_EXPIRYMONTHPLACEHOLDER,
        SIB_LBL_EXPIRYYEARLABEL,
        SIB_LBL_EXPIRYYEARPLACEHOLDER,
        SIB_LBL_NEXTSTEPLABEL,
        SIB_LBL_PAYLABEL,
        SIB_LBL_PAYMENT,
        SIB_COUNTRIESREQUIRINGPOSTALCODE,
        SIB_COUNTRIESREQUIRINGSTATE,
        SIB_SAMEASBILLINGADDRESS,
        SIB_GROUPRECIPIENTSMISMATCH
    }
    
    /**
     * 
     * Get the CheckoutData from the standard salesforce adapter
     * Response is expected to be 202 while checkout is starting
     * Response will be 200 when checkout start is complete and we can being processing checkout data 
     */
    @wire(CheckoutInformationAdapter, {})
    checkoutInfo({ error, data }) {
        if (!this.isInSitePreview()) {
            
            if (data && (!this.isCheckoutInfoLoaded || !this.isShippingAddressLoaded)) {
                if(!this.isCheckoutInfoLoaded && !this.isShippingAddressLoaded) {
                    this.isLoading = true;
                } 
                this.checkoutId = data?.checkoutId;
                this.shippingAddress = data?.deliveryGroups?.items[0]?.deliveryAddress;
                
                if(this.shippingAddress && this.shippingAddress != undefined && this.shippingAddress != null) {
                    this.isShippingAddressLoaded = true;
                }
                // Assigning country and states as the states are not populating when the user clicks the "Same As Billing Address" checkbox.
                this.country = this.shippingAddress?.country;
                this.isCheckoutInfoLoaded = true;
                this.orderReferenceNumber = data?.orderReferenceNumber;
            } else if (error) {
                this.isLoading = false;

                this.showToastMessage(this.labels.SIB_LBL_COULDNOTRETRIEVECHECKOUT, 'error', 8000);
            }
        }else{
            this.isLoading = false;
            this.showToastMessage(this.labels.SIB_LBL_COULDNOTRETRIEVECHECKOUT, 'error', 8000);
        }
    }

    // retrieve the cart summary information
    @wire(CartSummaryAdapter, {})
    cartSummary({error, data}){
        if (!this.isInSitePreview()){
            
            if (data && !this.isCartInfoLoaded) {
                this.isLoading = true;
                this.cartSummary = data;
                if(data && data?.customFields && data?.customFields?.length >0) {
                    this.isGroupOrderCart = data?.customFields[0]?.IsGroupOrder__c;
                    this.isWaitlistedCart = data?.customFields[0]?.IsWaitlisted__c;
                }
                this.grandTotalAmount = data?.grandTotalAmount;
                this.isCartInfoLoaded = true;
            } else if (error) {
                this.isLoading = false;
                this.showToastMessage(this.labels.SIB_LBL_COULDNOTRETRIEVECART, 'error', 8000);
            }
        }else{
            this.isLoading = false;
            this.showToastMessage(this.labels.SIB_LBL_COULDNOTRETRIEVECART, 'error', 8000);
        }
    }

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
        if(this._countries != undefined) {
            for(i = 0; i < this._countries?.length; i++) {
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
        
        const validForNumberToCountry = Object.fromEntries(Object.entries(data?.controllerValues).map(([key, value]) => [value, key]));

        this._countryToStates = data?.values?.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForNumberToCountry[state?.validFor[0]];

            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
        }, {});
    }

    /** getters setters: begin */
    get cardImage() {
        let image = '';
        if(this.cardType && this.cardType != '') {
            let cardType = this.originalCardType != '' ? this.originalCardType.toLowerCase() :  this.cardType;
            
            image = this.images[cardType];
        }
        return image
    }

    get displayCardImage() {
        let displayImage = false;

        if(this.cardImage && this.cardImage != '') {
            displayImage = true;
        }
        return displayImage;
    }

    get displayStencil(){
        
        return this.isLoading ?  '' :'sib-display-content-none';
    }

    get displayContent() {
        
        return !this.isLoading ? '' : 'sib-display-content-none' ;
    }

    get showBillingAddress() {
        return !this.isSameAsBillingAddress;
    }

    
    get countries() {
        return this._countries;
    }

    get states() {
        return this._countryToStates[this.country] || [];
    }

    get showStateRequired(){
        if(this.country != null) {
            return this.states.length > 0 && this.countriesRequiringState?.includes(this.country);
        }
        return true;
    }

    get showZipCodeRequired() {
        if(this.country != null) {
            return this.countriesRequiringPostalCode?.includes(this.country);
        }
        return true;
    }

    get paymentIsReadOnly() {
        if(this.isPaymentReadOnly) {
            this.sendEvent({paymentReadOnly: true});
        }

        return this.isPaymentReadOnly;
    }

    get showCardErrors() {
        return this.errorMessages?.length > 0;
    }

    /**
     * The current checkout mode for this component
     *
     * @type {CheckoutMode}
     */
    get checkoutMode() {
    
        return this._checkoutMode;
    }

    /** getters setters: end */

    /** Lifecycle hooks: begin */
    async connectedCallback() {
        
        this.currentCommunityId = communityId;
        
        //set year options
        const currentYear = new Date().getFullYear();
        this.expYear = ''+currentYear;
        for (let i = 0; i < 15; i++) {
            const yearString = '' + (currentYear + i);
            this.yearOptions.push({ label: yearString, value: yearString });
        }

        //get effectiveaccountid
        getSessionContext().then(ctx => {    
            this.effectiveAccountId = ctx?.effectiveAccountId;
        }).catch(err => {
            
            this.isLoading = false;
        });

        await loadScript(this, microformScript)
        .then(() => {
            this.setupMicroform();
        }).catch(err => {
            
            this.isLoading = false;
        });

        // Split the custom label strings by comma and trim spaces to create arrays
        this.countriesRequiringPostalCode = this.labels.SIB_COUNTRIESREQUIRINGPOSTALCODE.split(',').map(country => country.trim());
        this.countriesRequiringState = this.labels.SIB_COUNTRIESREQUIRINGSTATE.split(',').map(country => country.trim());
    }
    /** Lifecycle hooks: end */

    //TTS:create the Cybersource microform and add the fields
    setupMicroform() {
        
        let microformStyle = {
            'input': {
                color: '#212529',
                'font-size': '16px',
            },
            'div' : {
                'padding' :'16px',
                'border-radius': '8px'
            }
        }
        
        generateKey({
            mapParams : this.mapParams
        }).then(result => {

            result = result.response;
            
            const flex = new Flex(result);
            const microform = flex.microform({
                styles: 
                    microformStyle
            });

            const number = microform.createField('number',{
                placeholder: this.labels.SIB_LBL_ENTERCARDNUMBER
            });
            const securityCode = microform.createField('securityCode', {
                placeholder: this.labels.SIB_LBL_CVVPLACEHOLDER,
                maxLength: 4
            });
            
            const numberElement = this.refs['ccNumber'] ;//Change VRa 17 Sep 2024
            const securityCodeElement = this.refs['cvvNumber'];

            number.load(numberElement);
            securityCode.load(securityCodeElement);

            //add event listeners
            number.on('change', (data) => this.handleCardNumberValueChange(data));
            securityCode.on('change', (data) => this.handleCvvChange(data));

            this.microform = microform;
            this.isLoading = false;
        })
        .catch(err => {
            
            this.isLoading = false;
            this.showToastMessage(this.labels.SIB_LBL_MICROFLEXCREATIONERROR,'error',5000);
        });
    }

    isCCAddressValid() {
        let isValid = this.street?.length > 0 && this.refs?.city?.length > 0 && this.refs?.state?.length > 0 && this.refs?.postalCode?.length > 0 
        return isValid;
    }

    stageAction(checkoutStage) {
        
        switch (checkoutStage) {
            case 'CHECK_VALIDITY_UPDATE':
                if(this.paymentRendered) {
                    this.isPaymentInformationCompleted = this.checkFieldValidity() && this.checkCardAndCvvValidity();
                    return Promise.resolve(this.isPaymentInformationCompleted);
                } else {
                    //Payment component Hidden, allow Place Order
                    return Promise.resolve(true);
                }
                
            case 'REPORT_VALIDITY_SAVE':

                if(this.paymentRendered) {

                    return Promise.resolve(this.reportValidity());
                } else {

                    //Payment component Hidden, allow Place Order
                    return Promise.resolve(true);
                }
                
            case 'BEFORE_PAYMENT':
                if(this.paymentRendered) {

                    return Promise.resolve(this.checkCardValidityAndGetToken());
                } else {

                     //Payment component Hidden, allow Place Order
                    return Promise.resolve(true);
                }
                
            case 'PAYMENT':
                if(this.paymentRendered) {

                    return Promise.resolve(this.captureAuthorization());
                } else {
                    
                    //Payment component Hidden, allow Place Order
                    return Promise.resolve(true)
                }
                
            default:
                return Promise.resolve(true);
        }
    }

    /**
     * Determines if you are in the experience builder currently
     */
    isInSitePreview() {
        let url = document.URL;
        return (
        url.indexOf('sitepreview') > 0 ||
        url.indexOf('livepreview') > 0 ||
        url.indexOf('live-preview') > 0 ||
        url.indexOf('live.') > 0 ||
        url.indexOf('.builder.') > 0
        );
    }

    //VRa: Check payment form information
    reportValidity() {
        let isValid = true;

        if( !(this.isPaymentInformationCompleted && !this.isPaymentComplete) ){
            this.showToastMessage(this.labels.SIB_LBL_FILLINALLFIELDS,'error',5000);
            isValid = false;
        }

        return isValid;
    }


    //TTS: state change handler
    handleStateChange(event) {
        this.state = event?.target?.value;

        if(event?.target?.value && (event?.target?.value == '' || event?.target?.value == null || event?.target?.value == undefined)){
            this.refs?.state?.classList.add(this.stylingConstants.errorTextField);
        } else {
            if(this.refs?.state?.classList.contains(this.stylingConstants.errorTextField)){
                this.refs?.state?.classList.remove(this.stylingConstants.errorTextField);
            }
        }
    }

    //TTS: country change handler
    handleCountryChange(event){
        event.preventDefault();
        this.country = event?.target?.value;

        if(event?.target?.value && (event?.target?.value == '' || event?.target?.value == null || event?.target?.value == undefined)){
            this.refs?.country?.classList.add(this.stylingConstants.errorTextField);
        } else {
            if(this.refs?.country?.classList.contains(this.stylingConstants.errorTextField)){
                this.refs?.country?.classList.remove(this.stylingConstants.errorTextField);
            }
        }
        
    }
    //state country picklist end

    //TTS: Same as Billing Address change handler
    handleIsSameAsBillingAddress(evt) {
        this.isSameAsBillingAddress = !this.isSameAsBillingAddress;
    }

    //TTS: custom changes Sep 17 24: begin
    async handleCvvChange(data) {

        this.isCvvValid = data ? data?.valid : false;
        await this.checkMicroformStyling('cvvNumber')
    }

    //TTS: microform card change handler
    async handleCardNumberValueChange(data){

        this.isCardNumberValid = data ? data?.valid : false;

        await this.checkMicroformStyling('ccNumber');
        
        if((data && !data?.empty && data?.couldBeValid)) {
            this.isCardNumberValid = data?.valid ;
            if(data?.card && data?.card?.length > 0) {
                this.cardType = data?.card[0]?.name;
                
                if(this.cardType == 'discover'){
                    this.cardType = 'visa';
                    this.originalCardType = 'Discover';
                } else {
                    this.originalCardType = '';
                }
            }
        } else {
            this.cardType = '';
        }
    }

    //TTS: check styling for microform when validating
    checkMicroformStyling(fieldName){
        if(!this.isCardNumberValid) {
            this.refs[fieldName]?.classList?.add(this.stylingConstants.errorTextField);
            return Promise.resolve(true);
        } else {
            if(this.refs[fieldName]?.classList?.contains(this.stylingConstants.errorTextField)) {
                this.refs[fieldName]?.classList?.remove(this.stylingConstants.errorTextField);
            }
            return Promise.resolve(true);
        }
    }

    //TTS: validate all fields in form
    validateFields(){
        let isAllFieldsValid = true;

        for(const[key,field] of Object.entries(this.refs)){

            if(field && (field.value == '' || field == undefined || field == null)) {
                isAllFieldsValid = false;
                
                field?.classList?.add(this.stylingConstants.errorTextField);
            } else {
                if(field?.classList?.contains(this.stylingConstants.errorTextField)){
                    field?.classList?.remove(this.stylingConstants.errorTextField);
                }
            }
        }
        
        if(!isAllFieldsValid) {
            this.showToastMessage(this.labels.SIB_LBL_FILLINALLFIELDS, 'error', 10000);
        } 

        return isAllFieldsValid;
    }


    //TTS: create token 
    async checkCardValidityAndGetToken() {
        let mapParams = {
            CartId: this.cartSummary?.cartId,
            isOrderForSomeoneElse: getCookie("isOrderForSomeoneElse")
        };
        const result = await updateCheckOutCartStatus({ 'mapParams': mapParams });
        if(result && result.isGroupRecipientsMatch){
            let calloutResult = {success: false, token: ''};
            const selectedYear = this.refs['year']?.value;
            const selectedMonth = this.refs['month']?.value;
    
            const currentDate = new Date();
            const currentYear = currentDate.getFullYear();
            const currentMonth = currentDate.getMonth() + 1;
    
            let currentContext = this;
    
            if(Math.round(selectedYear) > currentYear || (Math.round(selectedYear) === currentYear && Math.round(selectedMonth) > currentMonth)) {
                return new Promise((resolve, reject) => {
                    this.microform.createToken({expirationMonth: selectedMonth, expirationYear: selectedYear}, function(err, token) {
                        if(err){
                            calloutResult.success = false;
                            if (err?.details && err?.details?.length > 0) {
    
                                for (let i=0; i < err?.details?.length; i++) {
                                    if (err?.details[i]?.message == 'Validation error' && err?.details[i]?.location == 'number') {
    
                                        currentContext?.showToastMessage(this.labels.SIB_LBL_CARDINFORMATIONINCORRECT, 'error', 8000);
                                    } else if (err?.details[i]?.message == 'Validation error' && err?.details[i]?.location == 'securityCode') {
    
                                        currentContext?.showToastMessage(this.labels.SIB_LBL_CVVINVALID, 'error', 8000);
                                    } else {
                                        currentContext?.showToastMessage(this.labels.SIB_LBL_CARDINFORMATIONINCORRECT, 'error', 8000);
                                    }
                                }
                            } else {
    
                                currentContext?.showToastMessage(err?.message, 'error', 8000);
                                resolve(calloutResult);
                            }
    
                            resolve(calloutResult);
                        } else {
    
                            calloutResult.success = true; calloutResult.token = token;
                            currentContext.transientToken = token;
                            resolve(calloutResult);
                        }
                    });
                } )
            } else {
                this.showToastMessage(this.labels.SIB_LBL_CARDEXPIRED, 'error', 8000);
                return await Promise.resolve(false);
            }
        } else {
            this.showToastMessage(this.labels.SIB_GROUPRECIPIENTSMISMATCH, 'error', 8000);
            return await Promise.resolve(false);
        }
    }

    //TTS: request auth for payment
    async captureAuthorization(){
        this.isShowSpinner = true;
        this.processingPaymentMessage = this.labels.SIB_LBL_PROCESSINGPAYMENTPLEASEWAIT;

        let paymentResponse = {
            success: false,
            captureResponse : {}
        };

        let billingAddress = {
            "name": this.refs['firstName']?.value + ' ' + this.refs['lastName']?.value,
            "street": '',
            "city": '',
            "region": '',
            "country": '',
            "postalCode": ''
        };

        if (this.isSameAsBillingAddress) {
            billingAddress.street = this.shippingAddress?.street;
            billingAddress.city = this.shippingAddress?.city;
            billingAddress.region = this.shippingAddress?.region;
            billingAddress.country = this.shippingAddress?.country;
            billingAddress.postalCode = this.shippingAddress?.postalCode;
        } else {
            billingAddress.street = this.refs['street']?.value;
            billingAddress.city = this.refs['city']?.value;
            billingAddress.region = this.refs['state']?.value;
            billingAddress.country = this.refs['country']?.value;
            billingAddress.postalCode = this.refs['postalCode']?.value;
        }

        const paymentData = {
            token: this.transientToken, 
            createToken: true,
            accountId: this.effectiveAccountId, 
            cartId: this.cartSummary?.cartId,
            currencyISOCode: this.cartSummary?.currencyIsoCode, 
            addressString: JSON.stringify(billingAddress), 
            expirationMonth: this.refs['month']?.value, 
            expirationYear: this.refs['year']?.value, 
            firstName: this.refs['firstName']?.value, 
            lastName: this.refs['lastName']?.value, 
            communityId: this.currentCommunityId,
            amount: this.grandTotalAmount,
            grouporder: this.isGroupOrderCart,
            waitlisted: this.isWaitlistedCart,
            cardType: this.cardType,
            orderReferenceNumber: this.orderReferenceNumber
        };

        try{
            let result = await authorizeCard({paymentsData: paymentData});

            if(result && result?.isSuccess ) {
                paymentResponse.success = result?.isSuccess;
                let authResponse = result?.authResponse;

                if(authResponse && authResponse?.paymentAuthorization && authResponse?.gatewayResponse?.salesforceResultCode == 'Success') {
                    this.authorizationId = authResponse?.paymentAuthorization?.id; 
                    
                    //return the cart update and auth capture method response
                    if(this.authorizationId) {

                        try {

                            paymentResponse.authResponse =  await this.updateAuthorizationOnCart(this.authorizationId);
                        }catch(error){
                            //for any error revert the authorization
                            paymentResponse.success = false;
                            await revertAuthorization({requestMap: {paymentAuthorizationId: this.authorizationId, cartId: this.cartSummary?.cartId, orderReferenceNumber: this.orderReferenceNumber}});
                        }

                        let captureResponse;
                        if(paymentResponse?.authResponse && paymentResponse?.authResponse?.success && !this.isWaitlistedCart) {
                            captureResponse = await this.capturePaymentFromAuthId(this.authorizationId);
                            
                            if(captureResponse) {
                                paymentResponse.success = true;
                                this.showToastMessage(this.labels.SIB_LBL_PAYMENTSUCCESSFUL, 'success', 100);
                            } else {
                                //await revertAuthorization({requestMap: {paymentAuthorizationId: this.authorizationId, cartId: this.cartSummary?.cartId}});
                                paymentResponse.success = false;
                                this.showToastMessage(this.labels.SIB_LBL_COULDNOTCOMPLETEPAYMENT, 'error', 7000);
                            }
                        } 
                    } else {

                        this.showToastMessage(this.labels.SIB_LBL_COULDNOTAUTHORIZECARD, 'error', 20000);
                        this.isShowSpinner = false;
                        paymentResponse.success = false;
                    }
                }
            } else {
                this.isShowSpinner = false;
                this.showToastMessage(this.labels.SIB_LBL_COULDNOTAUTHORIZECARD, 'error', 20000);
                paymentResponse.success = false;
            }
        } catch(error){
            this.isShowSpinner = false;
            this.showToastMessage(this.labels.SIB_LBL_COULDNOTAUTHORIZECARD, 'error', 20000);
            paymentResponse.success = false;
        };

        return Promise.resolve(paymentResponse.success);
    }

    //TTS: update the paymentmethodId and paymentGroupId on the current cart
    async updateAuthorizationOnCart(authorizationId){
        
        let updateCartResult = {
            success: false,
            authorizationId : authorizationId,
            message: '',
            paymentCaptureResponse: {},
            isWaitlistedCart : this.isWaitlistedCart
        }
        
        if( this.cartSummary?.cartId) {

            let result = await updatePaymentMethodOnCart({ requestMap: {cartId: this.cartSummary?.cartId, 
                authorizationId: authorizationId, originalCardType: this.originalCardType}
            });
            
            //capture payment only if the items on cart is not waitlisted
            if(result && result?.isSuccess && result?.updatedCart && !result?.updatedCart?.IsWaitlisted__c) { 

                this.isWaitlistedCart  = result?.updatedCart?.IsWaitlisted__c;
                updateCartResult.success = true;
                updateCartResult.message = this.labels.SIB_LBL_PAYMENTSUCCESSFUL
                
                return Promise.resolve(updateCartResult);
            } else if( result && result?.isSuccess && result?.updatedCart?.IsWaitlisted__c) {

                this.isWaitlistedCart  = result?.updatedCart?.IsWaitlisted__c;
                this.showToastMessage(this.labels.SIB_LBL_PAYMENTAUTHSUCCESS, 'success', 80000);
                updateCartResult.success = true;
                this.sendEvent({isPaymentReadOnly: true});
                return Promise.resolve(updateCartResult);
            }else {
                this.isShowSpinner = false;
                this.showToastMessage(result?.msg, 'error', 80000);
            }

        } else {
            this.isShowSpinner = false;
            this.showToastMessage(this.labels.SIB_LBL_PAYMENTAUTHSUCCESS, 'success', 80000);
            return Promise.resolve(updateCartResult);
        }

        return Promise.resolve(updateCartResult);
    }

    async capturePaymentFromAuthId(authorizationId) {
        let isCapturePaymentSuccess = false;
        
        try{

            await capturePaymentAuthorization(
                {requestMap : {
                        paymentAuthorizationId : authorizationId,
                        cartId: this.cartSummary?.cartId,
                        orderReferenceNumber: this.orderReferenceNumber
                    }
                }).then(result => {
                    
                    if(result && result.isSuccess) {
                        this.isShowSpinner = false;
                        this.showToastMessage(this.labels.SIB_LBL_PAYMENTSUCCESSFUL, 'success', 20000);
                        isCapturePaymentSuccess = true;
                        this.sendEvent({isPaymentReadOnly: true});
                    } else {
                        this.isShowSpinner = false;
                        revertAuthorization({requestMap: {paymentAuthorizationId: this.authorizationId, cartId: this.cartSummary?.cartId, orderReferenceNumber: this.orderReferenceNumber}});
                        this.showToastMessage(this.labels.SIB_LBL_COULDNOTCOMPLETEPAYMENT, 'error', 20000);
                        isCapturePaymentSuccess = false;
                    }
                });
        }catch(error) {
            this.showToastMessage(this.labels.SIB_LBL_COULDNOTCOMPLETEPAYMENT, 'error', 20000);
            await revertAuthorization({requestMap: {paymentAuthorizationId: this.authorizationId, cartId: this.cartSummary?.cartId, orderReferenceNumber: this.orderReferenceNumber}});
            isCapturePaymentSuccess = false
        }
        

        return await Promise.resolve(isCapturePaymentSuccess);
    }

    //TTS: check for vard and CVV validity
    checkCardAndCvvValidity() {
        let isValid = true;

        let expMonth = this.refs?.month?.value;
        let expYear = this.refs?.year?.value;

        if(!this.isCardNumberValid) {
            this.showToastMessage(this.labels.SIB_LBL_CARDINFORMATIONINCORRECT, 'error', 5000);
            isValid = false;
            return isValid;
        } else if(isValid && !this.isCvvValid) {
            this.showToastMessage(this.labels.SIB_LBL_CVVINVALID, 'error', 5000);
            isValid = false;
            return isValid;
        } else if(isValid && !expMonth) {
            this.showToastMessage(this.labels.SIB_ErrorMsgforInvalidMonth, 'error', 20000);
            isValid = false;
            return isValid;
        } else if(isValid && !expYear) {
            this.showToastMessage(this.labels.SIB_ErrorMsgforInvalidYear, 'error', 20000);
            isValid = false;
            return isValid;
        }

        if(expMonth && expYear) {
            const currentDate = new Date();
            const currentYear = currentDate?.getFullYear();
            const currentMonth = currentDate?.getMonth() + 1;

            if(expYear < currentYear || (expYear === currentYear && expMonth < currentMonth)){

                this.refs?.month?.classList?.add(this.stylingConstants.errorTextField);
                this.refs?.year?.classList?.add(this.stylingConstants.errorTextField);

                this.showToastMessage(this.labels.SIB_LBL_CARDEXPIRED, 'error', 8000);
                isValid = false;
            } 
        }
        return isValid;
    }
    
    showToastMessage(message, type, duration) {

        try {

            duration = duration && duration > 5000 ? duration : 6000;
            let field = this.querySelector('c-sib-show-toast-message');
            field.showToast(message,type,duration);
        }catch(error) {
            
        }
        
    }

    handleFieldBlur(event) {
        const fieldName = event?.currentTarget?.dataset?.id;
        
        let currentField = this.refs[fieldName];
        
        if(currentField && (fieldName != 'state' && currentField?.value == '' || currentField?.value == null || currentField?.value == undefined)) {
            currentField?.classList?.add(this.stylingConstants.errorTextField);
        } else {
            event.target.value = currentField?.value;
            if(fieldName == 'firstName' || fieldName == 'lastName' || fieldName == 'postalCode'){
                event.target.value = event.target.value.replaceAll(/[^A-Za-zÀ-ÿ0-9]/g, '');
                currentField.value = event.target.value;
            } 
            if(currentField?.classList?.contains(this.stylingConstants.errorTextField)) {
                currentField?.classList?.remove(this.stylingConstants.errorTextField);
            }
        }

    }

    //TTS: check field validity
    checkFieldValidity(){

        let isValid = true;
        let fieldsToValidate = ['firstName', 'lastName', 'street', 'city'];

        //check other fields for validity
        fieldsToValidate?.forEach(fieldName => {
            let field = this.refs[fieldName];
            
            if(field && (field?.value == '' || field?.value == undefined || field?.value == null)){
                
                field?.classList?.add(this.stylingConstants.errorTextField);
                isValid = false;
                
            }
        });

        // Get country, state, postalcode field reference
        let countryField = this.refs['country'];
        let stateField = this.refs['state'];
        let postalCodeField = this.refs['postalCode'];

        if(countryField && (countryField?.value == '' || countryField?.value == undefined || countryField?.value == null)){
            countryField?.classList?.add(this.stylingConstants.errorTextField);
            stateField?.classList?.add(this.stylingConstants.errorTextField);
            postalCodeField?.classList?.add(this.stylingConstants.errorTextField);
            isValid = false;
        } else {
            stateField?.classList?.remove(this.stylingConstants.errorTextField);
            postalCodeField?.classList?.remove(this.stylingConstants.errorTextField);
        }

        if(this.countriesRequiringState.includes(countryField?.value) && stateField && (stateField?.value == '' || stateField?.value == undefined || stateField?.value == null)) {
            stateField?.classList?.add(this.stylingConstants.errorTextField);
            isValid = false;
        }

        if(this.countriesRequiringPostalCode.includes(countryField?.value) && postalCodeField && (postalCodeField?.value == '' || postalCodeField?.value == undefined || postalCodeField?.value == null)) {
            postalCodeField?.classList?.add(this.stylingConstants.errorTextField);
            isValid = false;
        }

        if(!isValid){
            this.showToastMessage(this.labels.SIB_LBL_FILLINALLFIELDS, 'error', 8000);
            return isValid;
        }
        

        return isValid;
    }

    //TTS: send payment success message to container
    sendEvent(data) {

        const customEvent = new CustomEvent('paymentsuccess', {
            detail : data
        });

        this.dispatchEvent(customEvent);
    }

}