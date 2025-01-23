/**
 * @description       : Test class for SIB_BaseRequest
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_BaseRequestTest {
    
    @isTest
    public static void testSIBBaseRequestProperties() {

        Id accountId =  SIB_TestDataFactory.getMockId(Account.SObjectType) ; 
        Id webstoreId =  SIB_TestDataFactory.getMockId(WebStore.SObjectType) ; 
        Id communityId =  SIB_TestDataFactory.getMockId(Community.SObjectType) ; 
        SIB_BaseRequest baseRequest = new SIB_BaseRequest();
        
        baseRequest.accountId = accountId;
        baseRequest.webstoreId = webstoreId;
        baseRequest.communityId = communityId;
        System.assertEquals(accountId, baseRequest.accountId, 'Account Id should match');
    }
}