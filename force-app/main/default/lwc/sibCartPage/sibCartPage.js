import { LightningElement, api, track, wire } from 'lwc';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
import { CartCouponsAdapter } from 'commerce/cartApi';
import cartApi from 'commerce/cartApi';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getCartDetails from '@salesforce/apex/SIB_CartController.getCartDetails';
import updateCartItem from '@salesforce/apex/SIB_CartController.updateCartItem';
import deleteCartItem from '@salesforce/apex/SIB_CartController.deleteCartItem';
import clearCart from '@salesforce/apex/SIB_CartController.clearCart';
import getCartPromotions from '@salesforce/apex/Saltbox_B2BCartController2.getCartPromotions';
import { refreshCartSummary } from "commerce/cartApi";
import SIB_CartName from '@salesforce/label/c.SIB_CartName';
import SIB_OrderSummary from '@salesforce/label/c.SIB_OrderSummary';
import SIB_EmptyCartMsg from '@salesforce/label/c.SIB_EmptyCartMsg';
import SIB_CartNotAvailableMsg from '@salesforce/label/c.SIB_CartNotAvailableMsg';
import activateCart from '@salesforce/apex/SIB_CartController.activateCart';
import { CartSummaryAdapter } from "commerce/cartApi";
import {consoleLogging} from "c/sibUtils";


const CLOSED_CART_MESSAGE_REGEXP = new RegExp(/Cart Id: '\S+' is Deleted/, 'i');

export default class SibCartPage extends LightningElement {

    static renderMode = 'light';
    showSpinner = false;
    messageState = 'Loading';
    isCartClosed = false;
    errorMsg;
    webstoreId;
    effectiveAccountId;
    isPreview;
    cartId;
    isSkeletonLoading = true;

    Labels = {
        SIB_CartName,
        SIB_OrderSummary,
        SIB_EmptyCartMsg,
        SIB_CartNotAvailableMsg
    }

    @api cartItems = [];
    @api cartDetails = {};
    @api cartTotal;
    @api cartConfig;
    firstLoad = true;

    @wire(AppContextAdapter)
    handleAppContextAdapterResponse(result){
        if(result.data){
            this.webstoreId = result.data.webstoreId;
            this.getEffectiveAccountId();
        }
    }

    couponCode;
    cartCouponId;
    hasCoupon = false;
    oldCouponValue;
    @wire(CartCouponsAdapter, { webstoreId: '$webStoreId', cartStateOrId: 'current' })
    onGetCartCoupons(result) {
        this.isLoading = false;
        if (result?.data && result?.data?.cartCoupons && result?.data?.cartCoupons?.coupons?.length > 0) {
            this.couponCode = result?.data?.cartCoupons?.coupons[0]?.couponCode;
            this.cartCouponId = result?.data?.cartCoupons?.coupons[0]?.cartCouponId;
        }
    }

    async getEffectiveAccountId(){
        const result = await getSessionContext();
        if(result)
        {
            this.effectiveAccountId = result.effectiveAccountId;
        }
    }

