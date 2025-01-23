/**
 * @description       : Test class for SIB_UserSelector
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_UserSelectorTest {
    @isTest
    static void testGetContactIdForUserId(){
        User adminUser = SIB_TestDataFactory.createAdminUser(true);
        Test.startTest();
        String result = SIB_UserSelector.getContactIdForUserId(adminUser.Id);
        User resultGetUserInformationForUserId = SIB_UserSelector.getUserInformationForUserId(adminUser.Id);
        System.assertNotEquals(null, resultGetUserInformationForUserId,'Passed');        
        Test.stopTest();
    }
}