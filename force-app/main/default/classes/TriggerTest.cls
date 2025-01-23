@isTest
private class TriggerTest {
    @testSetup
    static  void testData() {
        
        Campaign parentEvt = new Campaign(Name='class1',StartDate = Date.newInstance(2010,1,1),EndDate = Date.newInstance(2060,1,10), Seats_Available__c=11.0);
        insert parentEvt;
        
        Campaign evt = new Campaign(ParentId =parentEvt.Id, Name='class1',StartDate = Date.newInstance(2010,1,1),EndDate = Date.newInstance(2060,1,10), Seats_Available__c=11.0);
        insert evt;
        
        Event_Relationship__c testEvtRel = new Event_Relationship__c(Name='Test Event Relation',
                                                                    Parent__c = parentEvt.Id,
                                                                    Child__c = evt.Id);
        insert testEvtRel;
        
        List<Contact> testContacts = new List<Contact>();
        Contact teacher = new Contact(LastName='teacher');
        testContacts.add(teacher);
        Contact student = new Contact(LastName='student1');
        testContacts.add(student);
        Contact student2 = new Contact(LastName='student2');
        testContacts.add(student2);
        
        insert testContacts;
        
        Group_Member__c testGrpMem = new Group_Member__c(Child_Event_Group__c = testEvtRel.Id,
                                                        Contact__c = testContacts[1].Id,
                                                        TTS_Event__c = evt.Id);
        
        insert testGrpMem;
        CampaignMember cm1 = new CampaignMember(CampaignId=evt.id,ContactID=testContacts[1].id,Event_Generated_From__c=evt.id);
        insert cm1;
        cm1.Status = 'Registered';
        update cm1;
    }
    
    
    static testMethod void UpsertMoodleEnrollmentTriggerTest(){
        CampaignMember cm = [SELECT Id,Status FROM CampaignMember limit 1];
        delete cm;
  	}
    
    /*
    static testMethod void TotalCostPerCampaignTest()
    {
        Contact teacher = new Contact(LastName='teacher');
        insert teacher;
        Campaign evt = new Campaign(Name='class1',StartDate = Date.newInstance(2010,1,1),EndDate = Date.newInstance(2010,1,10), Seats_Available__c=1.0);
        insert evt;
        CreateSession.CreateSessionFromEvent(evt.id);
        Contact student = new Contact(LastName='student1');
        Contact student2 = new Contact(LastName='student2');
        
        insert student;
        insert student2;
        CampaignMember cm1 = new CampaignMember(CampaignId=evt.id,ContactID=student.id,Event_Generated_From__c=evt.id);
        insert cm1;
        List<Session__c> sess = [SELECT ID FROM Session__c WHERE Event__c=:evt.id];
        List<Registration__c> regs = new List<Registration__c>();
        for(Session__c s:sess)
        {
            regs.add(new Registration__c(Contact__c=student.id,Session__c=s.id));   
            
        }
        insert regs;
        regs = new List<Registration__c>();
        for(Session__c s:sess)
        {
            regs.add(new Registration__c(Contact__c=student2.id,Session__c=s.id));  
            
        }
        insert regs;
        update sess;
    }
*/
}