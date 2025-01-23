import { LightningElement, api, wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import isguest from '@salesforce/user/isGuest';
import Subtotal from '@salesforce/label/c.SIB_Subtotal';
import Products from '@salesforce/label/c.SIB_products';
import Taxes from '@salesforce/label/c.SIB_taxes';
import CalculatedAtCheckout from '@salesforce/label/c.SIB_calculatedAtCheckout';
import Discounts from '@salesforce/label/c.SIB_discounts';
import CustomerDiscount from '@salesforce/label/c.SIB_customerDiscount';
import TotalDue from '@salesforce/label/c.SIB_totalDue';
import FinalTaxHelpText from '@salesforce/label/c.SIB_finalTaxHelpText';
import Checkout from '@salesforce/label/c.SIB_checkout';
import orderSummary from '@salesforce/label/c.SIB_OrderSummary';
import getStrivacityLoginUrl from '@salesforce/apex/SIB_UserRegistrationController.getStrivacityLoginUrl';
import deleteRecipientsFromCheckout from '@salesforce/apex/B2BGetInfo.deleteRecipientsFromCheckout';
import { consoleLogging, setCookie } from "c/sibUtils";
export default class SibCartSummary extends NavigationMixin(LightningElement) {
    static renderMode = 'light';

    labels = {
        orderSummary,
        Subtotal,
        Products,
        Taxes,
        CalculatedAtCheckout,
        Discounts,
        CustomerDiscount,
        TotalDue,
        FinalTaxHelpText,
        Checkout
    };
    @api cartTotal;
    @api cartDetails;
    @api cartConfig;
    @api webstoreId;
    @api viewPage;
    @api currencyCode;
    loginUrl;

    connectedCallback() {
        if(isguest && this.cartDetails?.cartId) {
            let isCartAvailable = (this.cartDetails?.cartId != null) ? 'true&cartId=' + this.cartDetails?.cartId : 'false'
            let mapParams = {
                'startUrl': basePath?.replace('/en-GB', '') + '/processing?page=checkout&preserveCart=' + isCartAvailable
            };
            getStrivacityLoginUrl({ 'dataMap': mapParams})
            .then((result) => {
                if(result.isSuccess) {
                    this.loginUrl = result.ssoUrl;
                }
            })
            .catch((e) => {
                console.log(e);
            })
            .finally(() => {
    
            });
        }
    }
    @api errorMsg;

    get orderContent(){
        if(this.viewPage == 'checkout'){
            return 'order-content-checkout';
        }
        return 'order-content';
    }

    get orderTitle(){
        if(this.viewPage == 'checkout'){
            return 'order-title-checkout';
        }
        return 'order-title';
    }

    get isCheckoutView(){
        if(this.viewPage == 'checkout'){
            return true;
        }
        return false;
    }

    get isCheckoutViewOrPromo(){
        return this.cartConfig?.allowPromoCode ;
    }

    get cartSummaryHeader() {
        return this.labels.orderSummary;
    }

    get cartSubTotal() {
        return this.cartDetails?.totalProductAmount;
    }

    get shippingAmt() {
        if(this.cartDetails?.shippingAmount !== 0) {
            return this.cartDetails?.shippingAmount;
        }
        return undefined;
    }

    get taxAmt() {
        return this.cartDetails?.taxAmount;
    }

    get hasUndefinedTax() {
        return this.taxAmt === undefined;
    }

    get hasTax() {
        return this.taxAmt > 0;
    }

    get grandTotal() {
        return this.cartDetails?.grandTotalAmount;
    }

    get cartPromotion() {
        if(this.cartDetails?.discountAmount !== 0) {
            return this.cartDetails?.discountAmount;
        }
        return undefined;
    }

    showToastMessage(message,type) {
        let field = this.querySelector('c-sib-show-toast-message');
        field.showToast(message,type,6000);
    }

    async deleteRecipients()
    {
        await deleteRecipientsFromCheckout({cartId: this.cartDetails?.cartId}).then(result =>
        {

        }).catch(error => {
            //  send toast message
            consoleLogging('deleteRecipients : Error : '+JSON.stringify(error));
            this.showToastMessage(this.labels.B2B_LBL_SOMETHINGWENTWRONG, 'error');
        });
    }
    
    goToCheckout() {
        const targetUrl = isguest ? ( this.loginUrl ? this.loginUrl : basePath + '/login') : basePath + '/checkout';

        setCookie("checkoutStage", 'groupOrders', 1);
        setCookie("isOrderForSomeoneElse", false, 1);
        setCookie("isPrePopulate", false, 1);
        
        if(!isguest) {
            // Await deletion to ensure it completes before redirecting
            this.deleteRecipients().then(()=>{
                this.navigateToCheckout(targetUrl);
            })
        } else {
            this.navigateToCheckout(targetUrl);
        }
    }

    navigateToCheckout(targetUrl) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url:  targetUrl
            }
        }).then((url) => {
            window.open(url,'_self');
        });
    }
}