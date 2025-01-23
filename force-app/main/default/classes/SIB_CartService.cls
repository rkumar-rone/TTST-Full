/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 11-08-2024
 * @last modified by  : Gaurav Setia
**/
public without sharing class SIB_CartService {

    private static final String CLASSNAME = 'SIB_CartService';
    private static final String CONFIG_TYPE = 'CART';

    public static Map<String,Object> getCartConfiguration(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        mapParams.put(SIB_SetupConstants.CONFIGURATION_TYPE,CONFIG_TYPE);
        mapParams = SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams.containsKey(SIB_SetupConstants.CONFIG_JSON)){
            SIB_CartConfiguration cartConfig = SIB_CartConfiguration.parse((String)mapParams.get(SIB_SetupConstants.CONFIG_JSON));
            mapParams.put(SIB_SetupConstants.CART_CONFIG, cartConfig);
            isSuccess = true;
        }else{
            message = SIB_SetupConstants.CART_CONFIG_NOT_FOUND_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> getCartDetails(Map<String,Object> mapParams){
        Boolean isSuccess = false;

        String message = '';
        mapParams.put(SIB_SetupConstants.CONFIGURATION_TYPE, CONFIG_TYPE);
        mapParams = SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams != null && mapParams.containsKey(SIB_SetupConstants.CONFIG_JSON) && mapParams.get(SIB_SetupConstants.CONFIG_JSON) != null && mapParams.containsKey(SIB_Constants.CART_ID) && mapParams.get(SIB_Constants.CART_ID) != null){
            String cartId = (String)mapParams.get(SIB_Constants.CART_ID);

            SIB_CartConfiguration cartConfig = SIB_CartConfiguration.parse((String)mapParams.get(SIB_SetupConstants.CONFIG_JSON));
            mapParams.put(SIB_SetupConstants.CART_CONFIG, cartConfig);

            isSuccess = true;
        }else{
            message = SIB_SetupConstants.CART_CONFIG_NOT_FOUND_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> getCartSummary(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null) {

            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);

            ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();
            SIB_CartRequest request = new SIB_CartRequest();
            request.webStoreId = webstoreId;
            request.accountId = effectiveAccountId;
            if(mapParams.containsKey(SIB_Constants.CARTID) && mapParams.get(SIB_Constants.CARTID) != null) {
                String cartId = String.valueOf(mapParams.get(SIB_Constants.CARTID));
                request.cartId = cartId;
            }
            SIB_CartResponse cartResponse = cartService.getCartSummary(request);
            mapParams.put(SIB_Constants.PARAM_CARTSUMMARY, cartResponse);
            mapParams.put(SIB_Constants.CART_ID, cartResponse.cartId);
            isSuccess = true;
        }else{
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> getCartItems(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null) {

            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);

            ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();
            SIB_CartRequest request = new SIB_CartRequest();
            request.webStoreId = webstoreId;
            request.accountId = effectiveAccountId;
            if(mapParams.containsKey(SIB_Constants.CARTID) && mapParams.get(SIB_Constants.CARTID) != null) {
                String cartId = String.valueOf(mapParams.get(SIB_Constants.CARTID));
                request.cartId = cartId;
            }
            mapParams.put(SIB_Constants.PARAM_CARTITEMS, cartService.getCartItems(request));
            isSuccess = true;
        }else{
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> updateCartItem(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        String cartId = '';

        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null) {

            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);

            ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();
            SIB_CartRequest request = new SIB_CartRequest();
            request.webStoreId = webstoreId;
            request.accountId = effectiveAccountId;
            if(mapParams.containsKey(SIB_Constants.CARTID) && mapParams.get(SIB_Constants.CARTID) != null) {
                cartId = String.valueOf(mapParams.get(SIB_Constants.CARTID));
                request.cartId = cartId;
            }
            SIB_CartRequest.SIB_CartItemRequest cartItemRequest = new SIB_CartRequest.SIB_CartItemRequest();
            cartItemRequest.quantity = Integer.valueOf(mapParams.get(SIB_Constants.PARAM_QUANTITY));
            cartItemRequest.itemId = String.valueOf(mapParams.get(SIB_Constants.PARAM_ITEM_ID));
            List<SIB_CartRequest.SIB_CartItemRequest> cartItemsList = new List<SIB_CartRequest.SIB_CartItemRequest>();
            cartItemsList.add(cartItemRequest);
            request.cartItems = cartItemsList;
            mapParams.put(SIB_Constants.PARAM_RES, cartService.updateCartItem(request));
            SIB_GetInfo.updateSessionPricesOnCartItems(cartId, String.valueOf(mapParams.get(SIB_Constants.PRODUCT_ID)), null, false, '');
            calculateCart(mapParams);
            isSuccess = true;
        }else{
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> deleteCartItem(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null) {

            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);

            ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();
            SIB_CartRequest request = new SIB_CartRequest();
            request.webstoreId = webstoreId;
            request.accountId = effectiveAccountId;
            if(mapParams.containsKey(SIB_Constants.CARTID) && mapParams.get(SIB_Constants.CARTID) != null) {
                String cartId = String.valueOf(mapParams.get(SIB_Constants.CARTID));
                request.cartId = cartId;
            }
            string cartItemId = String.valueOf(mapParams.get(SIB_Constants.PARAM_ITEM_ID));
            removeSessionFromCart(cartItemId);
            SIB_CartRequest.SIB_CartItemRequest cartItemRequest = new SIB_CartRequest.SIB_CartItemRequest();
            cartItemRequest.itemId = cartItemId;
            List<SIB_CartRequest.SIB_CartItemRequest> cartItemsList = new List<SIB_CartRequest.SIB_CartItemRequest>();
            cartItemsList.add(cartItemRequest);
            request.cartItems = cartItemsList;
            mapParams.put(SIB_Constants.PARAM_RES, cartService.removeCartItem(request));

            isSuccess = true;
        }else{
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static void removeSessionFromCart(String cartItemId) {
        // Query the CartItem record by the provided ID
        CartItem itemToDelete = [
                SELECT Id, CartId, Cart.Selected_Sessions__c, Product2.TTS_Event__c
                FROM CartItem
                WHERE Id = :cartItemId
                LIMIT 1
        ];

        if (itemToDelete != null) {
            // Query sessions related to the event in Product2.TTS_Event__c
            List<Session__c> sessionList = [
                    SELECT Id
                    FROM Session__c
                    WHERE Event__c = :itemToDelete.Product2.TTS_Event__c
            ];

            String selectedSessions = itemToDelete.Cart.Selected_Sessions__c;
            String sessionString; // This will store the updated sessions

            if (!String.isEmpty(selectedSessions)) {
                // Remove braces and split the selected sessions into a list
                List<String> selectedList = selectedSessions.removeStart('{').removeEnd('}').split(',');

                if (sessionList.size() > 0 && selectedList.size() > 0) {
                    // Iterate over each session and remove it from the selectedList
                    for (Session__c session : sessionList) {
                        for (Integer i = 0; i < selectedList.size(); i++) {
                            if (selectedList[i].contains(session.Id)) {
                                selectedList.remove(i);
                            }
                        }
                    }

                    if (selectedList.size() > 0) {
                        sessionString = '{' + String.join(selectedList, ',') + '}';
                    }
                }
            }

            // Update the Cart with the new session string
            WebCart updatedCart = new WebCart(
                    Id = itemToDelete.CartId,
                    Selected_Sessions__c = sessionString,
                    CartId__c = itemToDelete.CartId
            );
            update updatedCart;
        }
    }

    public static Map<String,Object> clearCart(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null) {

            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);

            ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();
            SIB_CartRequest request = new SIB_CartRequest();
            request.webStoreId = webstoreId;
            request.accountId = effectiveAccountId;
            if(mapParams.containsKey(SIB_Constants.CARTID) && mapParams.get(SIB_Constants.CARTID) != null) {
                String cartId = String.valueOf(mapParams.get(SIB_Constants.CARTID));
                request.cartId = cartId;
                update new WebCart(Id = cartId, Selected_Sessions__c = '', CartId__c = cartId);
            }
            mapParams.put(SIB_Constants.PARAM_RES, cartService.clearCart(request));

            isSuccess = true;
        }else{
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> activateCart(Map<String,Object> mapParams){
        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) &&
                mapParams.get(SIB_Constants.WEBSTOREID) != null)
        {
            mapParams = SIB_CartService.getCartSummary(mapParams);
            if(mapParams.containsKey(SIB_Constants.CART_ID) && mapParams.get(SIB_Constants.CART_ID) != null)
            {
                String cartId = (String)mapParams.get(SIB_Constants.CART_ID);
                List<CartDeliveryGroup> cartDeliveryGroupsList = [SELECT Id,DeliverToStreet,DeliverToCity, DeliverToPostalCode,DeliverToCountry,
                                                                     Cart.Status, Cart.Id FROM CartDeliveryGroup WHERE CartId =:cartId];
                if(cartDeliveryGroupsList != null && cartDeliveryGroupsList.size() > 0)
                {
                    CartDeliveryGroup cartDeliveryGroupObject = cartDeliveryGroupsList[0];
                    cartDeliveryGroupObject.DeliverToStreet = null;
                    cartDeliveryGroupObject.DeliverToCity = null;
                    cartDeliveryGroupObject.DeliverToPostalCode = null;
                    cartDeliveryGroupObject.DeliverToStateCode = null;
                    cartDeliveryGroupObject.DeliverToCountryCode = null;
                    update cartDeliveryGroupObject;
                    WebCart currCart = cartDeliveryGroupObject.Cart;
                    if(currCart.Status != SIB_Constants.Active)
                    {
                        currCart.Status = SIB_Constants.Active;
                        update currCart;
                    }
                }
            }
        }
        return mapParams;
    }

    public static Map<String,Object> addCartItem(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        String cartId = '';
        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null &&
                mapParams.containsKey(SIB_Constants.PRODUCT_ID) && mapParams.get(SIB_Constants.PRODUCT_ID) != null &&
                mapParams.containsKey(SIB_Constants.PARAM_QUANTITY) && mapParams.get(SIB_Constants.PARAM_QUANTITY) != null &&
                mapParams.containsKey(SIB_Constants.PARAM_CURRENCYISOCODE) && mapParams.get(SIB_Constants.PARAM_CURRENCYISOCODE) != null
        )
        {
            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);
            String currencyCode = (String)mapParams.get(SIB_Constants.PARAM_CURRENCYISOCODE);
            String selectedSessions = mapParams.containsKey(SIB_Constants.SELECTED_SESSIONS) ? (String)mapParams.get(SIB_Constants.SELECTED_SESSIONS) : null;
            Decimal selectedSessionNumber = mapParams.containsKey(SIB_Constants.SELECTED_SESSION_NUMBER) ? (Decimal)mapParams.get(SIB_Constants.SELECTED_SESSION_NUMBER) : null;
            String productId = (String)mapParams.get(SIB_Constants.PRODUCT_ID);
            Integer quantity = Integer.valueOf(mapParams.get(SIB_Constants.PARAM_QUANTITY));

            ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();
            SIB_CartRequest request = new SIB_CartRequest();
            request.webstoreId = webstoreId;
            request.accountId = effectiveAccountId;
            request.currencyIsoCode = currencyCode;
            SIB_CartRequest.SIB_CartItemRequest cartItemRequest = new SIB_CartRequest.SIB_CartItemRequest();
            cartItemRequest.quantity = quantity;
            cartItemRequest.productId = productId;
            List<SIB_CartRequest.SIB_CartItemRequest> cartItemsList = new List<SIB_CartRequest.SIB_CartItemRequest>();
            cartItemsList.add(cartItemRequest);
            request.cartItems = cartItemsList;
            SIB_CartResponse cartResponse = cartService.addToCart(request);
            mapParams.put(SIB_Constants.PARAM_RES, cartResponse);

            //TTS code
            B2BGetInfo.updateSelectedSessionsOnCart(cartResponse.cartId, selectedSessions);
            SIB_GetInfo.updateSessionPricesOnCartItems(cartResponse.cartId, productId, selectedSessionNumber, true, selectedSessions);
            isSuccess = true;
        }else{
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> calculateCart(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null &&
                mapParams.containsKey(SIB_Constants.CARTID) && mapParams.get(SIB_Constants.CARTID) != null)
        {
            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);
            Id cartId = (Id)mapParams.get(SIB_Constants.CARTID);
            
            List<WebCart> webcartList = (List<WebCart>)SIB_WebCartSelector.getCartByIds(new List<Id>{cartId});
            if(webcartList != null && !webcartList.isEmpty()) {
                Decimal grandTotalAmount = webcartList.get(0).GrandTotalAmount;
                if(grandTotalAmount != 0) {
                    String couponCode = 'FORCECALCULATE';
                    ConnectApi.CartCouponInput cartCouponInput = new ConnectApi.CartCouponInput();
                    cartCouponInput.couponCode = couponCode;
                    ConnectApi.CartCouponCollection couponCollection = null;
                    if (!Test.isRunningTest()) {
                        couponCollection = ConnectApi.CommerceCart.applyCartCoupon(webstoreId, effectiveAccountId , cartId , cartCouponInput);
                    }else{
                        couponCollection = SIB_TestDataFactory.createMockCartCouponCollection(cartId);
                    }
                    if(couponCollection.cartCoupons != null && couponCollection.cartCoupons.coupons != null &&
                        couponCollection.cartCoupons.coupons.size() > 0 ) {
                        for(ConnectApi.CartCoupon cartCoupon :  couponCollection.cartCoupons.coupons) {
                            if(cartCoupon.couponCode == couponCode) {
                                ConnectApi.CommerceCart.deleteCartCoupon(webstoreId, effectiveAccountId , cartId, cartCoupon.cartCouponId);
                            }
                        }
                    }
                    mapParams.put(SIB_Constants.IS_CART_AMT_ZERO, false);
                } else {
                    mapParams.put(SIB_Constants.IS_CART_AMT_ZERO, true);
                }
            }
            isSuccess = true;
        } else {
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }
    
    public static Map<String,Object> compareCurrency(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if(mapParams != null && mapParams.containsKey(SIB_Constants.CARTID) && mapParams.get(SIB_Constants.CARTID) != null) {
            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id oldCartId = String.valueOf(mapParams.get(SIB_Constants.CARTID));
            
            List<WebCart> oldCartList = getWebCartById(oldCartId);
            if(oldCartList != null && !oldCartList.isEmpty() && effectiveAccountId != null)
            {
                Account acc = SIB_AccountSelector.getAccountInformation(effectiveAccountId);
                if(acc != null && acc.CurrencyIsoCode != oldCartList.get(0).CurrencyIsoCode) {
                    mapParams.put(SIB_Constants.CURRENCY_CODE, oldCartList.get(0).CurrencyIsoCode);
                    mapParams = SIB_ProductDetailService.updateBuyerAndAccountCurrency(mapParams);
                } 
                isSuccess = true;
            }
        } else {
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static Map<String,Object> preserveGuestCart(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if(mapParams != null &&
                mapParams.containsKey(SIB_Constants.WEBSTOREID) && mapParams.get(SIB_Constants.WEBSTOREID) != null &&
                mapParams.containsKey(SIB_Constants.CARTID) && mapParams.get(SIB_Constants.CARTID) != null &&
                mapParams.containsKey(SIB_Constants.IS_CHECKOUT_PAGE) && mapParams.get(SIB_Constants.IS_CHECKOUT_PAGE) != null) 
        {
            Id effectiveAccountId = mapParams.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) ? (Id)mapParams.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) : null;
            Id webstoreId = (Id)mapParams.get(SIB_Constants.WEBSTOREID);
            Id oldCartId = String.valueOf(mapParams.get(SIB_Constants.CARTID));
            Boolean isCheckoutPage = (Boolean)mapParams.get(SIB_Constants.IS_CHECKOUT_PAGE);

            List<WebCart> oldCartList = getWebCartById(oldCartId);
            if(oldCartList != null && !oldCartList.isEmpty() && effectiveAccountId != null)
            {
                Id clonedCartId = cloneCartAndCartItems(oldCartList.get(0), effectiveAccountId);
                if(clonedCartId != null) {
                    if(oldCartList.get(0).Status == 'Active' || oldCartList.get(0).Status == 'Checkout' || oldCartList.get(0).Status == 'Processing' ) {
                        WebCart oldCart = new WebCart();
                        oldCart.Id = oldCartList.get(0).Id;
                        oldCart.Status = 'PendingDelete';
                        update oldCart;
                    }

                    List<WebCart> newCartList = getWebCartById(clonedCartId);
                    if(newCartList != null && !newCartList.isEmpty())
                    {
                        copyCustomCartFields(oldCartList.get(0), newCartList.get(0), isCheckoutPage);
                        SIB_GetInfo.updateSessionPricesOnCart(newCartList.get(0).Id);
                    }
                }
                isSuccess = true;
            }
        }else
        {
            message = SIB_Constants.PARAM_MISSIING_MSG;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }

    public static String getAppliedCartCoupons(String oldCartId){
        string appliedCouponCode;

        List<WebCartAdjustmentBasis> webCartAdjustmentBasis = [SELECT Id, AdjustmentBasisReference.CouponCode, WebCartId FROM WebCartAdjustmentBasis WHERE WebCartId =:oldCartId AND AdjustmentBasisReference.CouponCode != null];
        if(webCartAdjustmentBasis.size() > 0) {
            appliedCouponCode = webCartAdjustmentBasis[0].AdjustmentBasisReference.CouponCode;
        }

        return appliedCouponCode;
    }

    public static void copyCustomCartFields(WebCart oldCart, WebCart newCart, Boolean isCheckoutPage) {
        List<sObject> sobjectToUpdate = new List<sObject>();
        Map<Id, Id> product2ItemIdsMap = new Map<Id, Id>();
        if(oldCart != null && newCart != null) {

            WebCart cart = new WebCart();
            cart.Id = newCart.Id;
            cart.AVA_B2BLEX__Invoice_Message__c = oldCart.AVA_B2BLEX__Invoice_Message__c;
            cart.CartId__c = newCart.Id;
            cart.IsGroupOrder__c = oldCart.IsGroupOrder__c;
            cart.IsWaitlisted__c = oldCart.IsWaitlisted__c;
            cart.Original_Card_Type__c = oldCart.Original_Card_Type__c;
            cart.Selected_Sessions__c = oldCart.Selected_Sessions__c;
            cart.SIB_Guest_Cart__c = oldCart.Id;
            if(isCheckoutPage) {
                cart.Status = SIB_Constants.CART_STATUS_CHECKOUT;
            }
            sobjectToUpdate.add(cart);

            for(CartItem newItem : newCart.CartItems) {
                product2ItemIdsMap.put(newItem.Product2Id , newItem.Id);
            } 

            for(CartItem oldItem : oldCart.CartItems) {
                CartItem item = new CartItem();
                item.Id = product2ItemIdsMap.get(oldItem.Product2Id);
                item.AVA_B2BLEX__LandedCost__c = oldItem.AVA_B2BLEX__LandedCost__c;
                item.CartItem_Selected_Sessions__c = oldItem.CartItem_Selected_Sessions__c;
                item.IsWaitlisted__c = oldItem.IsWaitlisted__c;
                item.Number_of_Sessions__c = oldItem.Number_of_Sessions__c;
                //item.OverridePrice__c = oldItem.OverridePrice__c;
                sobjectToUpdate.add(item);
            }
        }

        if(sobjectToUpdate != null && !sobjectToUpdate.isEmpty()) {
            SIB_Util.updateSObjectsList(sobjectToUpdate);
        }        
    }

    @TestVisible
    private static Id cloneCartAndCartItems(WebCart oldCart, Id accId) {
        if(oldCart != null && accId != null)
        {
            ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();
                
            SIB_CartRequest request = new SIB_CartRequest();
            request.webStoreId = oldCart.WebStoreId;
            request.accountId = accId;
            request.currencyIsoCode = oldCart.CurrencyIsoCode;

            List<WebCart> cartList = getCurrentWebCart(oldCart.WebStoreId);
            if(cartList != null && !cartList.isEmpty()) {
                cartService.clearCart(request);
            }
                 
            SIB_CartResponse createCartResponse = cartService.createCart(request);
            if(createCartResponse != null && createCartResponse.isSuccess) {
                List<SIB_CartRequest.SIB_CartItemRequest> cartItemsList = new List<SIB_CartRequest.SIB_CartItemRequest>();
                for(CartItem oldItem : oldCart.CartItems) {
                    SIB_CartRequest.SIB_CartItemRequest cartItemRequest = new SIB_CartRequest.SIB_CartItemRequest();
                    cartItemRequest.quantity = Integer.valueOf(oldItem.Quantity);
                    cartItemRequest.productId = oldItem.Product2Id;
                    cartItemsList.add(cartItemRequest);
                }
                request.cartItems = cartItemsList;
                SIB_CartResponse cartResponse = cartService.addToCart(request);

                //Get Coupons from Old Cart and apply to New Cart
                String appliedCouponCode = getAppliedCartCoupons(oldCart.Id);
                if(String.isNotBlank(appliedCouponCode)){

                    ConnectApi.CartCouponInput cartCouponInput = new ConnectApi.CartCouponInput();
                    cartCouponInput.couponCode = appliedCouponCode;

                    ConnectApi.CartCouponCollection couponCollection = null;
                    if (!Test.isRunningTest()) {
                        couponCollection = ConnectApi.CommerceCart.applyCartCoupon(oldCart.WebStoreId, accId, cartResponse.cartId, cartCouponInput);
                    }else{
                        couponCollection = SIB_TestDataFactory.createMockCartCouponCollection(String.valueOf(cartResponse.cartId));
                    }
                }
                return cartResponse.cartId;
            }
        }

        return null;
    }

    private static List<WebCart> getWebCartById(Id cartId) {
        List<WebCart> webCartList;
        if(cartId != null) {
            webCartList = [
                SELECT 
                Id, AVA_B2BLEX__Invoice_Message__c, CurrencyIsoCode, IsGroupOrder__c, IsWaitlisted__c,
                Original_Card_Type__c, Selected_Sessions__c, Status, WebStoreId, 
                (
                    SELECT 
                    Id, AVA_B2BLEX__LandedCost__c, CartItem_Selected_Sessions__c, Quantity, 
                    IsWaitlisted__c, Number_of_Sessions__c, Product2Id, OverridePrice__c
                    FROM 
                    CartItems
                    )
                FROM WebCart 
                WHERE 
                Id =: cartId 
                WITH 
                SYSTEM_MODE
            ];

            if(webCartList != null && !webCartList.isEmpty()) {
                return webCartList;
            }
        }
        return null;
    }

    private static List<WebCart> getCurrentWebCart(Id webStoreId) {
        List<WebCart> webCartList;
        if(webStoreId != null) { 
            webCartList = [
                SELECT Id FROM WebCart 
                WHERE 
                OwnerId = :UserInfo.getUserId()
                AND 
                WebStoreId =: webStoreId
                AND 
                IsSecondary = false
                AND 
                (Status = 'Active' OR Status = 'Checkout')
                WITH 
                SYSTEM_MODE
            ];

            if(webCartList != null && !webCartList.isEmpty()) {
                return webCartList;
            }
        }
        return null;
    }

    public static Map<String,Object> updateCheckOutCartStatus(Map<String,Object> mapParams){
        if(mapParams != null && mapParams.containsKey(SIB_Constants.CART_ID) && mapParams.get(SIB_Constants.CART_ID) != null && 
            mapParams.containsKey(SIB_Constants.PARAM_ISORDERFORSOMEONEELSE) && mapParams.get(SIB_Constants.PARAM_ISORDERFORSOMEONEELSE) != null)
        {
            String cartId = (String)mapParams.get(SIB_Constants.CART_ID);
            List<WebCart> cartList = [SELECT Id, Status, BillingCity, BillingCountryCode, BillingStateCode, BillingStreet, BillingPostalCode, TotalProductCount, UniqueProductCount,
                                            (SELECT Id, Quantity FROM CartItems),
                                            (SELECT DeliverToStreet, DeliverToCity, DeliverToPostalCode, DeliverToCountry, DeliverToCountryCode, DeliverToStateCode
                                                FROM CartDeliveryGroups LIMIT 1)
                                        FROM WebCart
                                        WHERE Id = :cartId
                                    ];
            
            if(cartList!=null && cartList.size()>0)
            {
                WebCart currCart = cartList[0];
                Boolean blnUpdateCart = false;
                if (currCart.Status != 'Checkout')
                {
                    currCart.Status = 'Checkout';
                    blnUpdateCart = true;
                }
                if (!currCart.CartDeliveryGroups.isEmpty())
                {
                    CartDeliveryGroup cdg = currCart.CartDeliveryGroups[0];
                    currCart.BillingCity = cdg.DeliverToCity;
                    currCart.BillingCountryCode = cdg.DeliverToCountryCode;
                    currCart.BillingStateCode = cdg.DeliverToStateCode;
                    currCart.BillingStreet = cdg.DeliverToStreet;
                    currCart.BillingPostalCode = cdg.DeliverToPostalCode;
                    blnUpdateCart = true;
                }
                
                if (blnUpdateCart)
                {
                    update currCart;
                }

                Boolean isGroupRecipientsMatch = false;
                Integer groupRecipientsSize = B2BGetInfo.getRecipientsForCart(cartId);
                Boolean isGroupCart = !(SIB_Util.checkForGroupOrderCart(currCart.CartItems));
                
                if(mapParams.get(SIB_Constants.PARAM_ISORDERFORSOMEONEELSE) == 'true' && groupRecipientsSize == currCart.UniqueProductCount) {
                    isGroupRecipientsMatch = true;
                } else if(isGroupCart == true && groupRecipientsSize == Integer.valueOf(currCart.TotalProductCount)) {
                    isGroupRecipientsMatch = true;
                } else if(mapParams.get(SIB_Constants.PARAM_ISORDERFORSOMEONEELSE) == 'false' && isGroupCart == false && groupRecipientsSize == 0) {
                    isGroupRecipientsMatch = true;
                }
                mapParams.put(SIB_Constants.PARAM_ISGROUPRECIPIENTSMATCH, isGroupRecipientsMatch);
            }
        }
        return mapParams;
    }
}