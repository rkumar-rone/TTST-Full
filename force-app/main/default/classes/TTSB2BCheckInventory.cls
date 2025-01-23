public with sharing class TTSB2BCheckInventory {

    public static final String STATUS_SUCCESS = 'Success';
    public static final String STATUS_WAITLIST = 'Waitlist';
    public static final String STATUS_FAILED = 'Failed';

    @InvocableMethod(label='TTS B2B Check Inventory' description='Checks available seats for courses added to the cart.' category='B2B')
    public static List<InventoryResult> TTSB2BCheckInventory(List<Id> cartIds) {

        try {
            // Get all SKUs and their quantities from cart items.
            Map<String, Decimal> quantitiesFromSalesforce = new Map<String, Decimal>();
            Map<Id, Id> mapEventIdToProductId = new Map<Id, Id>();
            Map<Id, Id> mapProductIdToCartItemId = new Map<Id, Id>();
            Map<Id, CartItem> mapProducts = new Map<Id, CartItem>();
            for (CartItem cartItem : [SELECT Id, Sku, Quantity, Product2Id, Product2.Name, Product2.TTS_Event__c, Product2.TTS_Event__r.Name FROM CartItem WHERE CartId = :cartIds AND Type = 'Product']) {
                if (String.isBlank(cartItem.Sku)) {
                    String errorMessage = 'The SKUs for all products in your cart must be defined.';
                    return new List<InventoryResult>{new InventoryResult(STATUS_FAILED, errorMessage, new List<CartItem>())};
                }

                if (cartItem.Product2.TTS_Event__c != null) {
                    quantitiesFromSalesforce.put(cartItem.Product2Id, cartItem.Quantity);
                    mapEventIdToProductId.put(cartItem.Product2.TTS_Event__c, cartItem.Product2Id);
                    mapProductIdToCartItemId.put(cartItem.Product2Id, cartItem.Id);
                    mapProducts.put(cartItem.Id, cartItem);
                }
            }

            // contiune if there are no products that need inventory check
            if (quantitiesFromSalesforce.isEmpty()) {
                // integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
            }
            else {
                // Get all available quantities for products in the cart (cart items) from an external service.
                Map<String, Object> quantitiesFromExternalService = getAvailableQuantitiesFromEvents(quantitiesFromSalesforce.keySet(), mapEventIdToProductId);
                InventoryResult result = new InventoryResult('', '', new List<CartItem>());
                Boolean isWaitlisted = false;
                // For each cart item SKU, check that the quantity from the external service
                // is greater or equal to the quantity in the cart.
                // If that is not true, set the integration status to "Failed".
                for (String productIds : quantitiesFromSalesforce.keySet()) {
                    Decimal quantityFromSalesforce = quantitiesFromSalesforce.get(productIds);
                    Decimal quantityFromExternalService = (Decimal)quantitiesFromExternalService.get(productIds);
                    if (quantityFromExternalService == null){
                        String errorMessage = 'The product with Id ' + productIds + ' could not be found in the system';
                        return new List<InventoryResult>{new InventoryResult(STATUS_FAILED, errorMessage, mapProducts.get(productIds))};
                    }
                    else if (quantityFromExternalService < quantityFromSalesforce){
                        isWaitlisted = true;
                        result.status = STATUS_WAITLIST;
                        result.errorMessage += 'The Course ' + mapProducts.get(mapProductIdToCartItemId.get(productIds)).Product2.TTS_Event__r.Name + ' has only ' + quantityFromExternalService + ' seats available and ' + quantityFromSalesforce + ' seats are requested.\n';                        
                        result.waitlistedProducts.add(mapProducts.get(mapProductIdToCartItemId.get(productIds)));
                    }
                    else {
                        // If the product exists and the available quantity is enough, set status as SUCCESS
                        result.status = STATUS_SUCCESS;
                    }
                }

                result.status = isWaitlisted ? STATUS_WAITLIST : result.status;
                return new List<InventoryResult>{ result };
            }
        } catch(Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            String errorMessage = 'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage() + ' Stacktrace: ' + e.getStackTraceString();
            return new List<InventoryResult>{new InventoryResult(STATUS_FAILED, errorMessage, new List<CartItem>())};
        }

        return new List<InventoryResult>{new InventoryResult('', '', new List<CartItem>())};
    }

    private static Map<String, Decimal> getAvailableQuantitiesFromEvents(Set<String> productIds, Map<Id, Id> mapEventIdToProductId) {
        Map<String, Decimal> productIdsToAvailability = new Map<String, Decimal>();

        for (Campaign ttsEvent : [SELECT Registered__c, Seats_Available__c FROM Campaign WHERE Id IN (SELECT TTS_Event__c FROM Product2 WHERE Id IN : productIds)]) {
            Decimal availability = ttsEvent.Seats_Available__c - ttsEvent.Registered__c;
            productIdsToAvailability.put(mapEventIdToProductId.get(ttsEvent.Id), (availability < 0 ? 0 : availability));
        }

        return productIdsToAvailability;
    }

    public class InventoryResult{
        @InvocableVariable(label='Inventory Check Status')
        public String status;
        @InvocableVariable(label='Inventory Check Error Message')
        public String errorMessage;
        @InvocableVariable(label='Waitlisted Cart Items' description='List of Cart Items which are waitlisted')
        public List<CartItem> waitlistedProducts  = new List<CartItem>();

        public InventoryResult(String status, String errorMessage, List<CartItem> products){
            this.status = status;
            this.errorMessage = errorMessage;
            this.waitlistedProducts = products;
        }

        public InventoryResult(String status, String errorMessage, CartItem product){
            this.status = status;
            this.errorMessage = errorMessage;
            if (product != null) {
                this.waitlistedProducts.add(product);
            }
        }
    }
}