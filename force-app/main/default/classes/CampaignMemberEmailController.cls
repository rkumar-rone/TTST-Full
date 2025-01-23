public without sharing class CampaignMemberEmailController {
    public Id recipientId {get;set;}
    public Id relatedToId {get;set;}
    
    public Registration__c[] getRegistrations() {
    	Map <String, Schema.SObjectField> fieldMap = Schema.SObjectType.Registration__c.fields.getMap();
    	String[] fieldList = new String[0];
    	fieldList.addAll(fieldMap.keySet());
    	CampaignMember cm = [Select Id, ContactId, CampaignId from CampaignMember where Id = :relatedtoId];
    	Id contactId = cm.ContactId;
    	Id campaignId = cm.CampaignId;
    	return Database.query('Select ' + String.join(fieldList, ', ') + ' from Registration__c where Contact__c = :contactId and Session__r.Event__c = :campaignId');
    }
}