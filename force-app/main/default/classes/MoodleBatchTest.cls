@istest
public class MoodleBatchTest {
    
        @testSetup
    static void setupTestData() {
        // Create Contacts with mandatory LMS_Id__c field as an integer
        Contact testContact1 = new Contact(
            FirstName = 'Test', 
            LastName = 'User1', 
            LMS_Id__c = 12345
        );
        Contact testContact2 = new Contact(
            FirstName = 'Test', 
            LastName = 'User2', 
            LMS_Id__c = 67890
        );
        insert new List<Contact>{testContact1, testContact2};

        // Create Campaigns with mandatory LMS_Id__c field as an integer
        Campaign testCampaign1 = new Campaign(Name = 'Test Campaign 1', Status = 'Planned', LMS_Id__c = 11111);
        Campaign testCampaign2 = new Campaign(Name = 'Test Campaign 2', Status = 'Planned', LMS_Id__c = 22222);
        insert new List<Campaign>{testCampaign1, testCampaign2};

        // Create CampaignMembers for the same contact in multiple campaigns
        CampaignMember cm1 = new CampaignMember(ContactId = testContact1.Id, CampaignId = testCampaign1.Id, Status = 'Sent');
        CampaignMember cm2 = new CampaignMember(ContactId = testContact1.Id, CampaignId = testCampaign2.Id, Status = 'Sent');
        CampaignMember cm3 = new CampaignMember(ContactId = testContact2.Id, CampaignId = testCampaign1.Id, Status = 'Sent');
        CampaignMember cm4 = new CampaignMember(ContactId = testContact2.Id, CampaignId = testCampaign2.Id, Status = 'Sent');
        insert new List<CampaignMember>{cm1, cm2, cm3, cm4};
    }

    
    private static testMethod void MoodleBatchFullTest() {
        Test.startTest();
        MoodleBatch fullMoodle = new MoodleBatch();
        Database.executeBatch(fullMoodle);
        Test.stopTest();
    }
    
    private static testMethod void MoodleBatchPartialTest() {
        Test.startTest();
        MoodleBatch partial = new MoodleBatch(false);
        Database.executeBatch(partial);
        Test.stopTest(); 
    }
    
    private static testMethod void MoodleBatchEventTest() {
        Test.startTest();
        Campaign cmp = new Campaign(Name='Test');
        insert cmp;
        
        Account acc = new Account(Name='test');
        insert acc;
        
        Contact con = new Contact(FirstName='test', LastName='test',AccountId=acc.Id);
        insert con;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.Id,ContactId=con.Id);
        insert cmem;
        
        Map<Id,Campaign> cmpMap = new Map<Id,Campaign>([SELECT Id FROM Campaign]);
        MoodleBatch event = new MoodleBatch(cmpMap.keySet());
        Database.executeBatch(event);
        Test.stopTest(); 
    }
    
    private static testMethod void testMoodleSchedule(){
        MoodleBatch scheduler = new MoodleBatch();
        scheduler.execute(null);
    }
}