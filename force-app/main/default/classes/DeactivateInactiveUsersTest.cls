@isTest
public class DeactivateInactiveUsersTest {
  @TestSetup
  static void makeData(){
    // Create a Profile
    Profile objProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'B2B Customer Community Plus User'
      LIMIT 1
    ];

    Account objAccount = new Account();
    objAccount.Name = 'Test Account';
    insert objAccount;

    Contact objContact = new Contact();
    objContact.FirstName = 'Test';
    objContact.LastName = 'User';
    objContact.AccountId = objAccount.Id;
    insert objContact;

    // Create a User
    User objUser = new User();
    objUser.Username = 'test@test.com';
    objUser.Email = 'test@test.com';
    objUser.Alias = 'tuser';
    objUser.TimeZoneSidKey = 'America/Los_Angeles';
    objUser.LocaleSidKey = 'en_US';
    objUser.EmailEncodingKey = 'UTF-8';
    objUser.ProfileId = objProfile.Id;
    objUser.LanguageLocaleKey = 'en_US';
    objUser.LastName = 'Test';
    objUser.FirstName = 'User';
    objUser.IsActive = true;
    objUser.ContactId = objContact.Id;
    insert objUser;
  }
  @isTest
  static void testDeactivateInactiveUsers() {
    Test.startTest();
    DeactivateInactiveUsers.execute();
    Test.stopTest();

    // Query for the user again
    User objUser = [SELECT IsActive FROM User WHERE Username = 'test@test.com'];

    // Assert that the user is now inactive
    System.assertEquals(false, objUser.IsActive);
  }
}