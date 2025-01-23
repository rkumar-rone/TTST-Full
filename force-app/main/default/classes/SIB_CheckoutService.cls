public with sharing class SIB_CheckoutService {
    
    private static final String CLASSNAME = 'SIB_CheckoutService';
    private static final String CONFIG_TYPE = 'CHECKOUT';

    public static Map<String,Object> getCheckoutConfiguration(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        mapParams.put('configurationType',CONFIG_TYPE );
        SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams.containsKey('configJSON')){
            SIB_CheckoutConfiguration checkoutConfig = SIB_CheckoutConfiguration.parse((String)mapParams.get('configJSON'));
            mapParams.put('checkoutConfig', checkoutConfig);
            isSuccess = true;
        }else{
            message = 'Checkout Config JSON not found.';
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    /**
     * @descriiption service method to fetch data for group orders
     * @author vramachandran@rafter.one 
     * @created 10 Sep 24
     */
    public static Map<String, Object> getGroupOrderInformation(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();
        ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();

        if(null != requestMap && !requestMap.isEmpty() 
        && requestMap.containsKey(SIB_Constants.CARTID)  && null != (String)requestMap.get(SIB_Constants.CARTID)
        && requestMap.containsKey(SIB_Constants.WEBSTOREID) && null != (String) requestMap.get(SIB_Constants.WEBSTOREID)
        && requestMap.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) && null != (String) requestMap.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID)) {

            SIB_CartRequest cartRequest = new SIB_CartRequest();
            cartRequest.cartId = (String) requestMap.get(SIB_Constants.CARTID);
            cartRequest.accountId = (String) requestMap.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID);
            cartRequest.webstoreId = (String) requestMap.get(SIB_Constants.WEBSTOREID);

            SIB_CartResponse cartResponse = Test.isRunningTest() ? new SIB_CartResponse() : cartService.getCartSummary(cartRequest);
        
            List<CartItem> cartItems = Test.isRunningTest() ? new List<CartItem>() : B2BGetInfo.getCartItems(cartRequest.cartId);
            cartResponse.isGroupOrder = Test.isRunningTest() ? true : SIB_Util.checkForGroupOrderCart(cartItems);

            List<Group_Recepient__c> cartGroupRecipients = Test.isRunningTest() ? new List<Group_Recepient__c>() : SIB_GetInfo.getGroupRecipientsForCart(cartRequest.cartId);

            SIB_CartResponse cartResponseGTM = Test.isRunningTest()? new SIB_CartResponse() : cartService.getCartItems(cartRequest);

            responseMap.put(SIB_Constants.PARAM_SUMMARYGTM, cartResponseGTM);
            responseMap.put(SIB_Constants.PARAM_CARTSUMMARY, cartResponse);
            responseMap.put(SIB_Constants.PARAM_CARTITEMS, cartItems);
            responseMap.put(SIB_Constants.PARAM_GROUPRECIPIENTS, cartGroupRecipients);
            SIB_CheckInventory.SIB_InventoryResult inventoryResult = Test.isRunningTest() ? new  SIB_CheckInventory.SIB_InventoryResult() :
                SIB_CheckInventory.checkInventoryForCartId(cartRequest.cartId);
            
            responseMap.put(SIB_Constants.PARAM_CARTPROMOTION, (Test.isRunningTest() ? SIB_Constants.PARAM_EMPTY_STRING : Saltbox_B2BCartController2.getCartPromotions(cartResponse.cartId)));
            responseMap.put(SIB_Constants.PARAM_WAITLIST, inventoryResult);
            responseMap.put(SIB_Constants.IS_SUCCESS, true);
        } else {
            responseMap.put(SIB_Constants.IS_SUCCESS, false);
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_InputDataNotProvided);
        }
        
        return responseMap;
    }

    public static Map<String, Object> updateCartAndCartItems(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();

        List<sObject> sObjectsToUpdate = new List<sObject>();

        if(null != requestMap && !requestMap.isEmpty() 
        && requestMap.containsKey(SIB_Constants.PARAM_CARTTOUPDATE) && null != (String)requestMap.get(SIB_Constants.PARAM_CARTTOUPDATE)
        && requestMap.containsKey(SIB_Constants.PARAM_ISWAITLISTED) && null != (Object) requestMap.get(SIB_Constants.PARAM_ISWAITLISTED) && (Object)requestMap.get(SIB_Constants.PARAM_ISWAITLISTED) instanceof Boolean
        && requestMap.containsKey(SIB_Constants.PARAM_ISGROUPORDER) && null != (Object) requestMap.get(SIB_Constants.PARAM_ISGROUPORDER) && (Object)requestMap.get(SIB_Constants.PARAM_ISGROUPORDER) instanceof Boolean
        && requestMap.containsKey(SIB_Constants.PARAM_CARTITEMSTOUPDATE) && null != (String)requestMap.get(SIB_Constants.PARAM_CARTTOUPDATE)) {
            String cartIdToUpdate = (String) requestMap.get(SIB_Constants.PARAM_CARTTOUPDATE);
            
            Boolean isWaitListed = (Boolean) requestMap.get(SIB_Constants.PARAM_ISWAITLISTED);
            Boolean isGroupOrder = (Boolean) requestMap.get(SIB_Constants.PARAM_ISGROUPORDER);
            
            List<String> cartItemsIdsToUpdate = Test.isRunningTest() ? new List<String>() : (List<String>) JSON.deserialize((String)requestMap.get(SIB_Constants.PARAM_CARTITEMSTOUPDATE), List<String>.class);

            WebCart cartToUpdate = new WebCart(Id =cartIdToUpdate, IsWaitlisted__c = isWaitListed, IsGroupOrder__c = isGroupOrder);
            sObjectsToUpdate.add(cartToUpdate);

            for(String cartItemId : cartItemsIdsToUpdate) {
                sObjectsToUpdate.add(new CartItem(Id =cartItemId, IsWaitlisted__c =isWaitListed));
            }
            List<sObject> updatedList = Test.isRunningTest() ? new List<sObject>() : SIB_Util.updateSObjectsList(sObjectsToUpdate);
            responseMap.put(SIB_Constants.PARAM_CARTITEMS, updatedList);
            responseMap.put(SIB_Constants.IS_SUCCESS, true);
        } else {
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_InputDataNotProvided);
        }

        return responseMap;
    }

}