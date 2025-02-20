import { LightningElement, api, wire, track } from 'lwc';
import { navigate, NavigationContext } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';
import { CartSummaryAdapter, refreshCartSummary } from "commerce/cartApi";
import cartApi from 'commerce/cartApi';
import { CartCouponsAdapter } from 'commerce/cartApi';
import isGuestUser from "@salesforce/user/isGuest";
import getProductDetails from '@salesforce/apex/SIB_ProductDetailController.getProductDetails';
import updateBuyerAndAccountCurrency from '@salesforce/apex/SIB_ProductDetailController.updateBuyerAndAccountCurrency';
import getProductCurrency from '@salesforce/apex/SIB_ProductDetailController.getProductCurrency';
import addCartItem from '@salesforce/apex/SIB_CartController.addCartItem';
import checkCollevaProductExistOnCart from '@salesforce/apex/SIB_CartController.checkCollevaProductExistOnCart';
import calculateCart from '@salesforce/apex/SIB_CartController.calculateCart';
import clearCart from '@salesforce/apex/SIB_CartController.clearCart';
import CommonModal from 'c/sibCommonModal';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { Labels } from './labels';
import {applicationLogging, consoleLogging} from 'c/sibUtils';

export default class SibProductDetailAddToCart extends LightningElement {

    static renderMode = 'light';

    chooseYourCourse = Labels.chooseYourCourse;

    @api
    set recordId(val) {
        this._recordId = val;
    }
    get recordId() {
        return this._recordId;
    }

    @api
    product;

    @track
    selectedSessionsJson;

    effectiveAccountId;
    webstoreId;
    totalProductCount = 0;
    existingCartId = '';
    isCollevaProductExist = false;
    cartCurrency;
    eventSessions;
    isShowSpinner = false;
    spinnerMsg = 'Please wait while the product is being added to your cart.';

    previouslySelectedEventOption = '';
    currentSelectedEventOption = '';

