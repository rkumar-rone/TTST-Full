public class RCAccessEndDateJunctionHelper {
    
    
    @future
    public static void processFutureReg(Set<Id> eventRelationShips){
        Map<Id, List<Event_Relationship__c>> parentToRelationship = new Map<Id, List<Event_Relationship__c>>();
        Map<Id, Set<Id>> parentToChild = new Map<Id, Set<Id>>();
        
        Set<Id> parentIds = new Set<Id>();
        Set<Id> childrenIds = new Set<Id>();
        
        for(Event_Relationship__c er : [SELECT Id,Parent__c,Child__c FROM Event_Relationship__c WHERE Id IN:eventRelationShips]) {
            parentIds.add(er.Parent__c);    
            childrenIds.add(er.Child__c);    
            
            if(!parentToChild.containsKey(er.Parent__c)) {
                parentToChild.put(er.Parent__c, new Set<Id>());
                parentToRelationship.put(er.Parent__c, new List<Event_Relationship__c>());
            }
            parentToChild.get(er.Parent__c).add(er.Child__c);
            parentToRelationship.get(er.Parent__c).add(er);
        }  
    
        // Key 1 - Contact; Value 1 - Map of Session and Registration
        // Key 2 - Sessing ID; Value 2 - Registration
        Map<Id, Map<Id, Registration__c>> existingRegs = new Map<Id, Map<Id, Registration__c>>();
        
        for(Registration__c r : [Select Id, Contact__c, Session__c from Registration__c where Session__r.Event__c in :childrenIds]) {
            if(!existingRegs.containsKey(r.Contact__c)) {
                existingRegs.put(r.Contact__c, new Map<Id, Registration__c>());
            }
            existingRegs.get(r.Contact__c).put(r.Session__c, r);
        }
        
        Map<Id, Campaign> childCampaigns = new Map<Id, Campaign>([Select Id, (Select Id, Session_Content__c from Event_Sessions__r), View_Map__c, Training_Location_Street__c, Training_Location_City__c, Training_Location_State__c, Training_Location_Zip_Code__c, What_to_Bring__c, Description, Total_Sessions__c from Campaign  where Id in :childrenIds]);
        List<CampaignMember> parentCampaignMems = [Select Id, Discount__c, Cardholder_Email__c, Cardholder_First_Name__c, Cardholder_Last_Name__c, Cardholder_City__c, Cardholder_Postal_Code__c, Cardholder_State__c, Cardholder_Street__c, Transaction_Status__c, Card_Type__c, Affirmation__c, Custom_Picklist_Selection__c, CC_Last_4_Digits__c, Campaign.Cancellation_Policy__c, Course_Cost__c, Attempted_Registration_Date__c, ContactId, CampaignId from CampaignMember where Attendee_Status__c = 'Registered' and CampaignId in :parentIds];
    	List<Registration__c> toUpsertReg = new List<Registration__c>();
    
        for(CampaignMember cm : parentCampaignMems) {
            Integer j = 0;
            for(Id childCampaignId : parentToChild.get(cm.CampaignId)) {
                if(childCampaigns.get(childCampaignId).Event_Sessions__r != null && childCampaigns.get(childCampaignId).Event_Sessions__r.size() > 0) {
                    for(Session__c session : childCampaigns.get(childCampaignId).Event_Sessions__r) {
                        Registration__c tempReg = new Registration__c(Contact__c = cm.ContactId, Session__c = session.Id);
                        if(existingRegs.containsKey(cm.ContactId) && existingRegs.get(cm.ContactId).containsKey(session.Id)) {
                            tempReg = existingRegs.get(cm.ContactId).get(session.Id);
                        }
                        tempReg.Status__c = 'Registered';
                        tempReg.Cancellation_Policy__c = cm.Campaign.Cancellation_Policy__c;
                        tempreg.Session_Content__c = session.Session_Content__c;
                        tempreg.What_to_Bring__c = childCampaigns.get(childCampaignId).What_to_Bring__c;
                        tempReg.Event_Relationship_Generated_From__c = parentToRelationship.get(cm.CampaignId)[j].Id;
                        if(childCampaigns.get(childCampaignId).View_Map__c == null || childCampaigns.get(childCampaignId).View_Map__c == '') {
                            tempReg.View_Map__c = 'http://www.google.com/maps?hl=en&safe=off&q=' + childCampaigns.get(childCampaignId).Training_Location_Street__c + ',' + childCampaigns.get(childCampaignId).Training_Location_City__c + ',' + childCampaigns.get(childCampaignId).Training_Location_State__c + ',' + childCampaigns.get(childCampaignId).Training_Location_Zip_Code__c + '&aq=f&aqi=&aql=&oq=&pbx=1&bav=on.2,or.r_gc.r_pw.&fp=a445e974b90b3339';
                        }
                        else {
                            tempReg.View_Map__c = childCampaigns.get(childCampaignId).View_Map__c;
                        }
                        toUpsertReg.add(tempReg);
                    }
                }
            }
            j++;
        }
        
        if(!toUpsertReg.isEmpty()){
            upsert toUpsertReg;
        }
        
    }
    
}