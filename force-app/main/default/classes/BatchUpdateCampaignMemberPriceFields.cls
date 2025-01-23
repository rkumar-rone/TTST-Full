/**
    * @description : Implements the Batchable Interface
    * @created Date : 2nd May 2024
    * @Author : Nathan Anderson
    * @LastModified 
    * @decription Batch apex to repair the Course_Cost__c and Discount__c fields on Campaign Members that were populated with incorrect values.
*/
public class BatchUpdateCampaignMemberPriceFields implements Database.Batchable<sObject> {
    
    // Execute method to process records
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Course_Cost__c, Discount__c, Order_Summary__c, CampaignId, OrderType__c, Coupon_Code__c FROM CampaignMember WHERE Course_Cost__c = null AND Discount__c = null AND Order_Summary__c != null ORDER BY ';
        if (Test.isRunningTest()) {
            query += 'LastModifiedDate DESC NULLS LAST LIMIT 1';
        }else {
            query += 'CreatedDate DESC NULLS LAST';
        }
        return Database.getQueryLocator( query );
    }

    // Execute batch job to update records
    public void execute(Database.BatchableContext context, List<CampaignMember> scope) {
        List<CampaignMember> campaignMembersToUpdate = new List<CampaignMember>();
        // Loop through each Campaign Member and query for the related Order Item Summary
        for (CampaignMember em : scope) {
            List<OrderItemSummary> osiList = [SELECT Id, Product2Id, Product2.TTS_Event__c, Product2.TTS_Event__r.RecordType.DeveloperName, CurrencyIsoCode, 
                            (SELECT AdjustmentCause.Name FROM OrderItemAdjustmentLineItemSummaries), TotalLineAmount, TotalPrice, Quantity 
                            FROM OrderItemSummary 
                            WHERE OrderSummaryId = :em.Order_Summary__c AND Product2.TTS_Event__c = :em.CampaignId LIMIT 1];

            if (!osiList.isEmpty()) {
                OrderItemSummary osi = osiList[0];
                em.CurrencyIsoCode = osi.CurrencyIsoCode;
                // Check if the Product is a Self Study Product and if so, skip the record
                if (osi.Product2.TTS_Event__r.RecordType.DeveloperName != 'SelfStudy_Product') {
                    //For Group Orders, calculate the Course Cost and Discount by dividing the TotalLineAmount by the Quantity
                    if (em.OrderType__c == 'Group') {
                        em.Course_Cost__c = osi.TotalLineAmount / osi.Quantity;
                        em.Discount__c = (osi.TotalLineAmount - osi.TotalPrice) / osi.Quantity;
                    } else {
                        em.Course_Cost__c = osi.TotalLineAmount;
                        em.Discount__c = osi.TotalLineAmount - osi.TotalPrice;
                    }
                    // Check if there are any Adjustment Line Items and if so, populate the Coupon Code field
                    if (!osi.OrderItemAdjustmentLineItemSummaries.isEmpty()) {
                        em.Coupon_Code__c = osi.OrderItemAdjustmentLineItemSummaries[0].AdjustmentCause.Name;
                    }
                    // If there are multiple Adjustment Line Items, concatenate the Coupon Codes and truncate to 50 characters to avoid field limits   
                    if (osi.OrderItemAdjustmentLineItemSummaries.size() > 1) {
                        String couponCodes = em.Coupon_Code__c + ', ' + osi.OrderItemAdjustmentLineItemSummaries[1].AdjustmentCause.Name;
                        em.Coupon_Code__c = couponCodes.left(50);
                    }
                }
            }
            campaignMembersToUpdate.add(em);
        }
        update campaignMembersToUpdate;
    }

    // Finish method
    public void finish(Database.BatchableContext context) {}
}