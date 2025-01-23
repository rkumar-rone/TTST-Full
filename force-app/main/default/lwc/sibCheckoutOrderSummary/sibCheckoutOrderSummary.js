import { LightningElement, api, wire, track } from 'lwc';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';
import { CartItemsAdapter, refreshCartSummary } from 'commerce/cartApi';
import getCartDetails from '@salesforce/apex/SIB_CartController.getCartDetails';
import updateCheckOutCartStatus from '@salesforce/apex/SIB_CartController.updateCheckOutCartStatus';
import checkoutApi from 'commerce/checkoutApi';


export default class sibCheckoutOrderSummaryStencil extends LightningElement {
    static renderMode = 'light';
    cartTotal = {};
    viewPage = 'checkout';
    isSkeletonLoading = true;
    subscriptionList = [];
    showSubscriptions;
    webstoreId;
    effectiveAccountId;
    @api checkoutConfig;
    errorMsg;

    connectedCallback(){
        if(this.isInSitePreview()){
            //preview mode on.
            this.isSkeletonLoading = false;
            this.cartTotal.productAmount = 100;
            this.cartTotal.chargeAmount = 100;
            this.cartTotal.taxAmount = 100;
            this.cartTotal.grandTotal = 100;
            this.cartTotal.promotionalAdjustmentAmount = 100;
        }
    }

    @wire(CartItemsAdapter, { cartStateOrId: 'current' })
    onGetCartItems(result) {
        if( !this.isInSitePreview() ){
            this.isSkeletonLoading = true;
        }
        if(result && result?.data){
            if (result?.data && result?.data?.cartSummary && result?.data?.cartItems?.length > 0) {
                this.isCartEmpty = false;
                this.currencyCode = result?.data?.cartSummary?.currencyIsoCode;

                let mapParams = {
                    configType : 'cart',
                    cartId : result?.data?.cartSummary?.cartId
                };
                this.fetchCartDetails();
                
                let tempCartSummary = JSON.parse(JSON.stringify(result?.data?.cartSummary));
                //set data to pass to child components
                var tempCartTotal = {};
                tempCartTotal.productAmount = tempCartSummary?.totalProductAmount;
                tempCartTotal.chargeAmount = tempCartSummary?.totalChargeAmount;
                tempCartTotal.taxAmount = tempCartSummary?.totalTaxAmount;
                tempCartTotal.grandTotal = tempCartSummary?.grandTotalAmount;
                tempCartTotal.promotionalAdjustmentAmount = parseFloat(tempCartSummary?.totalPromotionalAdjustmentAmount);
                this.cartTotal = tempCartTotal;
                setTimeout(() => {
                    this.isSkeletonLoading = false;
                }, 900);
            }
        }
    }

    @wire(AppContextAdapter)
    hanldeAppContextAdapterResponse(result){
        if(result.data){
            this.webstoreId = result?.data?.webstoreId;
            this.getEffectiveAccountId();
        }
    }

    async getEffectiveAccountId(){
        const result = await getSessionContext();
        if(result){
            this.effectiveAccountId = result?.effectiveAccountId;
        }
    }

    fetchCartDetails(cartId) {

        let mapParams = {
            configType : 'cart',
            webstoreId: this.webstoreId,
            effectiveAccountId: this.effectiveAccountId
        };
        if(cartId != undefined) {
            mapParams.cartId = cartId;
        }

        getCartDetails({ 'mapParams': mapParams})
        .then((result) => {
            this.cartConfig = result?.cartConfig;
            if(result.isSuccess && result?.cartSummary?.isSuccess) {
                this.cartDetails = result?.cartSummary;
                this.cartTotal = result?.cartSummary?.grandTotalAmount;
                this.productCount = Number(this.cartDetails?.uniqueProductCount);
                if(result?.cartItems?.isSuccess) {
                    this.cartItems = result?.cartItems?.cartItems;
                }
            }else {
                this.cartDetails = {};
                this.cartItems = [];
            }
        })
        .catch((e) => {
            console.log(e);
        })
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

    handleApplyCoupon(evt) {
        this.isSkeletonLoading = true;
        this.querySelector('c-sib-cart-utils').applyCoupon(evt.detail);
    }

    handleRemoveCoupon(evt) {
        this.isSkeletonLoading = true;
        this.querySelector('c-sib-cart-utils').deleteCoupon(evt.detail);
    }

    handleInvalidCoupon(event){
        this.errorMsg = event.detail;
        this.isSkeletonLoading = false;
    }

    handleToastMsg(evt){
        this.errorMsg  = null;
        this.querySelector('c-sib-show-toast-message').showToast(evt.detail,'success',5000);
        this.handleUpdateCheckOutCartStatus();
        this.isSkeletonLoading = false;
        
    }

    async handleUpdateCheckOutCartStatus() {
        try {
            await checkoutApi.restartCheckout();
            this.fetchCartDetails();
        } catch (e) {
            console.log(e);
        }
    }
    
}