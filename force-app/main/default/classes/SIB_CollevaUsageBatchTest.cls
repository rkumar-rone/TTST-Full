@isTest
public with sharing class SIB_CollevaUsageBatchTest {
    public SIB_CollevaUsageBatchTest() {

    }

    @isTest
    static void callCollevaUsageBatch(){
        UserRole userrole = [Select Id, DeveloperName From UserRole Where PortalType = 'None' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
        
            // Create a test user and account
            Account account = new Account(Name='TestAccount', CurrencyIsoCode='USD');
            insert account;
            Contact contact = new Contact(AccountId=account.Id, LastName='TestContact',Colleva_Id__c =0);
            insert contact;

            // get System Admin profile
            Profile customerCommunityProfile = [SELECT Id FROM Profile WHERE Name = 'B2B Customer Community Plus User' LIMIT 1];

            // generate unique username string for User record
            String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@test.com';
        
            User user = new User(ContactId=contact.Id, ProfileId=customerCommunityProfile.Id, Alias='testuser', Email='testuser@test.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName, CollevaAccess__c=true);
            insert user;

            // insert buyer account
            BuyerAccount buyerAccount = new BuyerAccount(Name='Test Buyer Account', BuyerId=account.Id, CurrencyIsoCode='USD');
            insert buyerAccount;

            List<SIB_CollevaAPIActiveProductsVO> activeProdList = new List<SIB_CollevaAPIActiveProductsVO>();
            SIB_CollevaAPIActiveProductsVO activeProd = new SIB_CollevaAPIActiveProductsVO();
            activeProd.externalId = 'test';
            activeProd.productName = '';
            activeProd.purchaseType = '';
            activeProd.usageType = '';
            activeProd.validUntil = '2029-05-23';
            activeProdList.add(activeProd);

            SIB_CollevaAPIDataVO dataVo = new SIB_CollevaAPIDataVO();
            dataVo.createdAt = '';
            dataVo.id = 1;
            dataVo.email = '';
            dataVo.hasUsageLeft = true;
            dataVo.minutesLeft = 5;
            dataVo.minutesLimit = 10;
            dataVo.sessionsLeft = 1;
            dataVo.sessionsLimit = 20;
            dataVo.isUnlimited = false;
            dataVo.updatedAt = '';
            dataVo.validUntil = '';
            dataVo.activeProducts = activeProdList;
            


            // Call the method to test
            Test.startTest();
            SIB_CollevaUsageBatch usageCollevaBatch = new SIB_CollevaUsageBatch();
            Database.executeBatch(usageCollevaBatch);
            SIB_CollevaUsageSchedule sc = new SIB_CollevaUsageSchedule();
            sc.execute(null);
            SIB_CollevaUsageBatch.updateCollevaUsageData(dataVo, user, 1);
            Test.stopTest();
        }
    }
}