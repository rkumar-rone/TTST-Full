import { LightningElement, api, wire } from 'lwc';
import { subscribe, publish, MessageContext, unsubscribe } from 'lightning/messageService';
import { CartSummaryAdapter } from "commerce/cartApi"; //GArora - 17 Sep 2024
import CHECKOUT_STATE_MESSAGE_CHANNEL from '@salesforce/messageChannel/sibMultiStepCheckoutMessages__c';
import getCheckoutConfiguration from '@salesforce/apex/SIB_CheckoutController.getCheckoutConfiguration';
import { setCookie, getCookie } from "c/sibUtils";

/**
 * @slot onePagePlaceOrderBtn ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "onePagePlaceOrderBtn", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot multiStepPlaceOrderBtn ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "multiStepPlaceOrderBtn", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot questCheckout ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "multiStepPlaceOrderBtn", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
*/
export default class SibCheckoutContainer extends LightningElement {

    static renderMode = "light"; // the default is 'shadow'
    @api checkoutDetails;
    @api cartId;
    checkoutConfig;
    userHadNoCart = false;

    cartDetails;
    checkoutStage;//groupOrder;billing;payment

    //GArora - 17 Sep 2024 - to prevent calling in multiple child components
    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data && !this.isInSitePreview()) {
            this.cartDetails = data
        } else if (error) {
            this.userHadNoCart = true;
            console.error(error);
        }
    }

    mapParams = {
        configType : 'CHECKOUT'
    };

    @wire(getCheckoutConfiguration, {mapParams : '$mapParams' })
    wiredCheckoutConfig({ error, data }) {
        if (data) {
            this.checkoutConfig = data.checkoutConfig;
        } else if (error) {
            console.log(error);
            
        }
    };

    /**
     * Determines if you are in the experience builder currently
     */
    isInSitePreview() {
        let url = document.URL;

        return (
        url.indexOf("sitepreview") > 0 ||
        url.indexOf("livepreview") > 0 ||
        url.indexOf("live-preview") > 0 ||
        url.indexOf("live.") > 0 ||
        url.indexOf(".builder.") > 0
        );
    }

    get isConfigLoaded() {
        return this.checkoutConfig != null;
    }

    get showOnePageLayout(){
        var checkoutConfig = this.checkoutConfig;
        if(checkoutConfig && checkoutConfig.displayLayout == 'OnePage'){
            return true;
        }
        return false;
    }

    get showMultiPageLayout(){
        var checkoutConfig = this.checkoutConfig;
        if(checkoutConfig && checkoutConfig.displayLayout == 'MultiStep'){
            return true;
        }
        return false;
    }

    get showPlaceOrder() {
        return this.isInSitePreview() ? true : this._showPlaceOrder;
    };

    set showPlaceOrder(value) {
        this._showPlaceOrder = value;
    }

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
    
    handleMessage(message) {
        if(message && message?.nextState) {
            setCookie("checkoutStage", message?.nextState, 1);
            if(message?.nextState === 'payment') {
                this.showPlaceOrder = true;
            }else {
                this.showPlaceOrder = false;
            }
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    connectedCallback() {
        this.subscribeToMessageChannel(); 
        this.checkoutStage = getCookie("checkoutStage");
        if(this.checkoutStage && this.checkoutStage === 'payment') {
            this.showPlaceOrder = true;
        }
        if(!this.checkoutStage) {
            setCookie("checkoutStage", 'groupOrders', 1);
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
        setCookie("checkoutStage", 'groupOrders', 1);
    }

    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }

    _showPlaceOrder;
}