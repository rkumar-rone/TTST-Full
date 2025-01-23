import { LightningElement, api, wire } from 'lwc';
import { CartCouponsAdapter } from 'commerce/cartApi';
import EnterPromoCode from '@salesforce/label/c.SIB_enterPromoCode';
import PromoCode from '@salesforce/label/c.SIB_PromoCode';	
import ApplyBtn from '@salesforce/label/c.SIB_ApplyBtn';
import Discount from '@salesforce/label/c.SIB_Discount';

const APPLY_COUPON_EVT = 'applycartcoupon';
const REMOVE_COUPON_EVT = 'removecartoupon';
export default class SibCoupon extends LightningElement {
    _errorMessage;
    isCouponInvalid = false
    applyBtnClass = 'btn-apply btn-disabled'
    couponCodeVal = '';
    couponCode;
    cartCouponId;
    panelVisible = true;

    labels = {
        EnterPromoCode,
        ApplyBtn,
        Discount,
        PromoCode
    };

    @api cartTotal;
    @api cartConfig;
    @api webstoreId;

    @api 
    get errorMsg(){
        return this._errorMessage;
    }
    set errorMsg(value) {
        this._errorMessage = value;
        this.isCouponInvalid = this._errorMessage != null ? true : false;
    }

    get adjustedAmt() {
        return this.cartTotal?.promotionalAdjustmentAmount * -1;
    }

    get applyBtnClass(){
        return  this.couponCodeVal.length  == 0 ? 'btn-apply btn-disabled' : 'btn-apply';
    }
    
    get applyActionDisabled(){
        return  this.couponCodeVal.length  == 0 ? true : false;
    }

    get removeActionDisabled(){
        return this.cartCouponId == null ? true : false;
    }

    get panelClass() {
        return this.panelVisible ? 'panel' : 'panel slds-hide'; 
    }

    handlePromoIconClick() {
        this.panelVisible = !this.panelVisible; 
    }

    @wire(CartCouponsAdapter, { webstoreId: '$webStoreId', cartStateOrId: 'current' })
    onGetCartCoupons(result) {
        this.isLoading = false;
        if (result?.data && result?.data?.cartCoupons && result?.data?.cartCoupons?.coupons?.length > 0) {
            this.couponCode = result?.data?.cartCoupons?.coupons[0]?.couponCode;
            this.cartCouponId = result?.data?.cartCoupons?.coupons[0]?.cartCouponId;
            this.couponCodeVal = '';
        }
        else{
            this.couponCode= '';
            this.cartCouponId= '';
        }
    }

    handleCouponChange(event){
        this.couponCodeVal = event.target.value;
        this.applyBtnClass =  this.couponCodeVal?.length  == 0 ? 'btn-apply btn-disabled' : 'btn-apply';
    }

    handleApplyCoupon() {
        this.dispatchEvent(
            new CustomEvent(APPLY_COUPON_EVT, {
                detail: this.couponCodeVal,
                composed: true,
                bubbles: true,
            })
        );
    }

    handleDeleteCoupon() {
        this.dispatchEvent(
            new CustomEvent(REMOVE_COUPON_EVT, {
                detail: this.cartCouponId,
                composed: true,
                bubbles: true,
            })
        );
    }
    handleKeyPress(event){
        if (event.key == 'Enter') {
            event.preventDefault();
            this.handleApplyCoupon();
        }
    }
}