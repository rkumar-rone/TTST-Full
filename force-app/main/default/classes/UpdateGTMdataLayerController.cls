public without sharing class UpdateGTMdataLayerController {
    
    @AuraEnabled
	public static String getGTMEventData(String recordId){
        String eventDataResponse = '';

        GTMEventData gtmEventData = new GTMEventData();

        OrderSummary os = [SELECT OrderNumber, AccountId,Status,TotalAmount,CurrencyIsoCode,Id,TotalTaxAmount,TotalAdjustedProductAmount FROM OrderSummarY WHERE Id = :recordId LIMIT 1];

        Account client = [SELECT FirstName,LastName,PersonEmail FROM Account WHERE Id = :os.AccountId LIMIT 1];

        List<OrderItemSummary> oisList = [SELECT Product2Id, TotalPrice, TotalAdjustmentAmount, TotalLineAmount FROM OrderItemSummary WHERE OrderSummaryId = :recordId];

        Map<Id, OrderItemSummary> productMap = new Map<Id, OrderItemSummary>();

        for (OrderItemSummary ois : oisList) {
            productMap.put(ois.Product2Id, ois);
        }

        List<Product2> productEventInfo = [SELECT Id, TTS_Event__r.Name, TTS_Event__r.Class_Code__c, Product_Group__c FROM Product2 WHERE Id IN :productMap.keySet()];

        gtmEventData.firstName = client.FirstName;
        gtmEventData.lastName = client.LastName;
        gtmEventData.email = client.PersonEmail;
        gtmEventData.cost = os.TotalAmount;
        gtmEventData.status = os.Status;

        gtmEventData.currencyCode = os.CurrencyIsoCode;
        gtmEventData.osId = os.Id;
        gtmEventData.oId = os.OrderNumber;
        gtmEventData.tax = os.TotalTaxAmount;
        gtmEventData.subTotal = os.TotalAdjustedProductAmount;

        List<OrderItemAdjustmentLineSummary> coupons = [SELECT Id,AdjustmentCause.Name,OrderAdjustmentGroupSummaryId,OrderItemSummary.Product2Id FROM OrderItemAdjustmentLineSummary WHERE OrderSummaryId = :recordId];

        String cartCoupon='';

        for (OrderItemAdjustmentLineSummary coupon : coupons) {
            if (cartCoupon == '' && coupon.OrderAdjustmentGroupSummaryId != null) {
                cartCoupon = coupon.AdjustmentCause.Name;
            } 
        }

        gtmEventData.coupon = cartCoupon;
        
        String itemCoupon;
        for (Product2 product : productEventInfo) {
            itemCoupon = '';
            for (OrderItemAdjustmentLineSummary coupon : coupons) {
                if (coupon.OrderItemSummary.Product2Id == product.Id && coupon.OrderAdjustmentGroupSummaryId == null) {
                    itemCoupon = coupon.AdjustmentCause.Name;
                }
            }

            gtmEventData.gtmItems.add(new GtmItems(product.TTS_Event__r.Name, product.TTS_Event__r.Class_Code__c, itemCoupon, productMap.get(product.Id).TotalPrice, productMap.get(product.Id).TotalAdjustmentAmount, productMap.get(product.Id).TotalLineAmount, product.Product_Group__c));
        }

        eventDataResponse = JSON.serialize(gtmEventData);

        return eventDataResponse;
    }

    public class GTMEventData {
        String currencyCode {get;set;}
        String oId{get;set;}
        String osId {get;set;}
        Decimal tax {get;set;}
        String firstName {get;set;}
        String lastName {get;set;}
        String email {get;set;}
        Decimal cost {get;set;}
        String status {get;set;}
        String coupon {get;set;}
        Decimal subTotal {get;set;}
        public List<GtmItems> gtmItems {get;set;}

        public GTMEventData(){
            gtmItems = new List<GtmItems>();
        }
    }

    public class GtmItems {
        String item_name {get;set;}
        String item_id {get;set;}
        String coupon {get;set;}
        Decimal price {get;set;}
        Decimal discount {get;set;}
        Decimal subTotal {get;set;}
        String productGroup {get;set;}

        public GtmItems(String eventIn, String classCodeIn, String couponIn, Decimal priceIn, Decimal discountIn, Decimal subTotalIn, String productGroupIn){
            item_name = eventIn;
            item_id = classCodeIn;
            coupon = couponIn;
            price = priceIn;
            discount = discountIn*-1;
            subTotal = subTotalIn;
            productGroup = productGroupIn;
        }
    }

}