public with sharing class SIB_CheckInventory {

    public static SIB_InventoryResult checkInventoryForCartId(String cartId) {

        try {
            // Get all SKUs and their quantities from cart items.
            Map<String, Decimal> quantitiesFromSalesforce = new Map<String, Decimal>();
            Map<Id, Id> mapEventIdToProductId = new Map<Id, Id>();
            Map<Id, Id> mapProductIdToCartItemId = new Map<Id, Id>();
            Map<Id, CartItem> mapProducts = new Map<Id, CartItem>();
            for (CartItem cartItem : [SELECT Id, Sku, Quantity, Product2Id, Product2.Name, Product2.TTS_Event__c, Product2.TTS_Event__r.Name FROM CartItem WHERE CartId = :cartId AND Type = :SIB_Constants.PARAM_PRODUCT]) {
                if (String.isBlank(cartItem.Sku)) {
                    String errorMessage = System.Label.SIB_SkusMustBeDefined;
                    return new SIB_InventoryResult(SIB_SetupConstants.CHECK_INV_STATUS.STATUS_FAILED, errorMessage, new List<CartItem>());
                }

                if (cartItem.Product2.TTS_Event__c != null) {
                    quantitiesFromSalesforce.put(cartItem.Product2Id, cartItem.Quantity);
                    mapEventIdToProductId.put(cartItem.Product2.TTS_Event__c, cartItem.Product2Id);
                    mapProductIdToCartItemId.put(cartItem.Product2Id, cartItem.Id);
                    mapProducts.put(cartItem.Id, cartItem);
                }
            }

            // contiune if there are no products that need inventory check
            if (!quantitiesFromSalesforce.isEmpty()) {
                
                // Get all available quantities for products in the cart (cart items) from an external service.
                Map<String, Object> quantitiesFromExternalService = getAvailableQuantitiesFromEvents(quantitiesFromSalesforce.keySet(), mapEventIdToProductId);
                SIB_InventoryResult result = new SIB_InventoryResult('', '', new List<CartItem>());
                Boolean isWaitlisted = false;
                // For each cart item SKU, check that the quantity from the external service
                // is greater or equal to the quantity in the cart.
                // If that is not true, set the integration status to "Failed".
                for (String productIds : quantitiesFromSalesforce.keySet()) {
                    Decimal quantityFromSalesforce = quantitiesFromSalesforce.get(productIds);
                    Decimal quantityFromExternalService = (Decimal)quantitiesFromExternalService.get(productIds);
                    if (quantityFromExternalService == null){
                        String errorMessage = SIB_SetupConstants.CHK_INV_PRODINV_PREFIX + productIds + SIB_SetupConstants.CHK_INV_PRODINV_SUFFIX;
                        return new SIB_InventoryResult(SIB_SetupConstants.CHECK_INV_STATUS.STATUS_FAILED, errorMessage, mapProducts.get(productIds));
                    }
                    else if (quantityFromExternalService < quantityFromSalesforce){
                        isWaitlisted = true;
                        result.status = SIB_SetupConstants.CHECK_INV_STATUS.STATUS_WAITLIST;
                        result.errorMessage += SIB_SetupConstants.CHK_INV_THECOURSE + mapProducts.get(mapProductIdToCartItemId.get(productIds)).Product2.TTS_Event__r.Name + SIB_SetupConstants.CHK_INV_HASONLY + quantityFromExternalService + SIB_SetupConstants.CHK_INV_SEATSAVAILABLE + quantityFromSalesforce + SIB_SetupConstants.CHK_INV_SEATSAREREQUESTED;                        
                        result.waitlistedProducts.add(mapProducts.get(mapProductIdToCartItemId.get(productIds)));
                    }
                    else {
                        // If the product exists and the available quantity is enough, set status as SUCCESS
                        result.status = SIB_SetupConstants.CHECK_INV_STATUS.STATUS_SUCCESS;
                    }
                }

                result.status = isWaitlisted ? SIB_SetupConstants.CHECK_INV_STATUS.STATUS_WAITLIST : result.status;
                return result ;
            }
        } catch(Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            String errorMessage = SIB_SetupConstants.CHK_INV_ANEXCPOFTYPE + e.getTypeName() + SIB_SetupConstants.CHK_INV_HASOCCURRED + e.getMessage() + SIB_SetupConstants.CHK_INV_STACKTRACE + e.getStackTraceString();
            return new SIB_InventoryResult(SIB_SetupConstants.CHECK_INV_STATUS.STATUS_FAILED, errorMessage, new List<CartItem>());
        }

        return new SIB_InventoryResult('', '', new List<CartItem>());
    }

    private static Map<String, Decimal> getAvailableQuantitiesFromEvents(Set<String> productIds, Map<Id, Id> mapEventIdToProductId) {
        Map<String, Decimal> productIdsToAvailability = new Map<String, Decimal>();

        for (Campaign ttsEvent : [SELECT Registered__c, Seats_Available__c FROM Campaign WHERE Id IN (SELECT TTS_Event__c FROM Product2 WHERE Id IN : productIds)]) {

            Decimal availability = -1.0;
                if(null != ttsEvent && null != ttsEvent?.Seats_Available__c && null != ttsEvent?.Registered__c) {
                    availability = ttsEvent.Seats_Available__c - ttsEvent.Registered__c;
                }
            
            productIdsToAvailability.put(mapEventIdToProductId.get(ttsEvent.Id), (availability < 0 ? 0 : availability));
        }

        return productIdsToAvailability;
    }

    public class SIB_InventoryResult{
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public List<CartItem> waitlistedProducts  = new List<CartItem>();

        public SIB_InventoryResult(){
            
        }

        public SIB_InventoryResult(String status, String errorMessage, List<CartItem> products){
            this.status = status;
            this.errorMessage = errorMessage;
            this.waitlistedProducts = products;
        }

        public SIB_InventoryResult(String status, String errorMessage, CartItem product){
            this.status = status;
            this.errorMessage = errorMessage;
            if (product != null) {
                this.waitlistedProducts.add(product);
            }
        }
    }
}