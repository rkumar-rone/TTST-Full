@isTest(SeeAllData=true)
private class BatchUpdateCampaignMemberPriceFieldsTest {
    
    @isTest
    public static void testBatchUpdateCampaignMemberPriceFields() {
        
        List<OrderItemSummary> osiList = [SELECT Id, Product2Id, Product2.TTS_Event__c, Product2.TTS_Event__r.RecordType.DeveloperName, CurrencyIsoCode, 
                                                (SELECT AdjustmentCause.Name FROM OrderItemAdjustmentLineItemSummaries), TotalLineAmount, TotalPrice, Quantity, 
                                                TotalAdjustmentAmount, OrderSummaryId
                                            FROM OrderItemSummary 
                                            WHERE Product2.TTS_Event__r.RecordType.DeveloperName != 'SelfStudy_Product' AND TotalAdjustmentAmount != 0 
                                                AND Product2.TTS_Event__c != null AND OrderSummaryId NOT IN (SELECT Order_Summary__c FROM Group_Recepient__c) 
                                                AND OrderSummary.GrandTotalAmount != 0 AND CreatedDate = LAST_N_DAYS:61
                                            ORDER BY TotalAdjustmentAmount ASC NULLS LAST
                                            LIMIT 1];

        CampaignMember cm = [SELECT Id, Course_Cost__c, Discount__c, CampaignId, CurrencyIsoCode, Coupon_Code__c, Order_Summary__c
                                FROM CampaignMember 
                                WHERE CampaignId = :osiList[0].Product2.TTS_Event__c
                                ORDER BY CreatedDate DESC NULLS LAST
                                LIMIT 1];

        cm.Course_Cost__c = null;
        cm.Discount__c = null;
        cm.CurrencyIsoCode = null;
        cm.Coupon_Code__c = null;
        update cm;

        Test.startTest();
        BatchUpdateCampaignMemberPriceFields b = new BatchUpdateCampaignMemberPriceFields();
        Database.executeBatch(b, 1);
        Test.stopTest();
    }


}