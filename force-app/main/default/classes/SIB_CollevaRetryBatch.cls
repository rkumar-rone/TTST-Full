/**
 * Created by junaidmohammed on 2/13/25.
 */

public without sharing class SIB_CollevaRetryBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    // Execute method to process records
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id,Status, Colleva_Provisioned__c, Colleva_Order__c, Colleva_Exceptions__c ' +
                        ' FROM OrderSummary WHERE Colleva_Order__c=TRUE AND Colleva_Provisioned__c=FALSE ';
        if (Test.isRunningTest())
        {
            query += '  ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1';
        }else
        {
            query += '  ORDER BY CreatedDate DESC';
        }
        return Database.getQueryLocator( query );
    }

    // Execute batch job to update records
    public void execute(Database.BatchableContext context, List<OrderSummary> scope) {
        for (OrderSummary orderSummaryObject : scope)
        {
            Map<String, Object> params = new Map<String, Object>();
            params.put('OrderSummaryId', String.valueOf(orderSummaryObject.Id));
            // Instantiate and start the Flow
            Flow.Interview.SIB_Colleva_API collevaApiCall = new Flow.Interview.SIB_Colleva_API(params);
            collevaApiCall.start();
        }
    }

    // Finish method
    public void finish(Database.BatchableContext context) {

    }
}