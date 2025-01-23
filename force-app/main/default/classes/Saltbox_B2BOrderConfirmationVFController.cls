/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-07-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
public class Saltbox_B2BOrderConfirmationVFController {
    public String orderSummaryId {get;set;}
    public String recipientName {get;set;}
    public Boolean isSelfStudyOrder{get;set;}

    public Saltbox_B2BOrderConfirmationVFController() {
    }

    public OrderSummary getOrderSummary() {
        if(String.isBlank(orderSummaryId)) {
            return new OrderSummary();
        }
        return [SELECT Id, OrderedDate, OrderNumber, OriginalOrder.OrderNumber,BillingStateCode, TotalAmount,TotalProductAmount,TotalAdjDistAmount, TotalAdjustedDeliveryTaxAmount, TotalAdjustedProductTaxAmount, GrandTotalAmount, PoNumber, BillToContact.Name, BillingState, BillingStreet, BillingPostalCode, BillingPhoneNumber, BillingCity, BillingCountry, SalesStore.Name, TotalTaxAmount FROM OrderSummary WHERE Id = :orderSummaryId LIMIT 1];
    }

    public OrderDeliveryGroupSummary getShippingAddress() {
        if(String.isBlank(orderSummaryId)) {
            return new OrderDeliveryGroupSummary();
        }
        return [SELECT Id, DeliverToName, DeliverToCity, DeliverToCountry, DeliverToPostalCode, DeliverToState, DeliverToStreet, PhoneNumber, DeliveryInstructions FROM OrderDeliveryGroupSummary WHERE OrderSummaryId = :orderSummaryId LIMIT 1];
    }

    public List<OrderItem> getOrderItems() {
        if(String.isBlank(orderSummaryId)) {
            return new List<OrderItem>();
        }
        Map<String, OrderItem> orderItemByProductId = new Map<String, OrderItem>();
        /*String webstoreId = [SELECT Id, WebStoreId FROM WebStoreNetwork WHERE NetworkId = :NETWORK_ID LIMIT 1].WebStoreId;
        String accountId = [SELECT Id, AccountId FROM OrderSummary WHERE Id = :orderSummaryId LIMIT 1].AccountId;*/

        for(OrderItemSummary item: [SELECT Id, Product2Id, Product2.Name, Product2.StockKeepingUnit, Quantity, UnitPrice, ListPrice, Product2.TTS_Event__r.RecordType.DeveloperName FROM OrderItemSummary WHERE OrderSummaryId = :orderSummaryId AND ListPrice != 0  order by UnitPrice desc]) {
            OrderItem oi = new OrderItem();
            oi.productName = item.Product2.Name;
            oi.productSKU = item.Product2.StockKeepingUnit;
            oi.quantity = Integer.valueOf(item.Quantity);
            oi.listPrice = item.ListPrice;
            oi.unitPrice = item.UnitPrice;
            orderItemByProductId.put(item.Product2Id, oi);
            if(item.Product2.TTS_Event__r.RecordType.DeveloperName == 'SelfStudy_Product') 
            {
                isSelfStudyOrder = true;
            }
        }

        /*for(ConnectApi.OrderItemSummary item: ConnectApi.CommerceBuyerExperience.getOrderItemSummaries(webstoreId, accountId, orderSummaryId).items) {
            if(!String.isBlank(item.product.media.url)) {
                orderItemByProductId.get(item.product.productId).productURL = URL.getSalesforceBaseUrl().toExternalForm() + item.product.media.url;
            }
            else {
                orderItemByProductId.get(item.product.productId).productURL = 'xxxx';
            }
        }*/

        List<OrderItem> orderItemsToReturn = new List<OrderItem>();
        OrderItem dryIceOI;
        OrderItem shippingChargeOI;

        for(OrderItem orderItem: orderItemByProductId.values()) {
            if(orderItem.productSKU == '/DRY') {
                dryIceOI = orderItem;
            }
            else if(orderItem.productName == 'Shipping Charge for this delivery method') {
                orderItem.productName = 'Estimated Shipping';
                shippingChargeOI = orderItem;
            }
            else {
                orderItemsToReturn.add(OrderItem);
            }
        }

        if(dryIceOI != null) {
            orderItemsToReturn.add(dryIceOI);
        }

        if(shippingChargeOI != null) {
            orderItemsToReturn.add(shippingChargeOI);
        }

        return orderItemsToReturn;
    }

    public String getSiteURL() {
        if(String.isBlank(orderSummaryId)) {
            return null;
        }
        OrderSummary orderSummary = getOrderSummary();
        if (orderSummary.SalesStore.Name == System.Label.SIB_DefaultStorename) {
            return System.Label.SIB_LWRSiteURL + '/OrderSummary/' + orderSummaryId;
        }
        String networkId = [SELECT Id FROM Network WHERE Name = 'TTS B2B Store' LIMIT 1].Id;
        String networkPathPrefix = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :networkId LIMIT 1].UrlPathPrefix;
        Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = :networkPathPrefix LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;

        return communityUrl + '/s/OrderSummary/' + orderSummaryId;
    }

    public String getCurrencySymbol(){
        String currencySymbol = '';
        if(String.isBlank(orderSummaryId)) {
            return null;
        }
        String currencyIsoCode = [SELECT Id, CurrencyIsoCode FROM OrderSummary WHERE Id = :orderSummaryId LIMIT 1].CurrencyIsoCode;
        if (currencyIsoCode == 'GBP') {
            currencySymbol = '£';
        } else {
            currencySymbol = '$';
        }
        return currencySymbol;
    }

    /* public String getMaskedCCNumber() {
        if(String.isBlank(orderSummaryId)) {
            return null;
        }
        List<B2B_Payment_Authorization__c> auths = [SELECT Id, Masked_Card_Number__c FROM B2B_Payment_Authorization__c WHERE Order_Summary__c = :orderSummaryId LIMIT 1];

        if(!auths.isEmpty()) {
            return auths[0].Masked_Card_Number__c;
        }

        return null;
    } */

    public class OrderItem {
        public String productName {get;set;}
        public String productSKU {get;set;}
        public Integer quantity {get;set;}
        public Decimal listPrice {get;set;}
        public Decimal unitPrice {get;set;}
        //public String productURL {get;set;}
    }
}