import { LightningElement,api,wire} from 'lwc';
import cartApi from 'commerce/cartApi';
import { NavigationMixin } from 'lightning/navigation';
import CouponAppliedSuccessMsg from '@salesforce/label/c.SIB_CouponAppliedSuccessMsg';
import InvalidCouponMsg from '@salesforce/label/c.SIB_invalidCouponMsg';
import CouponDeletedSuccessMsg from '@salesforce/label/c.SIB_couponDeletedSuccessMsg';
import {publish, MessageContext} from 'lightning/messageService';
import CHECKOUT_CARTSTATUS_MESSAGE_CHANNEL from '@salesforce/messageChannel/sibMultiStepCheckoutMessages__c';
import { getCookie } from "c/sibUtils";

const INVALID_COUPON_EVT = 'invalidcoupon';
const SHOW_TOAST_MSG_EVT = 'showtoastmsg'

export default class SibCartUtils extends NavigationMixin(LightningElement) {

    @wire(MessageContext)
    messageContext;

    isLoading;
    labels = {
        CouponAppliedSuccessMsg,
        InvalidCouponMsg,
        CouponDeletedSuccessMsg
    };

    /*
    add product to cart.
    */
    @api addToCart(productId , productQuantity)
    {
       this.isLoading = true;
       this.handleAddToCart(productId , productQuantity);
    }

    async handleAddToCart(productId , productQuantity) {
        if (productId && productQuantity) {
            const result = await cartApi.addItemToCart(productId,productQuantity);
            if(result && result.cartItemId)
            {
                this.showAddToCartPopup = true;
                this.doPublishCartChange();
            }
        }
        this.isLoading = false;
    }

    /*
    Updates the item quantity in the cart.
    */
    @api updateCartItem(itemId , quantity)
    {
        this.updateItemInCart(itemId , quantity);
    }

    updateItemInCart(itemId , quantity) {
        this.isLoading = true;
        const result = cartApi.updateItemInCart(itemId,quantity);
        result.then((response) => {            
        }).catch((error) => {
            console.log(error);
        });
        this.doPublishCartChange();
        this.isLoading = false;
    }

    /*
    Deletes an item from the cart.
    */
    @api deleteCartItem(cartItemId)
    {
        this.deleteItemFromCart(cartItemId);
    }

    async deleteItemFromCart(cartItemId) {
        this.isLoading = true;
        const result = await cartApi.deleteItemFromCart(cartItemId);
        this.doPublishCartChange();
        this.isLoading = false;
    }

    /*
    Deletes an active/current cart. 
    */
    @api ClearCurrentCart()
    {
       this.deleteCurrentCart();
    }

    deleteCurrentCart() {
        this.isLoading = true;
        const result = cartApi.deleteCurrentCart();
        result.then((response) => {
        }).catch((error) => {
            console.log(error);
        });
        this.doPublishCartChange();
        this.isLoading = false;
    }

    doPublishCartChange() {
        
    }

    /*
    Applies a coupon to the cart.
    */
    @api applyCoupon(couponCode)
    {
       this.applyCouponToCart(couponCode);
    }

    async applyCouponToCart(couponCode) {
        this.isLoading = true;
        try {
            this.isLoading = true;
            const response = await cartApi.applyCouponToCart(couponCode);
            this.doDispatchTheCustomEvent(SHOW_TOAST_MSG_EVT, this.labels.CouponAppliedSuccessMsg);
            this.publishCouponUpdateMessage(true);// Oct 16 2024 added to force payment component hide/view
        } catch (error) {
            this.doDispatchTheCustomEvent(INVALID_COUPON_EVT, this.labels.InvalidCouponMsg);
            console.log(error);
        }
        this.isLoading = false;
    }

    doDispatchTheCustomEvent(evtName, message){
        this.dispatchEvent(
            new CustomEvent(evtName, {
                detail: message,
                composed: true,
                bubbles: true,
            })
        );
    }

    /*
    Deletes an applied coupon from the cart.
    */

    @api deleteCoupon(couponId)
    {
       this.deleteCouponFromCart(couponId);
    }

    deleteCouponFromCart(couponId) {
        this.isLoading = true;
        const result = cartApi.deleteCouponFromCart(couponId);
        result.then((response) => {
            this.doDispatchTheCustomEvent(SHOW_TOAST_MSG_EVT, this.labels.CouponDeletedSuccessMsg);
            this.publishCouponUpdateMessage(true);// Oct 16 2024 added to force payment component hide/view
        }).catch((error) => {
            console.log(error);
        });
        this.doPublishCartChange();
        this.isLoading = false;
    }

    /** handles publish message to LMS channel on coupon add/remove - 16 Oct 24 */
    publishCouponUpdateMessage(isForceCartRefresh) {
        let checkoutStage = getCookie("checkoutStage");
        const payload = { 
            forceCartRefresh: isForceCartRefresh,
            nextState: checkoutStage
        };
        publish(this.messageContext, CHECKOUT_CARTSTATUS_MESSAGE_CHANNEL, payload);
    }
}