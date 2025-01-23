@isTest(SeeAllData=true)
public with sharing class SaltboxPromotionsRelatedListControllTest {
    
    @isTest
    static void testGetRelatedPromotions() {

        OrderItemAdjustmentLineSummary oials = [SELECT OrderSummaryId, AdjustmentCauseId FROM OrderItemAdjustmentLineSummary WHERE AdjustmentCauseId != null LIMIT 1];

        Test.startTest();
        String response = SaltboxPromotionsRelatedListController.getRelatedPromotions(oials.OrderSummaryId);
        System.debug('>>> response: ' + response);
        System.assertEquals(true, response.contains(oials.AdjustmentCauseId), 'response should contain AdjustmentCauseId');
        Test.stopTest();

    }

}