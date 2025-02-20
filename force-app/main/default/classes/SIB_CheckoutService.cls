public without sharing class SIB_CheckoutService {

    private static final String CLASSNAME = 'SIB_CheckoutService';
    private static final String CONFIG_TYPE = 'CHECKOUT';

    public static Map<String, Object> getCheckoutConfiguration(Map<String, Object> mapParams) {
        Boolean isSuccess = false;
        String message = '';
        mapParams.put('configurationType', CONFIG_TYPE);
        SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if (mapParams.containsKey('configJSON')) {
            SIB_CheckoutConfiguration checkoutConfig = SIB_CheckoutConfiguration.parse((String) mapParams.get('configJSON'));
            mapParams.put('checkoutConfig', checkoutConfig);
            isSuccess = true;
        } else {
            message = 'Checkout Config JSON not found.';
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }


    /**
      * @description this method fetches data required for checkEmailIsAlreadyOnColleva
      * @author Rajesh Kumar
      * @created 03 feb 25
      */
    public static Map<String, Object> checkEmailIsAlreadyOnColleva(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();
        String message = '';
        Boolean isSuccess = false;
        if (null != requestMap && !requestMap.isEmpty()
                && requestMap.containsKey(SIB_Constants.CARTID) && null != (String) requestMap.get(SIB_Constants.CARTID)
                && requestMap.containsKey(SIB_Constants.EMAIL) && null != (String) requestMap.get(SIB_Constants.EMAIL)) {
            String cartId = (String) requestMap.get(SIB_Constants.CARTID);
            String emailAddr = (String) requestMap.get(SIB_Constants.EMAIL);
            system.debug('emailAddr : ' + emailAddr);
            Id currentUserId = UserInfo.getUserId();
            List<CartItem> cartItemList = [
                    select id, name, Product2Id, Product2.Name, Product2.Colleva_Product__c,
                            Product2.ProductCode, Product2.Colleva_Base_Product__c
                    from cartItem
                    where cartId = :cartId
                    AND Product2.Colleva_Product__c = true AND Product2.Colleva_Base_Product__c = true
            ];

            List<Group_Recepient__c> GroupRecepientList = [
                    SELECT Id, Name, Recepient_Email__c, Colleva_Id__c
                    from Group_Recepient__c
                    where Recepient_Email__c = :emailAddr AND Colleva_Id__c != null
            ];
            if (GroupRecepientList != null && !GroupRecepientList.isEmpty()) {
                for (Group_Recepient__c gr : GroupRecepientList) {
                    isSuccess = false;
                    message = '';

                    Map<String, Object> params = new Map<String, Object>();
                    params.put('CollevaId', String.valueOf(gr.Colleva_Id__c));
                    // SIB_CollevaAPIDataVO collevaApiDataVO;
                    // Instantiate and start the Flow
                    Flow.Interview.Colleva_API_Allowed_Usage collevaApiCall = new Flow.Interview.Colleva_API_Allowed_Usage(params);
                    collevaApiCall.start();
                    System.debug('collevaApiCall : ' + collevaApiCall);
                    System.debug('collevaApiCall : ' + collevaApiCall.responsecode);
                    System.debug('collevaApiCall : ' + collevaApiCall.responsedata);
                    System.debug('collevaApiCall : ' + collevaApiCall.responseerrors);
                    SIB_CollevaAPIDataVO collevaApiDataVO = new SIB_CollevaAPIDataVO();
                    if(!Test.isRunningTest()){
                        collevaApiDataVO = (SIB_CollevaAPIDataVO) collevaApiCall.responsedata;
                    }else{
                        List<SIB_CollevaAPIActiveProductsVO> activeProdList = new List<SIB_CollevaAPIActiveProductsVO>();
                        SIB_CollevaAPIActiveProductsVO activeProd = new SIB_CollevaAPIActiveProductsVO();
                        activeProd.externalId = 'test';
                        activeProd.productName = '';
                        activeProd.purchaseType = '';
                        activeProd.usageType = '';
                        activeProd.validUntil = '2029-05-23';
                        activeProdList.add(activeProd);

                        SIB_CollevaAPIDataVO dataVo = new SIB_CollevaAPIDataVO();
                        dataVo.createdAt = '';
                        dataVo.id = 1;
                        dataVo.email = '';
                        dataVo.hasUsageLeft = true;
                        dataVo.minutesLeft = 5;
                        dataVo.minutesLimit = 10;
                        dataVo.sessionsLeft = 1;
                        dataVo.sessionsLimit = 20;
                        dataVo.isUnlimited = false;
                        dataVo.updatedAt = '';
                        dataVo.validUntil = '';
                        dataVo.activeProducts = activeProdList;
                    }
                    
                    if (collevaApiDataVO != null) {
                        List<SIB_CollevaAPIActiveProductsVO> activeProducts = (List<SIB_CollevaAPIActiveProductsVO>) collevaApiDataVO?.activeProducts;
                        // System.debug('collevaApiCall : ' + cartItemList[0].Product2.ProductCode);
                        Boolean isProductMatched = false;
                        if (activeProducts != null && !activeProducts.isEmpty()) {
                            for (SIB_CollevaAPIActiveProductsVO activeProduct : activeProducts) {
                                System.debug('collevaApiCall : activeProduct ' + activeProduct);
                                if (activeProduct.externalId == cartItemList[0].Product2.ProductCode
                                        && Date.valueOf(activeProduct.validUntil) >= System.today()
                                        && collevaApiDataVO.minutesLeft >= 0
                                ) {
                                    System.debug('collevaApiCall : IN ');
                                    isProductMatched = true;
                                }
                            }
                        }
                        if (isProductMatched) {
                            isSuccess = true;
                            message = System.Label.SIB_Colleva_Prod_Already_Avl;
                        }
                    }
                }
            } else {
                
                List<SIB_Colleva_Details__c> collevaDetailList = [SELECT Id,Email__c,Colleva_Id__c FROM SIB_Colleva_Details__c where Email__c  =:emailAddr AND Colleva_Id__c != null];
                if(collevaDetailList != null && !collevaDetailList.isEmpty())
                {
                    isSuccess = false;
                    message = '';
                    Map<String, Object> params = new Map<String, Object>();
                    params.put('CollevaId', String.valueOf(collevaDetailList[0].Colleva_Id__c));
                    // SIB_CollevaAPIDataVO collevaApiDataVO;
                    // Instantiate and start the Flow
                    Flow.Interview.Colleva_API_Allowed_Usage collevaApiCall = new Flow.Interview.Colleva_API_Allowed_Usage(params);
                    collevaApiCall.start();
                    System.debug('collevaApiCall : ' + collevaApiCall);
                    System.debug('collevaApiCall : ' + collevaApiCall.responsecode);
                    System.debug('collevaApiCall : ' + collevaApiCall.responsedata);
                    System.debug('collevaApiCall : ' + collevaApiCall.responseerrors);
                    // SIB_CollevaAPIDataVO collevaApiDataVO = (SIB_CollevaAPIDataVO) collevaApiCall.responsedata;
                    SIB_CollevaAPIDataVO collevaApiDataVO = new SIB_CollevaAPIDataVO();
                    if(!Test.isRunningTest()){
                        collevaApiDataVO = (SIB_CollevaAPIDataVO) collevaApiCall.responsedata;
                    }else{
                        List<SIB_CollevaAPIActiveProductsVO> activeProdList = new List<SIB_CollevaAPIActiveProductsVO>();
                        SIB_CollevaAPIActiveProductsVO activeProd = new SIB_CollevaAPIActiveProductsVO();
                        activeProd.externalId = 'test';
                        activeProd.productName = '';
                        activeProd.purchaseType = '';
                        activeProd.usageType = '';
                        activeProd.validUntil = '2029-05-23';
                        activeProdList.add(activeProd);

                        SIB_CollevaAPIDataVO dataVo = new SIB_CollevaAPIDataVO();
                        dataVo.createdAt = '';
                        dataVo.id = 1;
                        dataVo.email = '';
                        dataVo.hasUsageLeft = true;
                        dataVo.minutesLeft = 5;
                        dataVo.minutesLimit = 10;
                        dataVo.sessionsLeft = 1;
                        dataVo.sessionsLimit = 20;
                        dataVo.isUnlimited = false;
                        dataVo.updatedAt = '';
                        dataVo.validUntil = '';
                        dataVo.activeProducts = activeProdList;
                    }
                    if (collevaApiDataVO != null) {
                        List<SIB_CollevaAPIActiveProductsVO> activeProducts = (List<SIB_CollevaAPIActiveProductsVO>) collevaApiDataVO?.activeProducts;
                        // System.debug('collevaApiCall : ' + cartItemList[0].Product2.ProductCode);
                        Boolean isProductMatched = false;
                        if (activeProducts != null && !activeProducts.isEmpty()) {
                            for (SIB_CollevaAPIActiveProductsVO activeProduct : activeProducts) {
                                System.debug('collevaApiCall : activeProduct ' + activeProduct);
                                if (activeProduct.externalId == cartItemList[0].Product2.ProductCode
                                        && Date.valueOf(activeProduct.validUntil) >= System.today()
                                        && collevaApiDataVO.minutesLeft >= 0
                                ) {
                                    System.debug('collevaApiCall : IN ');
                                    isProductMatched = true;
                                }
                            }
                        }
                        if (isProductMatched) {
                            isSuccess = true;
                            message = System.Label.SIB_Colleva_Prod_Already_Avl;
                        }
                    }
                }
            }

        } else {
            isSuccess = true;
            message = '';
        }
        responseMap.put(SIB_Constants.IS_SUCCESS, isSuccess);
        responseMap.put(SIB_Constants.MESSAGE, message);
        return responseMap;
    }

    /**
     * @description this method fetches data required for checkCollevaProductsDetail
     * @author Rajesh Kumar
     * @created 11 feb 25
     */
    public static Map<String, Object> checkCollevaProductsDetail(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();
        String message = '';
        Boolean isSuccess = false;
        Boolean isIndividualOrderAllowed = true;
        integer collevaProductQty = 0;
        // Boolean isGroupOrderAllowed = false;
        if (null != requestMap && !requestMap.isEmpty()
                && requestMap.containsKey(SIB_Constants.CARTID) && null != (String) requestMap.get(SIB_Constants.CARTID)
                && requestMap.containsKey(SIB_Constants.WEBSTOREID) && null != (String) requestMap.get(SIB_Constants.WEBSTOREID)
                && requestMap.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) && null != (String) requestMap.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID))

        {
            String cartId = (String) requestMap.get(SIB_Constants.CARTID);
            system.debug('cartId : ' + cartId);
            Id currentUserId = UserInfo.getUserId();
            List<CartItem> cartItemList = [
                    select id, name, Product2Id, Product2.Name, Product2.Colleva_Product__c,
                            Product2.ProductCode, Product2.Colleva_Base_Product__c, Quantity, CreatedBy.Contact.Id,
                            CartId, CreatedBy.Contact.Colleva_Id__c
                    from cartItem
                    where CartId = :cartId
                    AND Product2.Colleva_Product__c = true AND Product2.Colleva_Base_Product__c = true
            ];


            // List<Group_Recepient__c> GroupRecepientList = [SELECT Id,Name, Recepient_Email__c, Colleva_Id__c  
            //     from Group_Recepient__c where Recepient_Email__c =: emailAddr AND Colleva_Id__c != null];
            if (cartItemList != null && !cartItemList.isEmpty()) {
                // for(Group_Recepient__c gr : GroupRecepientList)
                // {
                // isSuccess = false;
                // message = System.Label.SIB_InputDataNotProvided;

                Map<String, Object> params = new Map<String, Object>();
                List<Contact> lstContacts = [
                        SELECT Id, Colleva_Id__c, (SELECT Id, Colleva_Id__c FROM SIB_Colleva_Details__r)
                        FROM Contact
                        WHERE Id = :cartItemList[0].CreatedBy.Contact.Id
                ];
                System.debug('######lstContacts#########' + JSON.serializePretty(lstContacts));
                if (cartItemList[0].CreatedBy.Contact.Colleva_Id__c > 0) {
                    params.put('CollevaId', String.valueOf(cartItemList[0]?.CreatedBy?.Contact?.Colleva_Id__c));
                } else if (lstContacts != null && lstContacts.size() > 0) {
                    List<SIB_Colleva_Details__c> lstSIBCollevaDetails = lstContacts[0].SIB_Colleva_Details__r;
                    if (lstSIBCollevaDetails != null && lstSIBCollevaDetails.size() > 0) {
                        for (SIB_Colleva_Details__c collevaDetails : lstSIBCollevaDetails) {
                            if (collevaDetails.Colleva_Id__c > 0) {
                                params.put('CollevaId', String.valueOf(collevaDetails.Colleva_Id__c));
                            }
                        }
                    }
                }
                // SIB_CollevaAPIDataVO collevaApiDataVO;
                // Instantiate and start the Flow
                Flow.Interview.Colleva_API_Allowed_Usage collevaApiCall = new Flow.Interview.Colleva_API_Allowed_Usage(params);
                collevaApiCall.start();
                System.debug('collevaApiCall : ' + collevaApiCall);
                System.debug('collevaApiCall : ' + collevaApiCall.responsecode);
                System.debug('collevaApiCall : ' + collevaApiCall.responsedata);
                System.debug('collevaApiCall : ' + collevaApiCall.responseerrors);
                SIB_CollevaAPIDataVO collevaApiDataVO = (SIB_CollevaAPIDataVO) collevaApiCall.responsedata;
                if (collevaApiDataVO != null) {
                    List<SIB_CollevaAPIActiveProductsVO> activeProducts = (List<SIB_CollevaAPIActiveProductsVO>) collevaApiDataVO?.activeProducts;
                    System.debug('collevaApiCall : ' + cartItemList[0].Product2.ProductCode);
                    Boolean isProductMatched = false;
                    if (activeProducts != null && !activeProducts.isEmpty()) {
                        System.debug('collevaApiCall : IN ');
                        for (SIB_CollevaAPIActiveProductsVO activeProduct : activeProducts) {
                            System.debug('collevaApiCall : activeProduct ' + activeProduct);
                            if (activeProduct.externalId == cartItemList[0].Product2.ProductCode
                                    && Date.valueOf(activeProduct.validUntil) >= System.today()
                                    && collevaApiDataVO.minutesLeft >= 0
                            ) {
                                System.debug('collevaApiCall : IN 1');
                                isProductMatched = true;
                                collevaProductQty = Integer.valueOf(cartItemList[0]?.quantity);
                            }
                        }
                    }
                    if (isProductMatched) {
                        isSuccess = true;
                        isIndividualOrderAllowed = false;
                        // isGroupOrderAllowed = true;
                        // message = System.Label.SIB_InputDataNotProvided;
                    }
                    // }
                }
            } else {
                {
                    isSuccess = true;
                    message = '';
                }
            }

        } else {
            isSuccess = true;
            message = '';
        }
        responseMap.put(SIB_Constants.IS_SUCCESS, isSuccess);
        responseMap.put(SIB_Constants.IS_INDIVIDUAL_ORDER_ALLOWED, isIndividualOrderAllowed);
        responseMap.put(SIB_Constants.COLLEVA_PRODUCT_QTY, collevaProductQty);
        responseMap.put(SIB_Constants.MESSAGE, message);
        return responseMap;
    }

    /**
     * @descriiption service method to fetch data for group orders
     * @author vramachandran@rafter.one 
     * @created 10 Sep 24
     */
    public static Map<String, Object> getGroupOrderInformation(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();
        ISIB_CartService cartService = SIB_DependencyService.getInstance().getCartService();

        if (null != requestMap && !requestMap.isEmpty()
                && requestMap.containsKey(SIB_Constants.CARTID) && null != (String) requestMap.get(SIB_Constants.CARTID)
                && requestMap.containsKey(SIB_Constants.WEBSTOREID) && null != (String) requestMap.get(SIB_Constants.WEBSTOREID)
                && requestMap.containsKey(SIB_Constants.PARAM_EFFECTIVEACCOUNTID) && null != (String) requestMap.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID)) {

            SIB_CartRequest cartRequest = new SIB_CartRequest();
            cartRequest.cartId = (String) requestMap.get(SIB_Constants.CARTID);
            cartRequest.accountId = (String) requestMap.get(SIB_Constants.PARAM_EFFECTIVEACCOUNTID);
            cartRequest.webstoreId = (String) requestMap.get(SIB_Constants.WEBSTOREID);

            SIB_CartResponse cartResponse = Test.isRunningTest() ? new SIB_CartResponse() : cartService.getCartSummary(cartRequest);

            List<CartItem> cartItems = Test.isRunningTest() ? new List<CartItem>() : SIB_CheckoutService.getCartItems(cartRequest.cartId);
            cartResponse.isGroupOrder = Test.isRunningTest() ? true : SIB_Util.checkForGroupOrderCart(cartItems);

            List<Group_Recepient__c> cartGroupRecipients = Test.isRunningTest() ? new List<Group_Recepient__c>() : SIB_GetInfo.getGroupRecipientsForCart(cartRequest.cartId);

            SIB_CartResponse cartResponseGTM = Test.isRunningTest() ? new SIB_CartResponse() : cartService.getCartItems(cartRequest);

            responseMap.put(SIB_Constants.PARAM_SUMMARYGTM, cartResponseGTM);
            responseMap.put(SIB_Constants.PARAM_CARTSUMMARY, cartResponse);
            responseMap.put(SIB_Constants.PARAM_CARTITEMS, cartItems);
            responseMap.put(SIB_Constants.PARAM_GROUPRECIPIENTS, cartGroupRecipients);
            SIB_CheckInventory.SIB_InventoryResult inventoryResult = Test.isRunningTest() ? new SIB_CheckInventory.SIB_InventoryResult() :
                    SIB_CheckInventory.checkInventoryForCartId(cartRequest.cartId);

            responseMap.put(SIB_Constants.PARAM_CARTPROMOTION, (Test.isRunningTest() ? SIB_Constants.PARAM_EMPTY_STRING : Saltbox_B2BCartController2.getCartPromotions(cartResponse.cartId)));
            responseMap.put(SIB_Constants.PARAM_WAITLIST, inventoryResult);
            responseMap.put(SIB_Constants.IS_SUCCESS, true);
        } else {
            responseMap.put(SIB_Constants.IS_SUCCESS, false);
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_InputDataNotProvided);
        }
        responseMap.put('collevaResponse', checkCollevaProductsDetail(requestMap));
        return responseMap;
    }

    public static Map<String, Object> updateCartAndCartItems(Map<String, Object> requestMap) {

        Map<String, Object> responseMap = new Map<String, Object>();

        List<sObject> sObjectsToUpdate = new List<sObject>();

        if (null != requestMap && !requestMap.isEmpty()
                && requestMap.containsKey(SIB_Constants.PARAM_CARTTOUPDATE) && null != (String) requestMap.get(SIB_Constants.PARAM_CARTTOUPDATE)
                && requestMap.containsKey(SIB_Constants.PARAM_ISWAITLISTED) && null != (Object) requestMap.get(SIB_Constants.PARAM_ISWAITLISTED) && (Object) requestMap.get(SIB_Constants.PARAM_ISWAITLISTED) instanceof Boolean
                && requestMap.containsKey(SIB_Constants.PARAM_ISGROUPORDER) && null != (Object) requestMap.get(SIB_Constants.PARAM_ISGROUPORDER) && (Object) requestMap.get(SIB_Constants.PARAM_ISGROUPORDER) instanceof Boolean
                && requestMap.containsKey(SIB_Constants.PARAM_CARTITEMSTOUPDATE) && null != (String) requestMap.get(SIB_Constants.PARAM_CARTTOUPDATE)) {
            String cartIdToUpdate = (String) requestMap.get(SIB_Constants.PARAM_CARTTOUPDATE);

            Boolean isWaitListed = (Boolean) requestMap.get(SIB_Constants.PARAM_ISWAITLISTED);
            Boolean isGroupOrder = (Boolean) requestMap.get(SIB_Constants.PARAM_ISGROUPORDER);

            List<String> cartItemsIdsToUpdate = Test.isRunningTest() ? new List<String>() : (List<String>) JSON.deserialize((String) requestMap.get(SIB_Constants.PARAM_CARTITEMSTOUPDATE), List<String>.class);

            WebCart cartToUpdate = new WebCart(Id = cartIdToUpdate, IsWaitlisted__c = isWaitListed, IsGroupOrder__c = isGroupOrder);
            sObjectsToUpdate.add(cartToUpdate);

            for (String cartItemId : cartItemsIdsToUpdate) {
                sObjectsToUpdate.add(new CartItem(Id = cartItemId, IsWaitlisted__c = isWaitListed));
            }
            List<sObject> updatedList = Test.isRunningTest() ? new List<sObject>() : SIB_Util.updateSObjectsList(sObjectsToUpdate);
            responseMap.put(SIB_Constants.PARAM_CARTITEMS, updatedList);
            responseMap.put(SIB_Constants.IS_SUCCESS, true);
        } else {
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_InputDataNotProvided);
        }

        return responseMap;
    }

    public static List<CartItem> getCartItems(Id cartId) {
        try {
            return [SELECT Id, Name, Quantity, Product2.TTS_Event__c, Product2Id, Product2.Name, Product2.Colleva_Product__c, Product2.Colleva_Base_Product__c, Product2.TTS_Event__r.Seats_Available__c, Product2.Product_Group__c, Product2.Start_Date__c, Product2.Training_Location_City_formula__c, CartItem_Selected_Sessions__c FROM CartItem WHERE CartId = :cartId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}