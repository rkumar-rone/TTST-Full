import { LightningElement, api, wire } from 'lwc';
import { subscribe, publish, MessageContext, unsubscribe } from 'lightning/messageService';
import CHECKOUT_STATE_MESSAGE_CHANNEL from '@salesforce/messageChannel/sibMultiStepCheckoutMessages__c';

//apex
import getAccountInformation from '@salesforce/apex/SIB_CybersourceController.getAccountInformation';
import getPaymentModule from '@salesforce/apex/SIB_CybersourceController.getPaymentModule';
import getCartPaymentStatus from '@salesforce/apex/SIB_CybersourceController.getCartPaymentStatus';

//labels
import SIB_LBL_PURCHASEORDER from '@salesforce/label/c.SIB_PurchaseOrder';
import SIB_LBL_CREDITCARD from '@salesforce/label/c.SIB_CreditCard';
import SIB_LBL_PAYMENT from '@salesforce/label/c.SIB_Payment';
import SIB_LBL_GENERICEXCEPTION from '@salesforce/label/c.SIB_GenericExceptionMessage';

import { refreshApex } from '@salesforce/apex';
import { CartItemsAdapter, CartSummaryAdapter  } from "commerce/cartApi";
import {CheckoutInformationAdapter} from "commerce/checkoutApi";
const MINIMUM_AMT_CONFIG_LABEL = 'DoNotInvoiceMinimumTotal';
import { getCookie } from "c/sibUtils";


export default class SibPaymentContainer extends LightningElement {
    static renderMode = "light"; // the default is 'shadow'
    @api checkoutConfig;
    @api checkoutDetails;
    
    isCreditCardSelected = true;
    isPurchaseOrderSelected =  false;
    isSkeletonLoading = false;
    isAccountDoNotInvoice = true;
    isCartItemDataLoaded = false;
    isCartSummaryDataLoaded = false;
    isAccountInformationLoaded = false;
    isConfigDataLoaded = false;
    isPaymentStampedOnCart = false;
    isPaymentRendered = true;
    isDoNotRenderCardOption = true;
    isCheckoutInfoLoaded = false;
    isRenderPaymentInformation = false;
    showPurchaseOrderScreen = false;
    paymentReadOnly = true;
    showAvailablePaymentOption = true;
    showPoOption = false;

    //text
    effectiveAccountId = '';
    checkoutId = '';
    paymentGroupId = '';
    paymentMethodId = '';

    //int
    minimumInvoiceValue = 0;

    //float
    currentGrandTotalAmount = 0.0;

    //objects 
    cartItems = {};
    cartSummary = {};

    //subscribe to message channel
    subscription = null;
    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            CHECKOUT_STATE_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    //labels
    labels = {
        SIB_LBL_PURCHASEORDER,  
        SIB_LBL_CREDITCARD,
        SIB_LBL_PAYMENT,
        SIB_LBL_GENERICEXCEPTION
    }

    //wired methods : begin
    @wire(CartItemsAdapter)
    setCartItems({ data, error }) {
        if (data && data?.cartItems && data?.cartItems?.length > 0 && !this.isBuilder && !this.isCartItemDataLoaded) {
            this.isCartItemDataLoaded = true;
            this.cartItems = data?.cartItems;
            this.checkPaymentMethodToDisplay(this.cartItems);

        } else if (error) {
            this.showToastMessage(this.labels.SIB_LBL_GENERICEXCEPTION, 'error', 20000);
        }
    }

    @wire(CartSummaryAdapter)
    setCartSummary({data, error}) {
        if(data && data?.cartId && !this.isBuilder && !this.isCartSummaryDataLoaded) {
            this.isCartSummaryDataLoaded = true;
            this.effectiveAccountId = data?.accountId;
            this.cartSummary = data;
this.currentGrandTotalAmount = this.cartSummary?.grandTotalAmount;
            this.fetchAccountInformation();
            this.checkPaymentStatus(this.cartSummary?.cartId);
            
        } else if(error){
            this.showToastMessage(this.labels.SIB_LBL_GENERICEXCEPTION, 'error', 20000);
        }
    }

    @wire(getPaymentModule, { mapParams: {'moduleName': 'Payment'}})
    getConfigurationValue({data, error}) {

        if(data && data?.isSuccess && data?.configs && !this.isConfigDataLoaded) {
            this.minimumInvoiceValue = data?.configs[MINIMUM_AMT_CONFIG_LABEL];
            this.isConfigDataLoaded = true;
        } else if(error){
            this.showToastMessage(this.labels.SIB_LBL_GENERICEXCEPTION, 'error', 20000);
        }
    }

