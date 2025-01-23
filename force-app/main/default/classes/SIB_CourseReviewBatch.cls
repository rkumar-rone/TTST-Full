/**
 * @description       : Batch class to make callouts to Coursecheck API and upsert reviews
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
public with sharing class SIB_CourseReviewBatch implements  Database.Batchable<SObject>, Database.AllowsCallouts {
    

    public Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([SELECT Id,SIB_Course_Id__c 
                                        FROM Product2 
                                        WHERE IsActive = true 
                                        AND SIB_Course_Id__c<>NULL]);
	}

    public void execute(Database.BatchableContext BC, List<Product2> scope){
        Map<String,Object> response = SIB_CourseReviewService.getReviewsFromCallout(scope);
    }

    public void finish(Database.BatchableContext bc)
    {
    }
}