    cartSummaryAdapter;
    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if (data) 
        {
            this.cartSummaryAdapter = data;
            if(data?.cartId)
            {
                this.handleCartStatus();
            }
            consoleLogging("Cart Summary:", data);
        } else if (error) 
        {
            this.isSkeletonLoading = false;
            consoleLogging(JSON.stringify(error));
        }
    }
    
    handleCartStatus() {
        let mapParams = {
            webstoreId : this.webstoreId,
            effectiveAccountId : this.effectiveAccountId,
        };
        activateCart({ 'mapParams': mapParams})
            .then((res)=>{
                if(res.isSuccess && this.firstLoad) {
                    this.firstLoad = false
                    this.fetchCartDetails();
                }
                else{
                    this.isSkeletonLoading = false;
                }
            })
            .catch((e) => {
                consoleLogging('error while activating cart');
            })
    }

    get currencyCode() {
        return this.cartDetails?.currencyIsoCode;
    }

    get isConfigLoaded() {
        return this.cartConfig != null;
    }

    get isCartItemsAvaialble() {
        return this.cartItems != null && this.cartItems.length !== 0;
    }

    get isCartDetailsAvailable() {
        return this.cartDetails != null;
    }

    get isCartTotalAvailable() {
        return this.cartTotal != null;
    }

    get checkEmptyCart() {
        return this.cartItems?.length === 0;
    }

    get displayCartPage() {
        if(this.isPreview) {
            return true;
        }
        
        if (this.isCartItemsAvaialble && this.isCartDetailsAvailable && this.isCartTotalAvailable && this.isConfigLoaded && this.scriptLoaded) {
            return true;
        } else {
            return false;
        }
    }


    handleQuantityChanged(evt) {
        this.isSkeletonLoading = true;
        const { cartItemId, newQty, productId } = evt.detail;
        let mapParams = {
            configType : 'cart',
            webstoreId : this.webstoreId,
            effectiveAccountId : this.effectiveAccountId,
            itemId : cartItemId,
            quantity : newQty,
            cartId : this.cartDetails?.cartId,
            productId : productId
        };

        updateCartItem({ 'mapParams': mapParams})
        .then((result) => {
            if(result.res.isSuccess) {
                if(this.couponCode && this.cartCouponId) {
                    this.hasCoupon = true;
                    this.oldCouponValue = this.couponCode;
                    this.deleteCouponFromCart(this.cartCouponId);
                } else {
                    this.fetchCartDetails();
                }
            }
        })
        .catch((e) => {
            consoleLogging(e);
            this.isSkeletonLoading = false;
        })
        .finally(() => {

        });
    }

    async applyCouponToCart(couponCode) {
        const response = await cartApi.applyCouponToCart(couponCode);
        console.log(response);
        if(response) {
            this.fetchCartDetails();
        }
    }

    deleteCouponFromCart(couponId) {
        const result = cartApi.deleteCouponFromCart(couponId);
        result.then((response) => {
            console.log(response);
            if(this.hasCoupon && this.oldCouponValue) {
                this.applyCouponToCart(this.oldCouponValue);
            } else {
                this.fetchCartDetails();
            }
        }).catch((error) => {
            console.log(error);
        });
    }

    handleCartItemDelete(evt) {
        this.isSkeletonLoading = true;
        let mapParams = {
            configType : 'cart',
            webstoreId : this.webstoreId,
            effectiveAccountId : this.effectiveAccountId,
            itemId : evt.detail
        };

        deleteCartItem({ 'mapParams': mapParams})
        .then((result) => {
            if(result.res.isSuccess) {
                this.fetchCartDetails();
            }
            this.pushGtmRemoveCartItemEvent(evt.detail);
        })
        .catch((e) => {
            consoleLogging(e);
            this.isSkeletonLoading = false;
        })
        .finally(() => {

        });
    }

    handleCartDelete() {
        this.isSkeletonLoading = true;
        let mapParams = {
            webstoreId : this.webstoreId,
            effectiveAccountId : this.effectiveAccountId,
        };

        clearCart({ 'mapParams': mapParams})
        .then((result) => {
            if(result.res.isSuccess) {
                this.cartItems = [];
                this.cartDetails = {};
                refreshCartSummary();
                this.isSkeletonLoading = false;
            }

        })
        .catch((e) => {
            consoleLogging(e);
            this.isSkeletonLoading = false;
        })
        .finally(() => {

        });
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
        this.isSkeletonLoading = false;
        this.fetchCartDetails();
    }
    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }

    connectedCallback() {
        window.addEventListener('recommendationaddtocart', this.handleRefreshCart.bind(this));
    }
    disConnectedCallback() {
        window.removeEventListener('recommendationaddtocart', this.handleRefreshCart.bind(this));
    }
    handleRefreshCart(){
        this.isSkeletonLoading = true;
        this.fetchCartDetails();
    }

    fetchCartDetails(cartId) {

        let mapParams = {
            configType : 'cart',
            webstoreId: this.webstoreId,
            effectiveAccountId: this.effectiveAccountId
        };
        if(cartId !== undefined)
        {
            mapParams.cartId = cartId;
        }

        getCartDetails({ 'mapParams': mapParams})
        .then((result) => {
            this.cartConfig = result?.cartConfig;
            if(result?.isSuccess && result?.cartSummary.isSuccess) {
                this.cartDetails = result?.cartSummary;
                this.cartTotal = result?.cartSummary?.grandTotalAmount;
                if (result?.cartItems && result?.cartItems?.isSuccess) {
                    this.cartItems = result?.cartItems?.cartItems;
                } else {
                    this.cartItems = [];
                    this.cartDetails = {};
                }
            }else {
                this.cartDetails = {};
                this.cartItems = [];
            }
            this.isSkeletonLoading = false
            //to update cart badge count
            refreshCartSummary();
            this.isSkeletonLoading = false;
            this.pushGtmViewCartEvent();
        })
        .catch((e) => {
            const errorMessage = error?.body?.message;
            consoleLogging(e);
            this.isCartClosed = isCartClosed(errorMessage);
            this.isSkeletonLoading = false;
        })
        .finally(() => {

        });
    }

    isCartClosed(errorMessage) {
        return CLOSED_CART_MESSAGE_REGEXP.test(errorMessage || '');
    }

    pushGtmViewCartEvent(){
        try {
            let cartID = this.cartDetails?.cartId;
            //View Cart GTM 
            getCartPromotions({ cartId: cartID})
            .then((result) => {
                let cartPromotions = JSON.parse(result);
                let items = [];
                let auxItem = {};
                let itemHasPromotion;
                this.cartItems.forEach(item => {
                    itemHasPromotion = false;
                    cartPromotions?.cartItemPromotions.forEach(promotion => {
                        if (promotion.cartItemId === item.itemId) {
                            auxItem = { item_name:item?.productDetail.name, item_id:item?.productDetail.productSku, coupon: promotion?.promotion};
                            itemHasPromotion = true;
                        }
                    });
                    if (!itemHasPromotion) {
                        auxItem = { item_name:item?.productDetail.name, item_id:item?.productDetail?.productSku, coupon: ''};
                    }
                    items.push(auxItem);
                });

                let value = this.cartDetails?.totalProductAmountAfterAdjustments  
                let currency = this.cartDetails?.currencyIsoCode;
                let coupon = cartPromotions?.cartOverallPromotion;
                let itemArray = JSON.parse(JSON.stringify(items));

                const pushToDataLayer = new CustomEvent('updateGTMdataLayer', { 
                    'detail' : { 
                        'event' : 'view_cart', 
                        'ecommerce' : {
                            'value': value,
                            'currency': currency,
                            'coupon': coupon,
                            'items' : itemArray
                        } 
                    }
                });

                document.dispatchEvent(pushToDataLayer);

            });
        } catch (error) {
            consoleLogging('Error in GTM View Cart', e);
        }
    }
    pushGtmRemoveCartItemEvent(cartItemId){
        try {
            let cartID = this.cartDetails?.cartId;
            const removedItem = (this.cartItems || []).find(
                (item) => item.itemId === cartItemId
            ) || null;
            //View Cart GTM 
            getCartPromotions({ cartId: cartID})
            .then((result) => {
                let cartPromotions = JSON.parse(result);
                let items = [];
                let coupon = '';
                let itemHasPromotion;
                this.cartItems.forEach(item => {
                    itemHasPromotion = false;
                    cartPromotions?.cartItemPromotions.forEach(itemPromotion => {
                        if (itemPromotion?.cartItemId === item.itemId) {
                            coupon = itemPromotion?.promotion;
                        }
                    });
                    let auxItem = { item_name:removedItem?.productDetail.name, item_id:removedItem?.productDetail.productSku};
                    items.push(auxItem);
                });

                let value = this.cartDetails?.totalProductAmountAfterAdjustments ;
                let currency = this.cartDetails?.currencyIsoCode;
                let itemArray = JSON.parse(JSON.stringify(items));

                const pushToDataLayer = new CustomEvent('updateGTMdataLayer', { 
                    'detail' : { 
                        'event' : 'remove_from_cart', 
                        'ecommerce' : {
                            'value': value,
                            'currency': currency,
                            'coupon': coupon,
                            'items' : itemArray
                        } 
                    }
                });
                document.dispatchEvent(pushToDataLayer);

            });
        } catch (error) {
            consoleLogging('Error in GTM View Cart', e);
        }
    }

    constructor() {
        super();
        this.initialLoadCSSAndJS();
    }

    initialLoadCSSAndJS() {
        let themeName = 'cart';
        let swiperCSSpath = SIBTheme + '/css/swiper-bundle.min.css';
        let mainCSSPath = SIBTheme + '/css/sib-main.css';
        let cartCSSPath = SIBTheme + '/css/' + themeName + '.css';
        let siteUtilsScriptpath = SIBTheme + '/js/sib-utils.js';
        let swiperScriptpath = SIBTheme + '/js/swiper-bundle.min.js';
        let siteScriptpath = SIBTheme + '/js/sib-site.js';
        Promise.all([
            loadStyle(this, mainCSSPath), 
            loadStyle(this, swiperCSSpath)
        ])
        .then(() => {
            this.scriptLoaded = true;
            //let cartPage = this.displayCartPage;
            Promise.all([
                loadScript(this, swiperScriptpath),
                loadScript(this, siteUtilsScriptpath), 
                loadScript(this, siteScriptpath)
            ])
            .then(() => {
                
            })
            .catch(error => {
                console.error(error);
            });
        })
        .catch(error => {
            console.error(error);
        });
    }
}