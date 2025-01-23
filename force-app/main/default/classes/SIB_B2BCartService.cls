/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_B2BCartService implements ISIB_CartService  {

    private static final String CONFIG_TYPE = 'CART';

    public SIB_CartResponse getCartSummary(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        String activeCartOrId = SIB_Constants.CURRENT_CART;
        if(cartRequest.cartId != null && String.isNotBlank(cartRequest.cartId)) {
            activeCartOrId = cartRequest.cartId;
        }
        ConnectApi.CartSummary cartSummary = null;
        if(!Test.isRunningTest()){
            cartSummary = ConnectApi.CommerceCart.getCartSummary(cartRequest.webstoreId, cartRequest.accountId , activeCartOrId);
        }else{
            cartSummary = SIB_TestDataFactory.createMockConnectAPICartSummary(activeCartOrId);
        }
        if(cartSummary != null) {
            cartResponse.isSuccess = true;
            cartResponse.cartId = cartSummary.cartId;
            cartResponse.grandTotalAmount = Decimal.valueOf(cartSummary.grandTotalAmount);
            cartResponse.totalProductAmount = Decimal.valueOf(cartSummary.totalProductAmount);
            cartResponse.status = String.valueOf(cartSummary.status);
            cartResponse.taxAmount = Decimal.valueOf(cartSummary.totalTaxAmount);
            cartResponse.shippingAmount = Decimal.valueOf(cartSummary.totalChargeAmount);
            cartResponse.discountAmount = Decimal.valueOf(cartSummary.totalPromotionalAdjustmentAmount);
            cartResponse.uniqueProductCount = cartSummary.uniqueProductCount;
            cartResponse.currencyIsoCode = cartSummary.currencyIsoCode;
            //check if cart is locked
            List<WebCart> cartList = [SELECT Id, IsLocked__c FROM WebCart WHERE Id = :cartSummary.cartId];
            if(cartList != null && cartList.size() > 0) {
                WebCart currCart = cartList[0];
                cartResponse.isLocked = currCart.IsLocked__c;
            }
        }
        return cartResponse;
    }

    public SIB_CartResponse getCartItems(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        String activeCartOrId = SIB_Constants.CURRENT_CART;
        if(cartRequest.cartId != null && String.isNotBlank(cartRequest.cartId)) {
            activeCartOrId = cartRequest.cartId;
        }
        String productFields = '';
        List<String> fieldList = cartItemProductFields();
        if(fieldList != null && fieldList.size() > 0) {
            for(String prodField : fieldList) {
                if(productFields == '') {
                    productFields += prodField;
                }
                productFields += ',' + prodField;
            }  
        }
        ConnectApi.CartItemCollection cartItemsCollection = null;
        if(!Test.isRunningTest()){
            cartItemsCollection = ConnectApi.CommerceCart.getCartItems(cartRequest.webstoreId, cartRequest.accountId , activeCartOrId, productFields, null, null, null);        
            System.debug('cartItemsCollection'+ JSON.serialize(cartItemsCollection));    
           
        }else{
            cartItemsCollection = SIB_TestDataFactory.createMockCartItemCollection(activeCartOrId);
        }
        if(cartItemsCollection != null && cartItemsCollection.cartItems != null && cartItemsCollection.cartItems.size() > 0) {
            cartResponse.isSuccess = true;
            ConnectApi.CartSummary cartSummary = cartItemsCollection.cartSummary;
            cartResponse.cartId = cartSummary.cartId;
            cartResponse.grandTotalAmount = Decimal.valueOf(cartSummary.grandTotalAmount);
            cartResponse.totalProductAmount = Decimal.valueOf(cartSummary.totalProductAmount);
            cartResponse.status = String.valueOf(cartSummary.status);
            cartResponse.taxAmount = Decimal.valueOf(cartSummary.totalTaxAmount);
            cartResponse.shippingAmount = Decimal.valueOf(cartSummary.totalChargeAmount);
            cartResponse.discountAmount = Decimal.valueOf(cartSummary.totalPromotionalAdjustmentAmount);
            cartResponse.uniqueProductCount = cartSummary.uniqueProductCount;
            cartResponse.currencyIsoCode = cartSummary.currencyIsoCode;
            cartResponse.totalProductAmountAfterAdjustments = Decimal.valueOf(cartSummary.totalProductAmountAfterAdjustments);
            //check if cart is locked
            List<WebCart> cartList = [SELECT Id, IsLocked__c FROM WebCart WHERE Id = :cartSummary.cartId];
            if(cartList != null && cartList.size() > 0) {
                WebCart currCart = cartList[0];
                cartResponse.isLocked = currCart.IsLocked__c;
            }
            List<SIB_CartResponse.SIB_CartItemResponse> cartItemsList = new List<SIB_CartResponse.SIB_CartItemResponse>();
            for(ConnectApi.CartItemResult cartItemObject : cartItemsCollection.cartItems) {
                ConnectApi.CartItem cartItem = (ConnectApi.CartItem)cartItemObject.cartItem;
                SIB_CartResponse.SIB_CartItemResponse item = new SIB_CartResponse.SIB_CartItemResponse();
                item.itemId = cartItem.cartItemId;
                item.productId = cartItem.productId;

                //productFieldList contains all lowercase strings
                List<String> productFieldList = SIB_Util.getAllObjectFields(SIB_Constants.PRODUCT_API_NAME).split(', ');
                SIB_ProductDetail productDetail = new SIB_ProductDetail();
                productDetail.productSku = cartItem.productDetails.sku;
                productDetail.name = cartItem.productDetails.name;
                productDetail.fieldsMap = cartItem.productDetails.fields;
                productDetail.productGroup = productFieldList.contains('product_group__c') &&  productDetail.fieldsMap.containsKey('Product_Group__c') &&  productDetail.fieldsMap.get('Product_Group__c') != null ?  productDetail.fieldsMap.get('Product_Group__c') : null;
                productDetail.isCourse = productFieldList.contains('sib_is_course__c') && productDetail.fieldsMap.containsKey('SIB_Is_Course__c') && productDetail.fieldsMap.get('SIB_Is_Course__c') != null ? Boolean.valueOf(productDetail.fieldsMap.get('SIB_Is_Course__c')) : false;
                productDetail.isMostPopular = productFieldList.contains('sib_most_popular__c') && productDetail.fieldsMap.containsKey('SIB_Most_Popular__c') && productDetail.fieldsMap.get('SIB_Most_Popular__c') != null ? Boolean.valueOf(productDetail.fieldsMap.get('SIB_Most_Popular__c')) : false;
                productDetail.isNewCourse = productFieldList.contains('new_course__c') && productDetail.fieldsMap.containsKey('New_Course__c') && productDetail.fieldsMap.get('New_Course__c') != null ? Boolean.valueOf(productDetail.fieldsMap.get('New_Course__c')) : false;
                ConnectApi.ProductMedia defaultMedia = cartItem.productDetails.thumbnailImage;
                if(defaultMedia != null){
                    SIB_ProductDetail.SIB_ProductMedia defaultImage = new SIB_ProductDetail.SIB_ProductMedia(defaultMedia.id, defaultMedia.title, String.valueOf(defaultMedia.mediaType) , defaultMedia.alternateText,defaultMedia.url);
                    productDetail.defaultImage = defaultImage;
                }
                item.productDetail = productDetail;
                item.quantity = Integer.valueOf(cartItem.quantity);
                item.listPrice = Decimal.valueOf(cartItem.totalListPrice);
                item.unitPrice = Decimal.valueOf(cartItem.salesPrice);
                item.totalPrice = Decimal.valueOf(cartItem.totalPrice);
                item.totalDiscount = Decimal.valueOf(cartItem.totalAdjustmentAmount);
                item.type = String.valueOf(cartItem.type);
                item.currencyIsoCode = cartSummary.currencyIsoCode;
                cartItemsList.add(item);
            }
            cartResponse.cartItems = cartItemsList;
        }
        return cartResponse;
    }
    
    public SIB_CartResponse addToCart(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        List<SIB_CartRequest.SIB_CartItemRequest> cartItemsRequest = cartRequest.cartItems;
        List<ConnectApi.BatchInput> cartItems = populateCartBatchInputs(cartItemsRequest);
        List<ConnectApi.BatchResult> lstBatchResults = null;
        System.debug('lstBatchResults =>' + cartItemsRequest);
        System.debug('lstBatchResults =>' + cartItems);
        if(!Test.isRunningTest()){
            lstBatchResults = ConnectApi.CommerceCart.addItemsToCart(cartRequest.webstoreId, cartRequest.accountId , SIB_Constants.CURRENT_CART , cartItems, cartRequest.currencyIsoCode);
        }
        System.debug('lstBatchResults =>' + lstBatchResults);
        if(lstBatchResults != null && lstBatchResults[0].isSuccess) {
            ConnectApi.CartItem batchResult = (ConnectApi.CartItem)lstBatchResults[0].getResult();
            cartResponse.cartId = batchResult.cartId;
            cartResponse.isSuccess = true;
        }
        return cartResponse;
    }

    public SIB_CartResponse removeCartItem(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        List<SIB_CartRequest.SIB_CartItemRequest> cartItemsToDeleteRequest = cartRequest.cartItems;
        if(cartItemsToDeleteRequest != null && cartItemsToDeleteRequest.size() > 0) {
            String cartItemId = cartItemsToDeleteRequest[0].itemId;
            if(!Test.isRunningTest()){
                ConnectApi.CommerceCart.deleteCartItem(cartRequest.webstoreId, cartRequest.accountId , SIB_Constants.ACTIVE_CART , cartItemId);
            }
            cartResponse.isSuccess = true;
        }
        return cartResponse;
    }

    public SIB_CartResponse clearCart(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        if(!Test.isRunningTest()){
            ConnectApi.CommerceCart.deleteCart(cartRequest.webstoreId, cartRequest.accountId , SIB_Constants.CURRENT_CART);
        }
        cartResponse.isSuccess = true;
        return cartResponse;
    }

    public SIB_CartResponse createCart(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        ConnectApi.CartInput cartInput  = new ConnectApi.CartInput();
        cartInput.effectiveAccountId = cartRequest.accountId;
        cartInput.currencyIsoCode = cartRequest.currencyIsoCode;
        cartInput.isSecondary = false;
        ConnectApi.CartSummary cartSummary = null;
        if(!Test.isRunningTest()){
            cartSummary = ConnectApi.CommerceCart.createCart(cartRequest.webstoreId , cartInput);
        }else{
            cartSummary =  SIB_TestDataFactory.createMockConnectAPICartSummary(cartRequest.cartId);
        }
        if(cartSummary != null) {
            cartResponse.isSuccess = true;
        }
        return cartResponse;
    }
    
    public SIB_CartResponse updateCartItem(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        List<SIB_CartRequest.SIB_CartItemRequest> cartItemsToUpdateRequest = cartRequest.cartItems;
        if(cartItemsToUpdateRequest != null && cartItemsToUpdateRequest.size() > 0) {
            SIB_CartRequest.SIB_CartItemRequest item = cartItemsToUpdateRequest[0];
            ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
            cartItemInput.productId = item.productId;
            cartItemInput.quantity = item.quantity + '';
            cartItemInput.type = ConnectApi.CartItemType.Product;
            String cartItemId = item.itemId;
            ConnectApi.CartItem itemResult = null;
            if(!Test.isRunningTest()){
                itemResult = ConnectApi.CommerceCart.updateCartItem(cartRequest.webstoreId, cartRequest.accountId , SIB_Constants.ACTIVE_CART , cartItemId, cartItemInput);
            }
            cartResponse.isSuccess = true;
        }
        return cartResponse;
    }

    public SIB_CartResponse repriceCart(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        
        return cartResponse;
    }

    public SIB_CartResponse applyCoupon(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        if(cartRequest.couponCode != null && String.isNotBlank(cartRequest.couponCode)) {
            String couponCode = cartRequest.couponCode;
            ConnectApi.cartCouponInput couponInput = new ConnectApi.cartCouponInput();
            couponInput.couponCode = couponCode;
            ConnectApi.CartCouponCollection couponCollection = null;
            if (!Test.isRunningTest()) {
                couponCollection = ConnectApi.CommerceCart.applyCartCoupon(cartRequest.webstoreId, cartRequest.accountId , 'active', couponInput);
}
            cartResponse.isSuccess = true;
        }
        return cartResponse;
    }

    public SIB_CartResponse getCartCoupons(SIB_CartRequest cartRequest){
        SIB_CartResponse cartResponse = new SIB_CartResponse();
        String activeCartOrId = SIB_Constants.ACTIVE_CART;
        if(cartRequest.cartId != null && String.isNotBlank(cartRequest.cartId)) {
            activeCartOrId = cartRequest.cartId;
        }
        ConnectApi.CartCouponCollection couponCollection = null;
        if(!Test.isRunningTest()){
            couponCollection = ConnectApi.CommerceCart.getCartCoupons(cartRequest.webstoreId, cartRequest.accountId , activeCartOrId);
        }
        if(couponCollection != null) {
            cartResponse.isSuccess = true;
            
        }
        return cartResponse;
    }
    

    public static List<ConnectApi.BatchInput> populateCartBatchInputs(List<SIB_CartRequest.SIB_CartItemRequest> cartItemsRequest)
    {
        List<ConnectApi.BatchInput> cartItems = new List<ConnectApi.BatchInput>();
        if(cartItemsRequest!=null && cartItemsRequest.size()>0)
        {
            for(SIB_CartRequest.SIB_CartItemRequest cartItemRequest : cartItemsRequest)
            {
                ConnectApi.CartItemInput cartItemInputObject = new ConnectApi.CartItemInput();
                cartItemInputObject.productId = cartItemRequest.productId;
                cartItemInputObject.quantity =  cartItemRequest.quantity + '';
                cartItemInputObject.type = ConnectApi.CartItemType.Product;
                ConnectApi.BatchInput addBatchInputObject = new ConnectApi.BatchInput(cartItemInputObject);
                cartItems.add(addBatchInputObject);
            }
        }
        return cartItems;
    }

    public static List<String> cartItemProductFields() {
        List<String> fieldNames = new List<String>();
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put(SIB_SetupConstants.CONFIGURATION_TYPE, CONFIG_TYPE);
        mapParams = SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams != null && mapParams.containsKey(SIB_SetupConstants.CONFIG_JSON) && mapParams.get(SIB_SetupConstants.CONFIG_JSON) != null) {
            SIB_CartConfiguration cartConfig = SIB_CartConfiguration.parse((String)mapParams.get(SIB_SetupConstants.CONFIG_JSON));
            if(cartConfig.productFields != null) {
                for(SIB_CartConfiguration.ProductFields prodField : cartConfig.productFields) {
                    fieldNames.add(prodField.name);
                }
            }
        }
        return fieldNames;
    }
}