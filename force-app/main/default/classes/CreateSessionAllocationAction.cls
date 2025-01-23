public with sharing class CreateSessionAllocationAction {
  @InvocableMethod(
    label='Create Session Allocations'
    description='Parse JSON from Order Summary to create Session Allocation records'
  )
  public static void createSessionAllocations(
    List<OrderSummaryCreatedEvent> lstOrderSummaryEvents
  ) {
    List<Session_Allocation__c> lstSessionAllocations = new List<Session_Allocation__c>();

    OrderSummary orderSummary = [
      SELECT Selected_Sessions__c
      FROM OrderSummary
      WHERE ID = :lstOrderSummaryEvents.get(0).OrderSummaryId
      LIMIT 1
    ];

    Map<String, Object> mapSelectedSessions = (Map<String, Object>) JSON.deserializeUntyped(
      orderSummary.Selected_Sessions__c
    );

    for (String key : mapSelectedSessions.keySet()) {
      lstSessionAllocations.add(
        new Session_Allocation__c(
          Session__c = key,
          Order_Summary__c = orderSummary.Id
        )
      );
    }

    insert lstSessionAllocations;
  }
}