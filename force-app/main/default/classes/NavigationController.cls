public without sharing class NavigationController {
    @AuraEnabled
    public static SAMLResponse samlAssertion(String username, String key, String assertionId) {
    	SAMLResponse sr = new SAMLResponse();
    	sr.assertion = SuperSAML.genrateSAMLAssertion(username, assertionId);
    	Identity_Provider_Configuration__mdt ipc = [Select Id, Audience__c, Certificate__c, Certificate_Developer_Name__c, Destination__c, Entity_Id__c, Service_URL__c from Identity_Provider_Configuration__mdt where Active__c = true limit 1];
    	sr.destination = ipc.Destination__c;
    	return sr;
    }
    
    public class SAMLResponse {
    	@AuraEnabled
    	public String assertion {get;set;}
    	@AuraEnabled
    	public String destination {get;set;}
    }
    
}