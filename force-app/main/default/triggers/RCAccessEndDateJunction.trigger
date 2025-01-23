trigger RCAccessEndDateJunction on Event_Relationship__c (after update, after insert) {
    if(Trigger.isInsert) {
        Map<Id, Id[]> parentToChild = new Map<Id, Id[]>();
        Map<Id, Event_Relationship__c[]> parentToRelationship = new Map<Id, Event_Relationship__c[]>();
        Id[] parentIds = new Id[0];
        Id[] childrenIds = new Id[0];
        for(Event_Relationship__c er : Trigger.new) {
            parentIds.add(er.Parent__c);
            childrenIds.add(er.Child__c);
            if(!parentToChild.containsKey(er.Parent__c)) {
                parentToChild.put(er.Parent__c, new Id[0]);
                parentToRelationship.put(er.Parent__c, new Event_Relationship__c[0]);
            }
            parentToChild.get(er.Parent__c).add(er.Child__c);
            parentToRelationship.get(er.Parent__c).add(er);
        }
        
        Map<Id, Campaign> children = new Map<Id, Campaign>([Select Id, (Select Id, Session_Content__c from Event_Sessions__r), View_Map__c, Training_Location_Street__c, Training_Location_City__c, Training_Location_State__c, Training_Location_Zip_Code__c, What_to_Bring__c, Description, Total_Sessions__c from Campaign  where Id in :childrenIds]);
        CampaignMember[] cms = [Select Id, Discount__c, Cardholder_Email__c, Cardholder_First_Name__c, Cardholder_Last_Name__c, Cardholder_City__c, Cardholder_Postal_Code__c, Cardholder_State__c, Cardholder_Street__c, Transaction_Status__c, Card_Type__c, Affirmation__c, Custom_Picklist_Selection__c, CC_Last_4_Digits__c, Campaign.Cancellation_Policy__c, Course_Cost__c, Attempted_Registration_Date__c, ContactId, CampaignId from CampaignMember where Attendee_Status__c = 'Registered' and CampaignId in :parentIds];
        CampaignMember[] toUpsert = new CampaignMember[0];
        Registration__c[] toUpsertReg = new Registration__c[0];
        Map<Id, Map<Id, CampaignMember>> existingMembers = new Map<Id, Map<Id, CampaignMember>>();
        for(CampaignMember cm : [Select CampaignId, ContactId, Date_RC_Access_Ends_Formula__c from CampaignMember where CampaignId in :childrenIds]) {
            if(!existingMembers.containsKey(cm.ContactId)) {
                existingMembers.put(cm.ContactId, new Map<Id, CampaignMember>());
            }
            existingMembers.get(cm.ContactId).put(cm.CampaignId, cm);
        }
        for(CampaignMember cm : cms) {
            Integer j = 0;
            for(Id i : parentToChild.get(cm.CampaignId)) {
                CampaignMember tempCm = new CampaignMember(ContactId = cm.ContactId, CampaignId = i);
                if(existingMembers.containsKey(cm.ContactId) && existingMembers.get(cm.ContactId).containsKey(i)) {
                    tempCm = existingMembers.get(cm.ContactId).get(i);
                }
                tempCm.Attempted_Registration_Date__c = cm.Attempted_Registration_Date__c;
                tempCm.Course_Cost__c =  cm.Course_Cost__c;
                tempCM.Discount__c = cm.Discount__c;
                tempCM.Sessions_Registered__c = children.get(i).Total_Sessions__c;
                tempCM.Description__c = children.get(i).Description;
                tempCM.Cancellation_Policy__c = cm.Campaign.Cancellation_Policy__c;
                tempCM.What_to_Bring__c = children.get(i).What_to_Bring__c;
                tempCM.Attendee_Status__c = 'Registered';
                if(tempCM.Id == null || tempCM.Date_RC_Access_Ends_Formula__c == null || parentToRelationship.get(cm.CampaignId)[j].Date_RC_Access_Ends_DateTime_Formula__c >= tempCM.Date_RC_Access_Ends_Formula__c) {
                    tempCM.Event_Relationship_Generated_From__c = parentToRelationship.get(cm.CampaignId)[j].Id;
                }
                if(children.get(i).View_Map__c == null || children.get(i).View_Map__c == '') {
                    tempCM.View_Map__c = 'http://www.google.com/maps?hl=en&safe=off&q=' + children.get(i).Training_Location_Street__c + ',' + children.get(i).Training_Location_City__c + ',' + children.get(i).Training_Location_State__c + ',' + children.get(i).Training_Location_Zip_Code__c + '&aq=f&aqi=&aql=&oq=&pbx=1&bav=on.2,or.r_gc.r_pw.&fp=a445e974b90b3339';
                }
                else {
                    tempCM.View_Map__c = children.get(i).View_Map__c;
                }
                tempCM.CC_Last_4_Digits__c = cm.CC_Last_4_Digits__c;
                tempCM.New_Portal__c = true;
                tempCM.Custom_Picklist_Selection__c = cm.Custom_Picklist_Selection__c;
                tempCM.Cardholder_Email__c = cm.Cardholder_Email__c;
                tempCM.Cardholder_First_Name__c = cm.Cardholder_First_Name__c;
                tempCM.Cardholder_Last_Name__c = cm.Cardholder_Last_Name__c;
                tempCM.Cardholder_City__c = cm.Cardholder_City__c;
                tempCM.Cardholder_Postal_Code__c = cm.Cardholder_Postal_Code__c;
                tempCM.Cardholder_State__c = cm.Cardholder_State__c;
                tempCM.Cardholder_Street__c = cm.Cardholder_Street__c;
                tempCM.Transaction_Status__c = cm.Transaction_Status__c;
                tempCM.Card_Type__c = cm.Card_Type__c;
                tempCM.Affirmation__c = cm.Affirmation__c;
                toUpsert.add(tempCM);
                j++;
            }
        }
        upsert toUpsert;
        RCAccessEndDateJunctionHelper.processFutureReg(Trigger.newMap.keySet());
    }
    else {
        Id[] junctionIds = new Id[0];
        for(Event_Relationship__c er : Trigger.new) {
            if(er.Date_RC_Access_Ends_DateTime__c != Trigger.oldMap.get(er.Id).Date_RC_Access_Ends_DateTime__c || er.Date_RC_Access_Starts__c != Trigger.oldMap.get(er.Id).Date_RC_Access_Starts__c) {
                junctionIds.add(er.Id);
            }
        }
        if(junctionIds.size() > 0) {
            for(CampaignMember[] cms : [Select Id, Update_RC_Date__c from CampaignMember where Event_Relationship_Generated_From__c in :junctionIds]) {
                for(CampaignMember cm : cms) {
                    cm.Update_RC_Date__c = !cm.Update_RC_Date__c;
                }
                update cms;
            }
        }
    }
    
}