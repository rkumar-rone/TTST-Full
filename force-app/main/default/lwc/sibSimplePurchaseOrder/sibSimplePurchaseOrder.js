import { wire, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { CheckoutInformationAdapter, simplePurchaseOrderPayment, CheckoutComponentBase } from "commerce/checkoutApi";
import { refreshCartSummary } from "commerce/cartApi";
import updateCheckOutCartStatus from '@salesforce/apex/SIB_CartController.updateCheckOutCartStatus';
import SIB_GROUPRECIPIENTSMISMATCH from '@salesforce/label/c.SIB_GroupRecipientsMismatch';
import {getCookie} from "c/sibUtils";


const CheckoutStage = {
    CHECK_VALIDITY_UPDATE: 'CHECK_VALIDITY_UPDATE',
    REPORT_VALIDITY_SAVE: 'REPORT_VALIDITY_SAVE',
    BEFORE_PAYMENT: 'BEFORE_PAYMENT',
    PAYMENT: 'PAYMENT',
    BEFORE_PLACE_ORDER: 'BEFORE_PLACE_ORDER',
    PLACE_ORDER: 'PLACE_ORDER'
};

export default class SibSimplePurchaseOrder extends NavigationMixin(CheckoutComponentBase){

    static renderMode = "light"; // the default is 'shadow'
    isLoading = false;
    @api paymentConfig;
    @api isFreeCourse;

    @track checkoutId;
    @track shippingAddress;
    @track showError = false;
    @track error;
    cartId;

    labels = {
        SIB_GROUPRECIPIENTSMISMATCH
    }

    /**
     * 
     * Get the CheckoutData from the standard salesforce adapter
     * Response is expected to be 202 while checkout is starting
     * Response will be 200 when checkout start is complete and we can being processing checkout data 
     * 
     */
    @wire(CheckoutInformationAdapter, {})
    checkoutInfo({ error, data }) {
        this.isPreview = this.isInSitePreview();
            if (!this.isPreview) {
                this.isLoading = true;
                if (data) {
                    this.checkoutId = data.checkoutId;
                    this.cartId = data.cartSummary.cartId;
                    this.shippingAddress = data.deliveryGroups.items.deliveryAddress;
                    if (data.checkoutStatus == 200) {
                        this.isLoading = false;
                    }
                } else if (error) {
                }
            } else {
                this.isLoading = false;
            }
    }

    /**
     * update form when our container asks us to
     */
    stageAction(checkoutStage /*CheckoutStage*/) {
        switch (checkoutStage) {
            case CheckoutStage.CHECK_VALIDITY_UPDATE:
                return Promise.resolve(true);
            case CheckoutStage.REPORT_VALIDITY_SAVE:
                return Promise.resolve(true);
            case CheckoutStage.BEFORE_PAYMENT:
                return Promise.resolve(this.beforePayment());
            case CheckoutStage.PAYMENT:
                return Promise.resolve(this.paymentProcess());
            default:
                return Promise.resolve(true);
        }
    }

    async beforePayment(){
        let mapParams = {
            CartId: this.cartId,
            isOrderForSomeoneElse: getCookie("isOrderForSomeoneElse")
        };
        const result = await updateCheckOutCartStatus({ 'mapParams': mapParams });
        if(result && result.isGroupRecipientsMatch){
            return true;
        } else {
            this.querySelector('c-sib-show-toast-message').showToast(this.labels.SIB_GROUPRECIPIENTSMISMATCH,'error',5000);
        }
    }

    /**
    * checkout save
    */
    @api
    async paymentProcess() {
        await this.completePayment();

        const orderConfirmation = await this.dispatchPlaceOrderAsync();

        if (orderConfirmation.orderReferenceNumber) {
            this.refs.showToast.showToast('Order Placed successfully','success',5000);
            refreshCartSummary();
            this.navigateToOrder(orderConfirmation.orderReferenceNumber);
        } else {
            this.querySelector('c-sib-show-toast-message').showToast('Required orderReferenceNumber is missing','error',5000);
        }
    }


    /**
     * complete payment
     */
    @api
    async completePayment(){
        let address = this.shippingAddress;
        const purchaseOrderInputValue = this.isFreeCourse ? 'No Charge' : 'Invoice';
        let po = await simplePurchaseOrderPayment(this.checkoutId, purchaseOrderInputValue, address);
        return po;
    }

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

    /**
     * Naviagte to the order confirmation page
     * @param navigationContext lightning naviagtion context
     * @param orderNumber the order number from place order api response
     */
    navigateToOrder(orderNumber) {
        this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
            name: "Order"
        },
        state: {
            orderNumber: orderNumber
        }
        });
    }
}