@isTest(SeeAllData=true)
public class CreateSessionAllocationActionTest {
    @isTest
    static void testCreateSessionAllocations() {
        // Create a test OrderSummary record
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithSessions('TestOS');
        OrderSummary testOrderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];

        // Create a test OrderSummaryCreatedEvent list
        List<OrderSummaryCreatedEvent> testEvents = new List<OrderSummaryCreatedEvent>{
            new OrderSummaryCreatedEvent(OrderSummaryId = testOrderSummary.Id)
        };

        // Call the method
        Test.startTest();
        CreateSessionAllocationAction.createSessionAllocations(testEvents);
        List<Session_Allocation__c> allocations = [
            SELECT Session__c, Order_Summary__c
            FROM Session_Allocation__c
            WHERE Order_Summary__c = :testOrderSummary.Id
        ];
        Test.stopTest();

        
        System.debug('Allocations: ' + allocations);
        System.assertEquals(2, allocations.size(), 'There should be 2 allocations created');
    }
}