@isTest(SeeAllData=true)
public class Test_EmailNotification {
    static testMethod void myUnitTest() {
    	Test.startTest();     
    	
        Campaign cam = new Campaign();
        cam.Name = 'Test';
        cam.Status = 'open';
        cam.Acct_Assess_Start__c = system.today();
        cam.Val_Assess_Start__c = system.today();
        cam.Case_Study_Pre_reading_Open__c = system.today();
        cam.Number_of_TA_s_Requested__c = '1';
        cam.Self_study_Format__c = 'Physical';
        cam.StartDate = system.today();
        
        cam.Generate_RC_Tasks__c = true;
        insert cam;
    	user Usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'John';
        con.LastName = 'Doe';
        con.Email = 'johndoe@example.com';
        con.AccountId = acc.Id;
        insert con;

        List<String> taskDescriptions = new List<String>();

        taskDescriptions.add('Registration Email -- Academic Participants');
        taskDescriptions.add('Registration Email -- Corporate Participants');
        taskDescriptions.add('Public Event');
        taskDescriptions.add('Academic Participants');
        taskDescriptions.add('Automate Logistic Email for Public Course 5 Day Core Comprehesive');
        taskDescriptions.add('Financial Modeling');
        taskDescriptions.add('Email to POST FM');

        List<Task> taskList = new List<Task>();

        Task t;

        Contact con1 = [SELECT Id FROM Contact WHERE Id = : con.Id];

        for (String taskDescription : taskDescriptions) {
            t = new Task();
            t.Subject = 'Rc:';
            t.Description = taskDescription;
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.whatId = cam.id;
            t.OwnerId = Usr.id;
            t.WhoId = con1.id;
            taskList.add(t);
        }

        insert taskList;

        Test.stopTest();
       
    }

}