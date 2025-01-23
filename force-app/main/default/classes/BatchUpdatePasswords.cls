public with sharing class BatchUpdatePasswords implements  Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id, Password__c from Contact where Password__c != null]);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope){
        for(Contact c : scope) {
            c.Password__c = null;
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC){
		
	}
}