trigger EventOwnerTrigger on Campaign (before insert, before update)
{       
    Map<string,User> email2UserMap = new Map<string,User>();
    Map<Id, string> contactId2EmailMap = new Map<Id, string>();
    Set<Id> changedIds = new Set<Id>();
    for (Campaign c: trigger.new)
    {
        if((Trigger.isInsert || c.Instructor__c != Trigger.oldMap.get(c.Id).Instructor__c)) {
            if(c.Instructor__c != null) {
                contactId2EmailMap.put(c.Instructor__c, null);
            }
            changedIds.add(c.Id);
        }
        else if(Trigger.isUpdate && c.Event_Manager__c != Trigger.oldMap.get(c.Id).Event_Manager__c && c.Instructor__c == null) {
            changedIds.add(c.Id);
        }
    }
    if(changedIds.size() > 0) {
        String[] emailAddresses = new String[0];
        for (Contact c: [SELECT Id, Email FROM Contact where Id IN: contactId2EmailMap.keySet()])
        {
            contactId2EmailMap.put(c.Id,c.Email);
            emailAddresses.add(c.Email);
        }
        if (!emailAddresses.isEmpty())
        {
            for (User u: [SELECT Id, Email FROM User where Email IN: emailAddresses])
            {
                email2UserMap.put(u.Email,u);
            }
        }
        for (Campaign c: trigger.new)
        {
            if(changedIds.contains(c.Id)) {
                if(c.Instructor__c != null && contactId2EmailMap.containsKey(c.Instructor__c) && email2UserMap.containsKey(contactId2EmailMap.get(c.Instructor__c))) {
                    c.Event_Owner__c = email2UserMap.get(contactId2EmailMap.get(c.Instructor__c)).Id;
                }
                else if(c.Event_Manager__c != null) {
                    c.Event_Owner__c = c.Event_Manager__c;
                }
                else {
                    c.Event_Owner__c = null;
                }
            }
        }
    }
}