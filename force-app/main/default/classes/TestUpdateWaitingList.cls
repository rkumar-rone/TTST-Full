/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest
private class TestUpdateWaitingList {

    static testMethod void testUpWait() {
    	Campaign camp = new Campaign(Name='test');
    	insert camp;
    	Session__c s = new Session__c(Event__c = camp.Id);
    	insert s;
    	Contact c = new Contact(LastName = 'test');
    	insert c;
        test.startTest();
        Registration__c r = new Registration__c(Status__c  = 'Registered', Session__c = s.Id, Contact__c = c.Id);
        insert r;
        r.Status__c = 'Cancelled';
        update r;
        test.stopTest();
    }
}