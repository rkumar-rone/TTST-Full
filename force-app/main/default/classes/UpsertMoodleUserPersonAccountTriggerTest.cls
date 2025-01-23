@isTest
public class UpsertMoodleUserPersonAccountTriggerTest {
    @isTest
    static void testTrigger() {
        // Get the ID of the 'Person Account' record type
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        // Create a test Account record
        Account testAccount = new Account(
            Name = 'Test User'       
        );
        insert testAccount;

        // Create a test Contact record
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            FirstName = 'Test',
            LastName = 'User'
        );
        insert testContact;

        // Update the Account record
        Account accToUpdate = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        accToUpdate.RecordTypeId = recordTypeId;
        update accToUpdate;

        accToUpdate.PersonEmail = 'updated@example.com';
        accToUpdate.User_Id__pc = 'updatedUser';
        accToUpdate.Has_Registered_Synced_Events__pc = true;
        accToUpdate.FirstName = 'Updated';
        accToUpdate.LastName = 'User';
        update accToUpdate;

        // Verify the results
        Contact updatedContact = [SELECT Id, LMS_Id__c, Email, User_Id__c, Has_Registered_Synced_Events__c, FirstName, LastName, Suspend_LMS_Account__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(accToUpdate.PersonEmail, updatedContact.Email);
        System.assertEquals(accToUpdate.User_Id__pc, updatedContact.User_Id__c);
        System.assertEquals(accToUpdate.FirstName, updatedContact.FirstName);
        System.assertEquals(accToUpdate.LastName, updatedContact.LastName);
    }

    @isTest
    static void testTrigger2() {
        // Get the ID of the 'Person Account' record type
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        // Create a test Account record
        Account testAccount = new Account(
            Name = 'Test User'
        );
        insert testAccount;

        // Create a test Contact record
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            FirstName = 'Test',
            LastName = 'User',
            LMS_Id__c = 12345
        );
        insert testContact;

        // Update the Account record
        Account accToUpdate = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        accToUpdate.RecordTypeId = recordTypeId;
        update accToUpdate;

        accToUpdate.PersonEmail = 'updated@example.com';
        accToUpdate.User_Id__pc = 'updatedUser';
        accToUpdate.Has_Registered_Synced_Events__pc = true;
        accToUpdate.FirstName = 'Updated';
        accToUpdate.LastName = 'User';
        update accToUpdate;

        // Verify the results
        Contact updatedContact = [SELECT Id, LMS_Id__c, Email, User_Id__c, Has_Registered_Synced_Events__c, FirstName, LastName, Suspend_LMS_Account__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(accToUpdate.PersonEmail, updatedContact.Email);
        System.assertEquals(accToUpdate.User_Id__pc, updatedContact.User_Id__c);
        System.assertEquals(accToUpdate.FirstName, updatedContact.FirstName);
        System.assertEquals(accToUpdate.LastName, updatedContact.LastName);
    }
}