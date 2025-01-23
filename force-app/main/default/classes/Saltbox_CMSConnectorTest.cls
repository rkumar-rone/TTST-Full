/**
 * @description         : Test class for Saltbox_CMSConnector.cls
 * @author              : Shane Smyth
 * @last modified on    : 12-15-2021
 * @last modified by    : Shane Smyth
 */
@isTest(SeeAllData=true)
public with sharing class Saltbox_CMSConnectorTest {
    public Saltbox_CMSConnectorTest() {

    }

    @IsTest
    static void doTest() {

        //MCJU55HZKY7BHPFJJHXF3LKJLAMU
        String CMS_IMAGE_KEY = System.Label.Test_CMS_Key;
        String NETWORK_ID = System.Label.Saltbox_Network_ID;
        String [] arrayOfProducts = new List<String>();
        arrayOfProducts.add(CMS_IMAGE_KEY);
        NetworkMember netMember = [SELECT MemberId FROM NetworkMember WHERE NetworkId = :NETWORK_ID LIMIT 1];
        User communityUser = [SELECT Id FROM User WHERE Id = :netMember.MemberId];
       


        Test.startTest();
        System.runAs(communityUser){
            String managedContent = Saltbox_CMSConnector.getManagedContentByContentKeys(arrayOfProducts);
            Map<String, Object> content = (Map<String, Object>)JSON.deserializeUntyped(managedContent);
            System.debug(content);
            Object success = content.get('success');
            
            System.assertEquals(true, success);
        }
            
        Test.stopTest();

    }

        @IsTest
    static void doTestException() {
        try{
            String CMS_IMAGE_KEY = System.Label.Test_CMS_Key;
            String NETWORK_ID = System.Label.Saltbox_Network_ID;
            String [] arrayOfProducts = new List<String>();
            NetworkMember netMember = [SELECT MemberId FROM NetworkMember WHERE NetworkId = :NETWORK_ID LIMIT 1];
            User communityUser = [SELECT Id FROM User WHERE Id = :netMember.MemberId];
           
    
    
            Test.startTest();
            System.runAs(communityUser){
                String managedContent = Saltbox_CMSConnector.getManagedContentByContentKeys(arrayOfProducts);
                Map<String, Object> content = (Map<String, Object>)JSON.deserializeUntyped(managedContent);
                System.debug(content);
                 Object success = content.get('success');
           System.assertEquals(true, success);

            }
                
            Test.stopTest();
        } catch(Exception e){
            
        }
    }
    @IsTest
    static void doTestConnectApiException() {
        try{
            String CMS_IMAGE_KEY = System.Label.Test_CMS_Key;
            String NETWORK_ID = System.Label.Saltbox_Network_ID;
            String [] arrayOfProducts = new List<String>();
            arrayOfProducts.add('1111111111111111111');
            NetworkMember netMember = [SELECT MemberId FROM NetworkMember WHERE NetworkId = :NETWORK_ID LIMIT 1];
            User communityUser = [SELECT Id FROM User WHERE Id = :netMember.MemberId];
           
    
    
            Test.startTest();
            System.runAs(communityUser){
                String managedContent = Saltbox_CMSConnector.getManagedContentByContentKeys(arrayOfProducts);
                Map<String, Object> content = (Map<String, Object>)JSON.deserializeUntyped(managedContent);
                System.debug(content);
                 Object success = content.get('success');
           System.assertEquals(true, success);

            }
                
            Test.stopTest();
        } catch(Exception e){
            System.debug('e1 '+e.getMessage());
             System.assertEquals('Only output types from ConnectApi support serialization',e.getMessage());
        }
    }
}