    @wire(CheckoutInformationAdapter, {})
    checkoutInfo({ error, data }) {
        
        if (data && !this.isCheckoutInfoLoaded) {
            this.checkoutId = data?.checkoutId;
            this.isCheckoutInfoLoaded = true;
        } else if (error) {
            this.showToastMessage(this.labels.SIB_LBL_GENERICEXCEPTION, 'error', 20000);
        }

    }


    handleMessage(message) {
        if(message?.nextState === 'payment') {
            this.paymentReadOnly = false;
        }else {
            this.paymentReadOnly = true;
        }

        if(message?.forceCartRefresh) {
            this.refreshWiredMethods();
        }
    }

    refreshWiredMethods() {
        
        getCartPaymentStatus({requestMap: {cartId : this.cartSummary?.cartId}}).then( result => {
            
            if(result && result?.isSuccess && result?.responseData) {
                this.currentGrandTotalAmount = parseFloat(result?.responseData?.GrandTotalAmount);
            }
        });
        refreshApex(this.cartSummary);
    }

    get isBuilder(){
        const loc = window.location.href;
        let isBuilder = false;
        if(loc.includes('comm') || loc.includes('preview')){
            isBuilder = true;
        }
        
        return isBuilder;
    }

    get checkForFreeCourses() {
        
        return this.currentGrandTotalAmount != null && this.currentGrandTotalAmount == 0.00;
    }

    get showCreditCardOption(){
        var tempCongif = this.checkoutConfig;
        var paymentOptions = tempCongif?.availablePaymentMethods;
        if( tempCongif && paymentOptions != undefined && paymentOptions?.includes('cc') ){
            return true;
        }else{
            return false;
        }
    }

    get showPurchaseOrderOption(){
        var tempCongif = this.checkoutConfig;
        var paymentOptions = tempCongif?.availablePaymentMethods;
        if( tempCongif && paymentOptions != undefined && paymentOptions?.includes('po') ){
            return true;
        }else{
            return false;
        }
    }

    get showCybersource(){
        var tempCongif = this.checkoutConfig;
        var paymentOptions = tempCongif?.availablePaymentMethods;
        if( tempCongif && paymentOptions != undefined && paymentOptions?.includes('cc') && tempCongif.creditCardGateway == 'Cybersource' ){
            return true;
        }else{
            return false;
        }
    }

    get showPurchaseOrder(){
        var tempCongif = this.checkoutConfig;
        var paymentOptions = tempCongif?.availablePaymentMethods;
        if( tempCongif && paymentOptions != undefined && paymentOptions?.includes('po')){
            return true;
        }else{
            return false;
        }
    }

    get isDisplayPurchaseOrder() {
        return (this.isAccountDoNotInvoice && this.cartSummary?.grandTotalAmount < this.minimumInvoiceValue) ? false : this.showPoOption;
    }

    get isPaymentComponentHidden() {
        let stylingClass = 'sib-component-hidden';
        this.isRenderPaymentInformation = false;
        //if(!this.isPaymentStampedOnCart && !this.checkForFreeCourses) {//VRa 29,Oct 2024- removing component as multiple scenarios would need to be handled if this is rendered
        if(!this.checkForFreeCourses) {
            stylingClass = '';
            this.isPaymentRendered = true;
            this.isDoNotRenderCardOption = false;
        // } //VRa 29,Oct 2024- removing component as multiple scenarios would need to be handled if this is rendered
        // else if(this.isPaymentStampedOnCart && !this.checkForFreeCourses) {
        //     stylingClass = '';
        //     this.isDoNotRenderCardOption = true;
        //     this.isRenderPaymentInformation = true;
        } else {
            this.isDoNotRenderCardOption = true;
            this.isPaymentRendered = false;
        }
        return stylingClass;
    }

