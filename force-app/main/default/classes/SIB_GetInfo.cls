/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : Gaurav Setia
**/
public without sharing class SIB_GetInfo {

    public static final String TTS_PRICEBOOK = 'TTS B2B Store Price Book';
    public static final String TTS_WEBSTORE = 'TTS B2B Store';
    private static final String CLASSNAME = 'SIB_CartController';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Cart Module';
    
    public static List<Group_Recepient__c> getGroupRecipientsForCart(String cartId) {
        String methodName = 'getGroupRecipientsForCart';
        String supportData = '';
        List<Group_Recepient__c> recipients = new List<Group_Recepient__c>();
        try {
            recipients = [
                    SELECT Id, First_Name__c, Last_Name__c, Recepient_Email__c, Cart_Item__c, Status__c, TTS_Event__c, Cart__c
                    FROM Group_Recepient__c
                    WHERE Cart__c = :cartId
            ];
        } catch (Exception expObject) {
            SIB_ExceptionLog.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }
        return recipients;
    }

    public static List<Session__c> getSessions(Id productId) {
        List<Campaign> lstEvents = new List<Campaign>([
                SELECT Id, Name, Only_Show_Sessions__c, (
                        SELECT Id, Name, Required__c, Session_Date__c, SIB_Session_Date_For_Display__c,
                                Start_AM_PM__c, Start_Hours__c, Start_Minutes__c,
                                End_AM_PM__c, End_Hours__c, End_Minutes__c,
                                Session_Start__c, Session_End__c
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

    @AuraEnabled
    public static List<Group_Recepient__c> createGroupRecepients(List<Group_Recepient__c> groupRecipients, Boolean useSameRecipient, Id cartId) {
        String methodName = 'createGroupRecepients';
        String supportData = '';
        List<Group_Recepient__c> lstGroupRecepients = new List<Group_Recepient__c>();
        try {
            if (!useSameRecipient) {
                lstGroupRecepients.addAll(groupRecipients);
            } else {
                Group_Recepient__c recipient = groupRecipients.get(0);
                if (recipient == null) return lstGroupRecepients;

                for (CartItem cartItem : B2BGetInfo.getCartItems(cartId)) {
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
                upsert lstGroupRecepients;
            }
        } catch (Exception expObject) {
            SIB_ExceptionLog.storeExceptionLog(expObject, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }
        return lstGroupRecepients;
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
                if (cartItem.CartItem_Selected_Sessions__c == null && String.isNotBlank(selectedSessions))
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
}