    @wire(AppContextAdapter)
    hanldeAppContextAdapterResponse(result) {
        if (result.data) {
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

    get selectedSessionPrice(){
        return (this.selectedSessionsJson != null ? (Object.keys(JSON.parse(this.selectedSessionsJson)).length) : 0) * this.negotiatedPrice;
    }

    get negotiatedPrice() {
        return this.product?.price?.negotiatedPrice;
    }

    get currencyCode() {
        return this.product?.price?.currencyCode;
    }

    get listPrice(){
        return this.product?.price?.listPrice
    }

    get unitPrice(){
        return this.product?.price?.negotiatedPrice;
    }

    get showListPrice() {
        return this.listPrice > this.unitPrice;
    }

    async getEffectiveAccountId() {
        const result = await getSessionContext();
        if (result) {
            this.effectiveAccountId = result.effectiveAccountId;
            this.fetchProductDetails();
        }
    }

    get isProductDataAvailable() {
        if(this.product != null) {
            return true;
        }
        return false;
    }

    get incrementStep() {
        return 1;
    }

    get stopDecreaseQuantity() {
        return this.qty <= 1;
    }

    get stopIncreaseQuantity() {
        return false;
    }
    
    @wire(CartSummaryAdapter, {})
    CartAdapterFunc({error, data}){
        if (!this.isInSitePreview()){
            if (data) {
                this.totalProductCount = parseInt(data?.totalProductCount); 
                this.existingCartId = data?.cartId;
                this.cartCurrency = data?.currencyIsoCode;
            } else if (error) {
                this.totalProductCount = 0;
                this.cartCurrency = undefined;
                consoleLogging('CartAdapter Error: ' + error);
            }
        }
    }

    connectedCallback() {
        window.addEventListener('summarysectionchange', this.handleShowAddToCart.bind(this));
        if(this.isMobile) {
            this.summarySectionExpanded = false;
        } else{
            this.summarySectionExpanded = true;
        }
    }

    disconnectedCallback(){
        window.removeEventListener('summarysectionchange', this.handleShowAddToCart.bind(this));
    }

    get isMobile(){
        return FORM_FACTOR === 'Small';
    }

    summarySectionExpanded;

    handleShowAddToCart(event){
        if(event && event.detail){
            this.summarySectionExpanded = event.detail.message;
            const addToCartLayer = this.querySelector('.bottom-layer')
            if(this.summarySectionExpanded){
                addToCartLayer.classList.add('addToCartFix');
            }
            else{
                addToCartLayer.classList.remove('addToCartFix');
            }
        }
    }

    fetchProductDetails() {
        let mapParams = {
            recordId: this.recordId,
            webstoreId: this.webstoreId,
            effectiveAccountId: this.effectiveAccountId
        };
        getProductDetails({
            'mapParams' : mapParams
        }).then((result) => {
            consoleLogging('fetchProductDetails result ' + JSON.stringify(result));
            this.product = result.product;
            if(!this.product?.price?.negotiatedPrice && this.product?.price?.negotiatedPrice !== 0) {
                this.addToCartDisabled = true;
            }
            this.getEventSessions();
            this.handleProductDataEvent();
            this.prepareVariationOptions();
        }).catch((err) => {
            console.error(err);
        });
    }

    getEventSessions() {
        let eventSession = this.product?.eventSessions;

        //TTS code
        let sessions = [];
        let allRequired = true;
        for (let index = 0; index < eventSession?.length; index++) {
            let currentSession = {...eventSession[index]};
            if(currentSession.Required__c == false) {
                allRequired = false;
            }
        }
        let selectedSessionJSON={};
        for (let index = 0; index < eventSession?.length; index++) {
            let currentSession = {...eventSession[index]};
            let previousSession = {...sessions[index-1]};

            // let date = new Date(currentSession?.Session_Date__c);

            // let formattedDate = date.toLocaleDateString("en-US", {
            // month: "short",
            // day: "numeric", 
            // year: "numeric" 
            // });
            
            // let startTime = `${formattedDate} ${currentSession?.Start_Hours__c}:${currentSession?.Start_Minutes__c} ${currentSession?.Start_AM_PM__c}`;
            //let endTime = `${currentSession?.End_Hours__c}:${currentSession?.End_Minutes__c} ${currentSession?.End_AM_PM__c}`;

            currentSession.label = `${currentSession?.Name}`;
            currentSession.sessionTime = `${currentSession?.SIB_Session_Date_For_Display__c}`; //`${ currentSession?.Session_Start__c ? startTime : '' } ${ endTime ? ' - ' + endTime : ''}`;
            if(allRequired) {
                currentSession.isChecked = true;
                selectedSessionJSON[currentSession.Id] = currentSession.label;
            }
            sessions.push(currentSession);
        }
        this.selectedSessionsJson = JSON.stringify(selectedSessionJSON);
        this.eventSessions = sessions;
    }

    handleProductDataEvent() {

        let params = {};
        let totalDays = this.product?.totalDays || '';
        let displayTotalDays;
        if(totalDays){
            displayTotalDays = totalDays == 1 ?'1 Day' : `1-${totalDays} Days`;
        }
        if(this.product?.productGroup == 'Self-Study' 
            || this.product?.productGroup == 'Bundle' 
            || this.product?.fieldsMap?.productClass == 'VariationParent') {
                params = {
                    listPrice: this.product?.price?.listPrice,
                    unitPrice: this.product?.price?.negotiatedPrice,
                    currencyCode: this.product?.price?.currencyCode,
                    courseCount: this.product?.productCount,
                    totalDays: displayTotalDays,
                    productClass : this.product?.productClass,
                    isSelfStudy : true
                } 
        } else {
            params = {
                courseCount: this.product?.productCount,
                totalDays: displayTotalDays,
                productClass : this.product?.productClass,
                isSelfStudy : false
            }
        }

        window.dispatchEvent(
            new CustomEvent("productdata", {
                detail: {
                    params
                },
                bubbles: true,
                composed: true
            })
        );
    }

    @track qty = 1;

    addToCartDisabled = false;

    qtyChange(event){
        this.qty = parseInt(event.target.value);
    }

    decreaseQty(e){
        this.qty = parseInt(this.qty) - parseInt(this.incrementStep);
    }

    increaseQty(e){
        this.qty = parseInt(this.qty) + parseInt(this.incrementStep);
    }

    @wire(NavigationContext)
    navContext;

    handleAddToCart(event) {
        event.stopPropagation();
        this.isShowSpinner = true;
        this.sendIsSpinnerOnEvent(true);
        this.addToCartDisabled = true;

        let productCurrency = this.product?.price?.currencyCode;

        if(isGuestUser) {
            this.addToCartAction();
        } else {
            if(this.cartCurrency && this.cartCurrency != productCurrency) {
                if(this.totalProductCount > 0) {
                    this.sendBubbledToastMessage(Labels.coulNotAddToCartDueToCurrencyMismatch ,'error',5000);
                    this.isShowSpinner = false;
                    this.sendIsSpinnerOnEvent(false);
                    this.addToCartDisabled = true;
                } else {
                    this.handleCartDelete(); 
                }
            } else {
                this.updateAccount();
            }
        }
    }

    handleCartDelete() {
        let mapParams = {
            webstoreId : this.webstoreId,
            effectiveAccountId : this.effectiveAccountId,
        };

        clearCart({ 'mapParams': mapParams})
        .then((result) => {
            if(result.res.isSuccess) {
                console.log('Cart Deleted');
                this.updateAccount();
            }
        })
        .catch((e) => {
            this.isShowSpinner = false;
            this.sendIsSpinnerOnEvent(false);
            console.log(e);
        })
        .finally(() => {

        });
    }

    updateAccount() {
        let mapParams = {
            currencyCode: this.product?.price?.currencyCode,
            effectiveAccountId: this.effectiveAccountId
        };
        updateBuyerAndAccountCurrency({
            'mapParams' : mapParams
        }).then((result) => {
            if(result.isSuccess) {
                consoleLogging('updateAccount result -> ' + result);
                this.addToCartAction();
            }
        }).catch((err) => {
            this.isShowSpinner = false;
            this.sendIsSpinnerOnEvent(false);
            console.error(err);
        });
    }

    async addToCartAction() {
        let productId = this.product?.productId ;
        let productQuantity = parseInt(this.qty);
        if (productId && productQuantity && productQuantity > 0) {
            // if(this.existingCartId)
            // {
                let mapParams = {
                    CartId: this.existingCartId,                
                    productId: productId,
                    quantity: productQuantity,
                };
                await checkCollevaProductExistOnCart({
                    'mapParams' : mapParams
                }).then(async (result) => {
                    consoleLogging('checkCollevaProductExistOnCart result ->' + result);
                    if (result.isSuccess)
                    {
                        if(result.productAlreadyExist) 
                        {
                            this.isCollevaProductExist = true;
                            this.isShowSpinner = false;
                            this.sendIsSpinnerOnEvent(false);
                            this.sendBubbledToastMessage(result.message, 'error', 5000);
                        }
                        if (result && result.log) 
                        {
                            applicationLogging(result.log);
                        }
                    } 
                    else 
                    {
                        this.isShowSpinner = false;
                        this.sendIsSpinnerOnEvent(false);
                        this.sendBubbledToastMessage('There is Error On Cart', 'error', 5000);
                    }
                }).catch((err) => {
                    this.isShowSpinner = false;
                    this.sendIsSpinnerOnEvent(false);
                    this.sendBubbledToastMessage('There is Error On Cart', 'error', 5000);
                    console.error(err);
                });
            // }
            if(!this.isCollevaProductExist)
            {
                let mapParams = {
                    webstoreId: this.webstoreId,
                    effectiveAccountId: this.effectiveAccountId,
                    selectedSessions: this.selectedSessionsJson,
                    selectedSessionNumber: this.selectedSessionNumber,
                    productId: productId,
                    quantity: productQuantity,
                    currencyISOCode: this.product?.price?.currencyCode
                };
                addCartItem({
                    'mapParams' : mapParams
                }).then(async (result) => {
                    consoleLogging('addToCartAction result ->' + result);
                    if (result.isSuccess)
                    {
                        if(this.couponCode && this.cartCouponId) {
                            this.hasCoupon = true;
                            this.oldCouponValue = this.couponCode;
                            this.deleteCouponFromCart(this.cartCouponId, result.res.cartId);
                        } else {
                            this.clearCoupon(result.res.cartId);
                        }
                        

                        if (result && result.log) {
                            applicationLogging(result.log);
                        }
                    } else {
                        this.isShowSpinner = false;
                        this.sendIsSpinnerOnEvent(false);
                        this.sendBubbledToastMessage(Labels.productCouldNotBeAddedToCart.replace('{0}', this.product?.name), 'error', 5000);
                    }
                }).catch((err) => {
                    this.isShowSpinner = false;
                    this.sendIsSpinnerOnEvent(false);
                    this.sendBubbledToastMessage(Labels.productCouldNotBeAddedToCart.replace('{0}', this.product?.name),'error',5000);
                    console.error(err);
                });
            }
        }
    }

    async checkCollevaProductExist() {
        let productId = this.product?.productId ;
        let productQuantity = parseInt(this.qty);
        if (productId && productQuantity && productQuantity > 0) {

            let mapParams = {
                CartId: this.existingCartId,                
                productId: productId,
                quantity: productQuantity,
            };
            await checkCollevaProductExistOnCart({
                'mapParams' : mapParams
            }).then(async (result) => {
                consoleLogging('checkCollevaProductExistOnCart result ->' + result);
                if (result.isSuccess)
                {
                    if(result.productAlreadyExist) 
                    {
                        this.isCollevaProductExist = true;
                        this.isShowSpinner = false;
                        this.sendIsSpinnerOnEvent(false);
                        this.sendBubbledToastMessage('Colleva Product Already Exist On Cart', 'error', 5000);
                    }
                    if (result && result.log) 
                    {
                        applicationLogging(result.log);
                    }
                } 
                else 
                {
                    this.isShowSpinner = false;
                    this.sendIsSpinnerOnEvent(false);
                    this.sendBubbledToastMessage('There is Error On Cart', 'error', 5000);
                }
            }).catch((err) => {
                this.isShowSpinner = false;
                this.sendIsSpinnerOnEvent(false);
                this.sendBubbledToastMessage('There is Error On Cart', 'error', 5000);
                console.error(err);
            });
        }
    }

    async applyCouponToCart(couponCode) {
        const response = await cartApi.applyCouponToCart(couponCode);
        console.log(response);
        if(response) {
            this.openModal();
        }
    }

    deleteCouponFromCart(couponId, cartId) {
        const result = cartApi.deleteCouponFromCart(couponId);
        result.then((response) => {
            console.log(response);
            this.clearCoupon(cartId);
        }).catch((error) => {
            console.log(error);
        });
    }

    clearCoupon(cartId) {
        let params = {
            webstoreId: this.webstoreId,
            effectiveAccountId: this.effectiveAccountId,
            cartId: cartId
        };
        calculateCart({
            'mapParams' : params
        }).then((result) => {
        if(result.isSuccess) {
            consoleLogging('calculateCart result: ' + result);
            if(result.isCartAmtZero) {
                this.openModal();
            } else {
                if(this.hasCoupon && this.oldCouponValue) {
                    this.applyCouponToCart(this.oldCouponValue);
                } else {
                    this.openModal();
                }
            }
        }
        }).catch((err) => {
            this.isShowSpinner = false;
            this.sendIsSpinnerOnEvent(false);
            console.error(err);
        });
    }

    openModal() {
        this.isShowSpinner = false;
        this.sendIsSpinnerOnEvent(false);
        this.addToCartDisabled = false;
        this.sendBubbledToastMessage(Labels.addToCartSuccessMessage, 'success', 5000);
        CommonModal.open({
            label: Labels.messageSuccessfullyAddedToCart,
            size: 'small',
            secondaryActionLabel: Labels.actionContinueShopping,
            primaryActionLabel: Labels.actionViewCart,
            onprimaryactionclick: () => this.navigateToCart(),
        });
        refreshCartSummary();
        this.updateDataLayer();
    }
    
    updateDataLayer() {
        let value = this.product?.price?.negotiatedPrice * this.selectedSessionNumber * parseInt(this.qty);
        let currency = this.product?.price?.currencyCode;
        let itemArray = [];
        itemArray.push({item_name: this.product?.name, item_id: this.product?.productSku, quantity: parseInt(this.qty)});
        
        const pushToDataLayer = new CustomEvent('updateGTMdataLayer', { 
            'detail' : { 
                'event' : 'add_to_cart', 
                'ecommerce' : {
                'value': value,
                'currency': currency,
                'items' : itemArray
                } 
            }
        });
        this.dispatchEvent(pushToDataLayer);
    }

    navigateToCart() {
        this.navContext &&
            navigate(this.navContext, {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Current_Cart',
                },
            });
    }

    firstLoad = true;
    renderedCallback(){
        /*This is done to disable add to cart button on first load if even 1 of the session is 
        required = false, as then all are unchecked*/
        if(this.showPricesAndEvents && this.eventSessions && this.firstLoad){
            this.firstLoad = false;
            let anyRequired = false;
            this.eventSessions?.forEach((event)=>{
                if(!event.Required__c){
                    anyRequired = true;
                }
            });
            if(anyRequired){
                this.addToCartDisabled = true;
            }
            else{
                this.addToCartDisabled = false;
            }
        }
    }

    get isPublicCourse() {
        return this.product?.productGroup == 'Public Course';
    }

    get showStrikethroughPricing(){
        return this.product?.productGroup == 'Self-Study' || this.product?.productGroup == 'Bundle'
    }

    get showEventCityOptions(){
        return this.eventCityOptions.length>0;
    }

    eventCityOptions=[];
    canonicalKeyProductId={};
    showPlaceholder = false;

    prepareVariationOptions(){
        let availableCities=[];
        let availableDates=[];
        if(this.isPublicCourse && this.product!=null){
            if(this.product?.variationInfo){
                //For getting selected values
                if(this.product.variationInfo?.attributesToProductMappings && this.product.variationInfo?.attributesToProductMappings.length>0){
                    this.product.variationInfo?.attributesToProductMappings.forEach(attribute => {
                        if(attribute?.canonicalKey && attribute?.productId){
                            this.canonicalKeyProductId[attribute?.canonicalKey] = attribute?.productId;
                        }
                    });
                }

                //For getting available values
                if(this.product.variationInfo?.variationAttributeInfo){
                    if(this.product.variationInfo?.variationAttributeInfo['Event_City__c']){
                        this.product.variationInfo?.variationAttributeInfo['Event_City__c'].availableValues.forEach(city=>{
                            availableCities.push(city);
                        });
                    }
                    if(this.product.variationInfo?.variationAttributeInfo['Month_Year__c']){
                        this.product.variationInfo?.variationAttributeInfo['Month_Year__c'].availableValues.forEach(date=>{
                            availableDates.push(date);
                        });
                    }
                }

                //Sort Month Year
                if(availableDates?.length > 0) {
                    availableDates.sort((a, b) => new Date(a) - new Date(b));
                }

                if(availableCities.length>0 && availableDates.length>0){
                    availableDates.forEach(dateItem=>{
                        availableCities.forEach(cityItem=>{
                            let value = dateItem+'_'+cityItem;
                            if(value in this.canonicalKeyProductId){
                                this.eventCityOptions.push({label: cityItem+', '+dateItem, value: dateItem+'_'+cityItem, selected:false, disabled:false});
                            }
                        });
                    });

                    if(this.eventCityOptions.length>0){
                        if(this.canonicalKeyProductId!=null){
                            //garora-to set variant option pre-selected - 8 Oct 2024
                            let value='';
                            for (let key in this.canonicalKeyProductId) {
                                if (this.canonicalKeyProductId[key] == this.recordId) {
                                    value=key;
                                }
                            }
                            if(value){
                                const index = this.eventCityOptions.findIndex((item)=>item.value==value);
                                if(index>-1){
                                    this.eventCityOptions[index].selected = true;
                                    let item = this.eventCityOptions[index];
                                    this.previouslySelectedEventOption = item.value; //24 Oct 24- TATLB-211 change VRa
                                    this.currentSelectedEventOption = item.value;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    cityChangeFn(event){
        this.isShowSpinner = true;
        this.sendIsSpinnerOnEvent(true);
        this.spinnerMsg = 'Processing';
        console.log(event.target.value);
        this.currentSelectedEventOption = event.target.value;
        let productId = this.canonicalKeyProductId[event.target.value]
        this.fetchProductCurrency(productId);
    }

    fetchProductCurrency(productId) {
        let mapParams = {
            recordId: productId
        };
        getProductCurrency({
            'mapParams' : mapParams
        }).then((result) => {
            if(result.isSuccess && result.currencyISOCode) {
                
                let baseUrl = basePath.includes('en-GB') ? basePath.split('/en-GB')[0] : basePath;
                let url = baseUrl + '/en-US/product/' + productId;
                if(result.currencyISOCode == 'GBP' && isGuestUser) {//To handle GBP product for guest user
                    url = baseUrl + '/en-GB/product/' + productId;
                }
                if(this.cartCurrency && result.currencyISOCode && this.cartCurrency != result.currencyISOCode) {
                    this.showCurrencyChangeModal(url);
                } else {
                    this.isShowSpinner = false;
                    this.sendIsSpinnerOnEvent(false);
                    window.location.assign(url);
                }
            }
        }).catch((err) => {
            this.isShowSpinner = false;
            this.sendIsSpinnerOnEvent(false);
            console.error(err);
        });
    }

    showCurrencyChangeModal(url) {
        CommonModal.open({
            label: Labels.SIB_Currency_Change_Msg,
            size: 'small',
            secondaryActionLabel: 'Yes',
            primaryActionLabel: 'No',
            onsecondaryactionclick: () => this.currencyModalYesOption(url),
            onprimaryactionclick: () => this.revertProductChange()
        });
    }

    revertProductChange(){
        if(this.previouslySelectedEventOption && this.previouslySelectedEventOption != ''){
            this.currentSelectedEventOption = this.previouslySelectedEventOption;
            this.querySelector('#slct').value = this.currentSelectedEventOption;
        }
        this.isShowSpinner = false;
        this.sendIsSpinnerOnEvent(false);
    }

    currencyModalYesOption(url) {
        this.previouslySelectedEventOption = this.currentSelectedEventOption;
        const result = cartApi.deleteCurrentCart();
        result.then((response) => {
            console.log('Cart Delete');
            refreshCartSummary();
            this.sendIsSpinnerOnEvent(false);
            this.isShowSpinner = false;
            window.location.assign(url);
        }).catch((error) => {
            this.isShowSpinner = false;
            this.sendIsSpinnerOnEvent(false);
            console.log(error);
        });
    }

    get sessionFlag() {
        return this.product?.sessionFlag == 'true';
    }

    get showPricesAndEvents() {
        return this.product?.productGroup == 'Private Course' || this.product?.productGroup == 'Public Course';
    }

    get closeToCapacity() {
        return this.product?.fieldsMap?.Close_to_Capacity__c == 'true';
    }

    get isNonParentProduct() {
        return this.product?.productClass != 'VariationParent';
    }

    get selectedSessionNumber(){
        return (this.selectedSessionsJson != null ? Object.keys(JSON.parse(this.selectedSessionsJson)).length : 1);
    }

    handleSelectionEvent(evt) {
        if(evt.detail){
            this.addToCartDisabled = evt.detail.disableAddToCart;
            this.selectedSessionsJson = evt.detail.selectedSessionsJson 
        }
    }

    _recordId;

    isInSitePreview() {
        let url = document.URL;
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }

    sendBubbledToastMessage(message, type, duration) {
        let displayDuration = duration && duration > 6000 ? duration : 6000;
        window.dispatchEvent(new CustomEvent("bubbledtoastmessage", {
                detail: {
                    message: message, 
                    type: type,
                    duration: displayDuration
                },
                bubbles: true,
                composed: true
            })
        );
    }

    sendIsSpinnerOnEvent(isLoading) {
        window.dispatchEvent(new CustomEvent("isSpinnerOn", {
                detail: {
                    isLoading: isLoading
                },
                bubbles: true,
                composed: true
            })
        );
    }
}