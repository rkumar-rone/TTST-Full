@istest
private with sharing class UpsertMoodleGroupTriggerTest {
    private static testMethod void TestUpsertMoodleGroupTrigger() {
        Campaign c = new Campaign(Name='test');
        insert c;
        Campaign c2 = new Campaign(Name='test2');
        insert c2;
        Event_Relationship__c er = new Event_Relationship__c(Parent__c = c.Id, Child__c = c2.Id);
        insert er;

    }
}