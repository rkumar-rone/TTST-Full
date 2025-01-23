@isTest
private class NewCommunityTests {
	
	static testMethod void TestCommunity() {
		Campaign c = new Campaign(Name='test');
		insert c;
		Contact cont = new Contact(Lastname='test');
		insert cont;
		CampaignMember cm = new CampaignMember(CampaignId = c.Id, ContactId = cont.Id);
		insert cm;
	}
	
	
	static testMethod void TestMore() {
		CourseManagementController.tst();
		CourseManagementController.tst2();
		ProfileController.tst();
		UserAuthenticationController.tst();
		CourseManagementController.getIsSandbox();
	}

	@isTest
    static void testUpdateFirstDate() {
		Id peCampaignRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Public Event').getRecordTypeId();
		Campaign c = new Campaign();
		c.Name = 'cTestName';
		c.RecordTypeId = peCampaignRT;
		c.Training_Location_City__c = 'TestCity';
		c.Course_Start_Date_Time__c = Date.today().addDays(1);
		insert c;

        Session__c s = new Session__c();
		s.Event__c = c.Id;
		s.Name = 'sTestName';
		s.Session_Start__c = Date.today().addDays(3);

		Test.startTest();

		insert s;

		Session__c sToUpdate = [SELECT Id FROM Session__c WHERE Name = 'sTestName' LIMIT 1];

		sToUpdate.Session_Start__c = Date.today().addDays(5);

		update sToUpdate;

		Session__c sToDelete = [SELECT Id FROM Session__c WHERE Name = 'sTestName' LIMIT 1];
		
		delete sToDelete;

		Test.stopTest();

		List<Session__c> queryNoS = [SELECT Id FROM Session__c WHERE Name = 'sTestName'];

		System.assertEquals(0, queryNoS.size());
    }
	
    
}