    checkPaymentMethodToDisplay(cartItems){

        let today = new Date();
        const formattedDate = (new Date(today.setDate(today.getDate() + 14))).toISOString().split('T')[0].replace(/-/g, ' ');
        const formattedTime = new Date(formattedDate).getTime();
        
        cartItems.forEach(cartItem => {
            if(cartItem?.cartItem?.productDetails?.fields?.Product_Group__c && cartItem?.cartItem?.productDetails?.fields?.Start_Date__c &&
                cartItem?.cartItem?.productDetails?.fields?.Product_Group__c == 'Public Course') {
                    let cartItemDate = new Date(cartItem?.cartItem?.productDetails?.fields?.Start_Date__c);
                    const cartItemFormattedDate = cartItemDate.toISOString().split('T')[0].replace(/-/g, ' ');
                    const cartItemFormattedTime = new Date(cartItemFormattedDate).getTime();

                    if(cartItemFormattedTime >= formattedTime) {
                        this.showPoOption = true;
                    }
                
            }
        })
    }

    handleIsCreditCardSelected(evt){
        if(!this.isCreditCardSelected){
            this.isCreditCardSelected = !this.isCreditCardSelected;
            if(this.isPurchaseOrderSelected){
                this.isPurchaseOrderSelected = !this.isPurchaseOrderSelected;
            }
            this.showAvailablePaymentOption =  true;
            if(this.showPurchaseOrderScreen){
                this.showPurchaseOrderScreen = !this.showPurchaseOrderScreen;
            }
        }
    }

    handleIsPurchaseOrderSelected(evt){
        if(!this.isPurchaseOrderSelected){
            this.isPurchaseOrderSelected = !this.isPurchaseOrderSelected;
            if(this.isCreditCardSelected){
                this.isCreditCardSelected = !this.isCreditCardSelected;
            }
            this.showPurchaseOrderScreen = true;
            if(this.showAvailablePaymentOption){
                this.showAvailablePaymentOption = !this.showAvailablePaymentOption;
            }
        }
    }

    savePaymentDetails(event) {
        this.paymentReadOnly = true;
        this.publishCheckoutState('payment');
    }

    publishCheckoutState(nextState) {
        const payload = { 
            nextState: nextState,
        };
        publish(this.messageContext, CHECKOUT_STATE_MESSAGE_CHANNEL, payload);
    }

    get showNextButton() {
        if(this.isOnePageLayout() || this.paymentReadOnly) {
            return false;
        }
        return true;
    }

    isOnePageLayout() {
        if(this.checkoutConfig && this.checkoutConfig.displayLayout == 'OnePage') {
            return true;
        }
        return false;
    }

    connectedCallback() {
        
        if(this.isOnePageLayout()) {
            this.paymentReadOnly = false;
        }else {
            this.subscribeToMessageChannel();
        }

        let checkoutStage = getCookie("checkoutStage");
        if(checkoutStage && checkoutStage === 'payment') {
            this.paymentReadOnly = false;
        } else {
            this.paymentReadOnly = true;
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        if(!this.isOnePageLayout()) {
            this.unsubscribeToMessageChannel();
        }
    }

    fetchAccountInformation(){

        getAccountInformation({
            requestMap: {
                effectiveAccountId: this.effectiveAccountId
            }
        }).then(result => {

            if(result && result?.isSuccess && result?.fetchedAccount) {
                
                this.isAccountDoNotInvoice = result?.fetchedAccount?.Do_Not_Invoice__c;
            }
        }).catch(err => {
        })
    }

    checkPaymentStatus(cartId) {

        getCartPaymentStatus({requestMap: {cartId : cartId}}).then(result => {

            if(result && result?.isSuccess && result?.paymentStampedOnCart){
                let cart = result?.responseData;
                
                if(cart && cart?.PaymentMethodId && cart?.PaymentGroupId) {
                    this.paymentMethodId = cart?.PaymentMethodId;
                    this.paymentGroupId = cart?.PaymentGroupId;
                }
                
                this.paymentReadOnly = true;
                this.isPaymentStampedOnCart = true;
            }
        }).catch(err => {

        })

    }

    handleAuthReversal(event) {
    
        this.isPaymentStampedOnCart = false;
        this.isPaymentRendered = true;
        this.isDoNotRenderCardOption = false;
        this.isRenderPaymentInformation = false;
    
    }

    handlePaymentSuccess(event) {
        if(event?.detail &&  event?.detail?.isPaymentReadOnly) {
            this.paymentReadOnly = true;
        }
    }

    showToastMessage(message, type, duration) {
        duration = duration > 6000 ? duration : 6000;
        this.querySelector('c-sib-show-toast-message').showToast(message, type, duration);
    }
}