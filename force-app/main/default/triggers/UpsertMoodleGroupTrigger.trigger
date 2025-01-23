trigger UpsertMoodleGroupTrigger on Event_Relationship__c (after insert, after delete) {
    if(Trigger.isInsert) {
        Id[] parentIds = new Id[0];
        Id[] childIds = new Id[0];
        for(Event_Relationship__c er : Trigger.new) {
            parentIds.add(er.Parent__c);
            childIds.add(er.Child__c);
        }
        Moodle.createGroups(parentIds, childIds);
    }
    else {
        Integer[] lmsGroupIds = new Integer[0];
        for(Event_Relationship__c er : Trigger.old) {
            if(er.LMS_Group_Id__c != null) {
                lmsgroupIDs.add(er.LMS_Group_Id__c.intValue());
            }
        }
        if(lmsgroupIds.size() > 0) {
            Moodle.deleteGroups(lmsgroupIDs);
        }
    }
}