/**
* @description : Test class for Saltbox_eRecommendationsController
* @created Date : 06-12-2022
* @Author : Nicolas Gala
* @LastModified : 06-12-2022
*/
@isTest(SeeAllData=true)
public class Saltbox_eRecommendationsControllerTest {
    
    @isTest 
    static void testGetERecommendations(){
        Test.setMock(HttpCalloutMock.class, new Saltbox_MockHttpEinstein());

        String tUser = System.label.Saltbox_Test_User_ID;

        User testUser = [SELECT Id,ContactId FROM User WHERE Id = :tUser LIMIT 1]; 
        System.runAs(testUser) { 
           
            Test.startTest();
            String data =  Saltbox_eRecommendationsController.getERecommendations('SimilarProducts', 'randomId123', 'CookieConsentPolicy=0:1');
            Test.stopTest();
      
            System.assertNotEquals(null, data);
        }
    }

}