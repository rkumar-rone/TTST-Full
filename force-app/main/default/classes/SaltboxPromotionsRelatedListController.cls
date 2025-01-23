public without sharing class SaltboxPromotionsRelatedListController {
    
    @AuraEnabled(cacheable=true)
    public static String getRelatedPromotions(String recordId){
        List<OrderItemAdjustmentLineSummary> oials = [SELECT AdjustmentCause.Id, AdjustmentCause.Name FROM OrderItemAdjustmentLineSummary WHERE OrderSummaryId = :recordId];
        return JSON.serialize(oials);
    }

}