@isTest(SeeAllData=true)
public with sharing class SaltboxGroupOrderReservedSeatsInvocaTest {
    
    @isTest 
    static void testSaltboxGroupOrderReservedSeatsInvoca() {

        Session_Allocation__c sa = [SELECT Id, Session__c, Order_Summary__c, Session__r.Event__c FROM Session_Allocation__c ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];

        List<String> sessionAllocationsIds = new List<String>();

        sessionAllocationsIds.add(sa.Id);

        String os = sa.Order_Summary__c;

        List<OrderItemSummary> orderItemSummaries = [SELECT Id, Product2.TTS_Event__c FROM OrderItemSummary WHERE OrderSummaryId = :os ORDER BY CreatedDate DESC NULLS LAST];

        List<String> orderItemSummaryIds = new List<String>();

        for (OrderItemSummary ois : orderItemSummaries) {
            orderItemSummaryIds.add(ois.Id);
        }

        Integer groupRecipientCount = 1;

        SaltboxGroupOrderReservedSeatsInvocable.GroupOrderReservedSeats groupOrderReservedSeats = new SaltboxGroupOrderReservedSeatsInvocable.GroupOrderReservedSeats();
        
        groupOrderReservedSeats.sessionAllocationsIds = sessionAllocationsIds;
        groupOrderReservedSeats.orderItemSummariesIds = orderItemSummaryIds;
        groupOrderReservedSeats.groupRecipientCount = groupRecipientCount;

        List<SaltboxGroupOrderReservedSeatsInvocable.GroupOrderReservedSeats> groupOrderReservedSeatsList = new List<SaltboxGroupOrderReservedSeatsInvocable.GroupOrderReservedSeats> { groupOrderReservedSeats };
        groupOrderReservedSeatsList.add(groupOrderReservedSeats);

        Test.startTest();
        List<String> result = SaltboxGroupOrderReservedSeatsInvocable.updateReservedSeats(groupOrderReservedSeatsList);
        Test.stopTest();
        
        System.assertEquals('Reserved seats updated successfully', result[0], 'result is: '+ result[0]);

    }

}