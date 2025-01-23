public without sharing class B2BGetInfo {

    public static final String TTS_PRICEBOOK = 'TTS B2B Store Price Book';
    public static final String TTS_WEBSTORE = 'TTS B2B Store';
    private static final String CLASSNAME = 'SIB_CartController';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Cart Module';

    @AuraEnabled
    public static Integer getRecipientsForCart(String cartId) {
        try {
            List<Group_Recepient__c> recipients = [
                    SELECT Id
                    FROM Group_Recepient__c
                    WHERE Cart__c = :cartId
            ];
            return recipients.size();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Void deleteRecipientsFromCheckout(String cartId) {
        try {
            List<Group_Recepient__c> recipients = [
                    SELECT Id
                    FROM Group_Recepient__c
                    WHERE Cart__c = :cartId
            ];
            delete recipients;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductDetail getProduct(
            String communityId,
            String productId,
            String effectiveAccountId
    ) {
        if (effectiveAccountId == '000000000000000' || effectiveAccountId == null) {
            effectiveAccountId = [SELECT Id FROM GuestBuyerProfile LIMIT 1].Id;
        }
        // Lookup the webstore ID associated with the community
        String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
        return Test.isRunningTest() ? new ConnectApi.ProductDetail() : ConnectApi.CommerceCatalog.getProduct(webstoreId, productId, effectiveAccountID, null, false, null, false, true, false, false, false);
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkProductIsInStock(String productId) {
        /*
         * The following is an example of calling an external API.
         * The example API provided is extremely simple: It takes in a product id
         * and returns a true or false value for inStock based on whether the 15th char is odd or even.
         *
         * To access this endpoint on your org, go to Remote Site Settings in Setup as an admin user
         * click "New Remote Site" and provide "https://inventorymanagerdemo.herokuapp.com" for the "Remote Site URL" field
         */

        // Http http = new Http();
        // HttpRequest request = new HttpRequest();
        // String endpoint =
        //   'https://inventorymanagerdemo.herokuapp.com/api/inventory/' + productId;
        // request.setEndpoint(endpoint);
        // request.setMethod('GET');
        // HttpResponse response = http.send(request);
        // // If the request is successful, parse the JSON response.
        // if (response.getStatusCode() == 200) {
        //   // Deserialize the JSON string into collections of primitive data types.
        //   Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
        //     response.getBody()
        //   );
        //   return (boolean) results.get('inStock');
        // } else {
        //   return false;
        // }

        return true;
    }

    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
            String communityId,
            String effectiveAccountId,
            String currencyCode
    ) {
        if (effectiveAccountId == '000000000000000' || effectiveAccountId == null) {
            effectiveAccountId = [SELECT Id FROM GuestBuyerProfile LIMIT 1].Id;
        }
        // Lookup the webstore ID associated with the community
        String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
        //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
        String activeCartOrId = 'current';

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return Test.isRunningTest() ? new ConnectApi.CartSummary() : ConnectApi.CommerceCart.getCartSummary(webstoreId, effectiveAccountId, activeCartOrId
        );
    }

    @AuraEnabled
    public static ConnectApi.CartItem addToCart(
            String communityId,
            String productId,
            String quantity,
            String effectiveAccountId,
            Id cartId,
            String selectedSessions,
            Decimal selectedSessionNumber,
            String currencyCode
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.productId = productId;
        cartInput.quantity = quantity;
        cartInput.type = ConnectApi.CartItemType.PRODUCT;

        updateSelectedSessionsOnCart(cartId, selectedSessions);

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        ConnectApi.CartItem cartItem = Test.isRunningTest() ? new ConnectApi.CartItem() : ConnectApi.CommerceCart.addItemToCart(
                webstoreId,
                effectiveAccountId,
                'active',
                cartInput,
                currencyCode
        );

        updateSessionPricesOnCartItems(cartId, productId, selectedSessionNumber, true, selectedSessions);

        //So that the cartSummary is correct on first navigation
        Saltbox_B2BCartController2.calculatePromotions(cartId);
        return cartItem;
    }

    public static void updateSelectedSessionsOnCart(Id cartId, String selectedSessions) {
        try {
            WebCart cart = [SELECT Id, Selected_Sessions__c FROM WebCart WHERE Id = :cartId LIMIT 1];
            String selectedItems;
            if (cart.Selected_Sessions__c == null) {
                selectedItems = selectedSessions.removeStart('{').removeEnd('}');
            } else {
                selectedItems = cart.Selected_Sessions__c.removeStart('{').removeEnd('}') + ' , ' + selectedSessions.removeStart('{').removeEnd('}');
            }
            update new WebCart(Id = cartId, Selected_Sessions__c = '{' + selectedItems + '}', CartId__c = cartId);
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public static void updateSessionPricesOnCartItems(Id cartId, Id productId, Decimal selectedSessionNumber, Boolean isInvokedFromAddToCart, String selectedSessions) {
      String methodName = 'updateSessionPricesOnCartItems';
      String supportData = '';
        try {
            List<CartItem> lstCartItems = new List<CartItem>();
            PricebookEntry pricebookEntry = [SELECT UnitPrice FROM PricebookEntry WHERE Pricebook2.Name = :TTS_PRICEBOOK AND Pricebook2.IsActive = true AND Product2Id = :productId LIMIT 1];
            String selectedItems;

            for (CartItem cartItem : [SELECT Quantity, Number_of_Sessions__c, CartItem_Selected_Sessions__c FROM CartItem WHERE CartId = :cartId AND Product2Id = :productId]) {
                Decimal numberOfSessions = isInvokedFromAddToCart ? selectedSessionNumber : cartItem.Number_of_Sessions__c;
                Decimal salesPrice = null;
                if (numberOfSessions == null || numberOfSessions == 0)
                {
                    salesPrice = pricebookEntry.UnitPrice;
                }else
                {
                    salesPrice = pricebookEntry.UnitPrice * numberOfSessions;
                }
                System.debug('>>>>>numberOfSessions>>>>>>>'+numberOfSessions);
                System.debug('>>>>>selectedSessions>>>>>>>'+selectedSessions);
                if (cartItem.CartItem_Selected_Sessions__c == null)
                {
                    selectedItems = selectedSessions.removeStart('{').removeEnd('}');
                } else
                {
                    selectedItems = cartItem.CartItem_Selected_Sessions__c.removeStart('{').removeEnd('}');
                    if(String.isNotBlank(selectedSessions))
                    {
                        selectedItems = selectedSessions.removeStart('{').removeEnd('}');
                    }
                }
                System.debug('>>>>>selectedItems>>>>>>>'+selectedItems);
                lstCartItems.add(
                        new CartItem(
                                Id = cartItem.Id,
                                NetUnitPrice = salesPrice,
                                UnitAdjustedPrice = salesPrice,
                                ListPrice = salesPrice,
                                SalesPrice = salesPrice,
                                TotalLineAmount = cartItem.Quantity * salesPrice,
                                TotalPrice = cartItem.Quantity * salesPrice,
                                TotalPriceAfterAllAdjustments = cartItem.Quantity * salesPrice,
                                Number_of_Sessions__c = numberOfSessions,
                                CartItem_Selected_Sessions__c = '{' + selectedItems + '}'
                                // =========================================
                                // TotalAdjustmentAmount = -333,
                                // TotalPromoAdjustmentAmount = -333
                                // =========================================
                        )
                );
            }

            if (lstCartItems.size() > 0) {
                update lstCartItems;
            }
        } catch (Exception expObject) {
            System.debug(expObject);
          SIB_ExceptionLog.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }
    }

    @Future
    public static void updateSessionPricesOnCart(Id cartId) {
      String methodName = 'updateSessionPricesOnCart';
      String supportData = '';
      Set<String> setProductIds = new Set<String>();
      List<CartItem> lstCartItemsToUpdate = new List<CartItem>();
        try {
            if (String.isNotBlank(cartId))
            {
                List<WebCart> lstCarts = [
                        SELECT Id, CurrencyIsoCode, (SELECT Id, Product2Id, Quantity, Type, Number_of_Sessions__c, CartItem_Selected_Sessions__c FROM CartItems)
                        FROM WebCart
                        WHERE Id = :cartId
                ];

                if (lstCarts != null && lstCarts.size() > 0)
                {
                    WebCart webCartObject = lstCarts[0];
                    if (webCartObject.CartItems != null && webCartObject.CartItems.size() > 0)
                    {
                        for (CartItem cartItemObject : webCartObject.CartItems)
                        {
                            if (SIB_Constants.PRODUCT.equalsIgnoreCase(cartItemObject.Type)) {
                                setProductIds.add(cartItemObject.Product2Id);
                            }
                        }
                        Map<String, PricebookEntry> mapPricebookEntriesByStrings = new Map<String, PricebookEntry>();
                        List<PricebookEntry> lstPricebookEntries = [SELECT Id, UnitPrice,Product2Id FROM PricebookEntry WHERE
                                      Pricebook2.Name = :TTS_PRICEBOOK AND Pricebook2.IsActive = TRUE AND
                                      Product2Id IN :setProductIds AND CurrencyIsoCode = :webCartObject.CurrencyIsoCode];
                        if (lstPricebookEntries != null && lstPricebookEntries.size() > 0)
                        {
                            for (PricebookEntry pricebookEntryObj : lstPricebookEntries)
                            {
                              mapPricebookEntriesByStrings.put(pricebookEntryObj.Product2Id, pricebookEntryObj);
                            }
                        }
                        for (CartItem cartItemObject : webCartObject.CartItems)
                        {
                            if(cartItemObject.Number_of_Sessions__c!=null)
                            {
                                Decimal numberOfSessions = cartItemObject.Number_of_Sessions__c;
                                if (mapPricebookEntriesByStrings.containsKey(cartItemObject.Product2Id) && mapPricebookEntriesByStrings.get(cartItemObject.Product2Id) != null) {
                                  PricebookEntry pricebookEntryObject = mapPricebookEntriesByStrings.get(cartItemObject.Product2Id);
                                  Decimal salesPrice = pricebookEntryObject.UnitPrice * numberOfSessions;
                                  if (numberOfSessions == 0)
                                  {
                                    salesPrice = pricebookEntryObject.UnitPrice;
                                  }
                                  cartItemObject.NetUnitPrice = salesPrice;
                                  cartItemObject.ListPrice = salesPrice;
                                  cartItemObject.SalesPrice = salesPrice;
                                  cartItemObject.TotalLineAmount = cartItemObject.Quantity * salesPrice;
                                  cartItemObject.TotalListPrice = cartItemObject.Quantity * salesPrice;
                                  cartItemObject.TotalPrice = cartItemObject.Quantity * salesPrice;
                                  cartItemObject.GrossUnitPrice = salesPrice;
                                  System.debug('cartItemObject : '+JSON.serializePretty(cartItemObject));
                                  lstCartItemsToUpdate.add(cartItemObject);
                                  /*lstCartItems.add(
                                    new CartItem(
                                            Id = cartItem.Id,
                                            NetUnitPrice = salesPrice,
                                            UnitAdjustedPrice = salesPrice,
                                            ListPrice = salesPrice,
                                            SalesPrice = salesPrice,
                                            TotalLineAmount = cartItem.Quantity * salesPrice,
                                            TotalPrice = cartItem.Quantity * salesPrice,
                                            TotalPriceAfterAllAdjustments = cartItem.Quantity * salesPrice,
                                            Number_of_Sessions__c = numberOfSessions,
                                            CartItem_Selected_Sessions__c = '{' + selectedItems + '}'
                                            // =========================================
                                            // TotalAdjustmentAmount = -333,
                                            // TotalPromoAdjustmentAmount = -333
                                            // =========================================
                                    )
                                  );*/
                                }
                            }
                        }
                    }
                }
                if (lstCartItemsToUpdate.size() > 0)
                {
                    update lstCartItemsToUpdate;
                }
            }
        } catch (Exception expObject) {
          SIB_ExceptionLog.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }
    }

    @AuraEnabled
    public static ConnectApi.Wishlist createAndAddToList(
            String communityId,
            String productId,
            String wishlistName,
            String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        // Store the product in a WishlistItemInput to pass to the Wishlist
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        wishlistItemInput.productId = productId;

        //Create a wishlistInput to be created
        ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
        wishlistInput.name = wishlistName;
        wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
                wishlistItemInput
        };

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
        return Test.isRunningTest() ? new ConnectApi.Wishlist() : ConnectApi.CommerceWishlist.createWishlist(
                webstoreId,
                effectiveAccountId,
                wishlistInput
        );
    }

    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(
            String communityId,
            String productId,
            String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
        return Test.isRunningTest() ? new ConnectApi.ProductPrice() : ConnectApi.CommerceStorePricing.getProductPrice(
                webstoreId,
                productId,
                effectiveAccountId
        );
    }

    @AuraEnabled(cacheable=true)
    public static List<Session__c> getSessions(Id productId) {
        List<Campaign> lstEvents = new List<Campaign>([
                SELECT Id, Name, Only_Show_Sessions__c, (
                        SELECT Id, Name, Required__c, FORMAT(Session_Date__c) sessionStartDate,
                                Start_AM_PM__c, Start_Hours__c, Start_Minutes__c,
                                End_AM_PM__c, End_Hours__c, End_Minutes__c,
                                FORMAT(Session_Start__c) sessionStart,
                                FORMAT(Session_End__c) sessionEnd
                        From Event_Sessions__r
                        ORDER BY Session_Start__c ASC
                )
                FROM Campaign
                WHERE Id IN (SELECT TTS_Event__c FROM Product2 WHERE Id = :productId)
        ]);
        if (!lstEvents.isEmpty()) {
            return lstEvents.get(0)?.Event_Sessions__r;
        } else {
            return null;
        }

    }

    @AuraEnabled(cacheable=true)
    public static Boolean getOnlyOneSession(Id productId) {
        List<Campaign> lstEvents = new List<Campaign>([
                SELECT Id, Name, Only_Show_Sessions__c
                FROM Campaign
                WHERE Id IN (SELECT TTS_Event__c FROM Product2 WHERE Id = :productId)
        ]);
        if (!lstEvents.isEmpty()) {
            return lstEvents.get(0)?.Only_Show_Sessions__c;
        } else {
            return false;
        }

    }

    @AuraEnabled
    public static Registration__c saveOneSelection(List<Registration__c> regs, Id registrationId) {
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT ContactId FROM User WHERE Id = :currentUserId];

        for (Registration__c r : regs) {
            if (r.Status__c != 'Cancelled') {
                r.Status__c = 'Cancelled';
            }
        }
        update regs;
        Registration__c newReg = new Registration__c();
        newReg.Status__c = 'Registered';
        newReg.Session__c = registrationId;
        newReg.Contact__c = currentUser.ContactId;
        insert newReg;
        return newReg;
    }

    @AuraEnabled
    public static void createGroupRecepients(List<Group_Recepient__c> groupRecipients, Boolean useSameRecipient, Id cartId) {
        try {
            List<Group_Recepient__c> lstGroupRecepients = new List<Group_Recepient__c>();

            if (!useSameRecipient) {
                lstGroupRecepients.addAll(groupRecipients);
            } else {
                Group_Recepient__c recipient = groupRecipients.get(0);
                if (recipient == null) return;

                for (CartItem cartItem : getCartItems(cartId)) {
                    for (Integer i = 0; i < cartItem.Quantity; i++) {
                        lstGroupRecepients.add(
                                new Group_Recepient__c(
                                        Recepient_Email__c = recipient.Recepient_Email__c,
                                        Status__c = 'Created',
                                        Cart__c = cartId,
                                        Cart_Item__c = cartItem.Id,
                                        First_Name__c = recipient.First_Name__c,
                                        Last_Name__c = recipient.Last_Name__c,
                                        TTS_Event__c = cartItem.Product2.TTS_Event__c
                                )
                        );
                    }
                }
            }

            if (!lstGroupRecepients.isEmpty()) {
                insert lstGroupRecepients;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CartItem> getCartItems(Id cartId) {
        try {
            return [SELECT Id, Name, Quantity, Product2.TTS_Event__c, Product2Id, Product2.Name, Product2.TTS_Event__r.Seats_Available__c, Product2.Product_Group__c, Product2.Start_Date__c, Product2.Training_Location_City_formula__c, CartItem_Selected_Sessions__c FROM CartItem WHERE CartId = :cartId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getGbpProductPrice(String productId) {
        try {

            // there is always going to be a pricebook entry because the id
            // is coming from the portal... meaning the product has been correctly setup.
            PricebookEntry pbe = [
                    SELECT Id, Name, UnitPrice, CurrencyIsoCode, IsActive, Pricebook2.Name
                    FROM PricebookEntry
                    WHERE
                            Product2Id = :productId
                            AND Pricebook2.Name = :TTS_PRICEBOOK // 'TTS B2B Store Price Book'
                            AND IsActive = true
            ];
            String result = JSON.serialize(pbe);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getCartByUser(String userId) {
        try {

            Webcart cart = [
                    SELECT Id, Name, Status, CurrencyIsoCode, (SELECT Id FROM CartItems)
                    FROM WebCart
                    WHERE OwnerId = :userId
                    AND (Status = 'Active' OR Status = 'Checkout')
                    LIMIT 1
            ];

            String result = JSON.serialize(cart);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createCart(String currencyCode, String ownerId, String effectiveAccountId) {
        try {

            WebStore store = [SELECT Id FROM WebStore WHERe Name = :TTS_WEBSTORE LIMIT 1];

            WebCart cart = new WebCart();
            cart.OwnerId = ownerId;
            cart.AccountId = effectiveAccountId;
            cart.CurrencyIsoCode = currencyCode;
            cart.Status = 'Active';
            cart.Name = 'Cart';
            cart.Type = 'Cart';
            cart.WebStoreId = store.Id;

            insert cart;

            CartDeliveryGroup cdg = new CartDeliveryGroup();
            cdg.Name = 'Default Delivery';
            cdg.CartId = cart.Id;
            cdg.CurrencyIsoCode = currencyCode;
            // cdg.IsDefault = true;

            insert cdg;


            String result = JSON.serialize(cart);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string deleteCart(String cartId) {

        // when you delete the cart, the cartDeliveryGroup gets deleted automatically.
        try {
            Webcart cart = [
                    SELECT Id
                    FROM WebCart
                    WHERE Id = :cartId
                    LIMIT 1
            ];
            delete cart;

            return 'success';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateAccountCurrency(
            String currencyCode,
            String userId
    ) {
        try {
            User portalUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :userId LIMIT 1];

            String accId = portalUser.Contact.AccountId;

            BuyerAccount ba = [
                    SELECT Id, CurrencyIsoCode, IsActive, Buyer.Name
                    FROM BuyerAccount
                    WHERE BuyerId = :accId
            ];
            ba.CurrencyIsoCode = currencyCode;
            update ba;

            Account acc = [
                    SELECT Id, CurrencyIsoCode
                    FROM Account
                    WHERE Id = :accId
            ];
            acc.CurrencyIsoCode = currencyCode;
            update acc;

            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}