/**
 * @description       : Test class for SIB_CourseReviewController
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_CourseReviewControllerTest {
	@TestSetup
    static void setup(){
        Product2 prod = new Product2(Name='Test');
        insert prod;
        SIB_Course_Review__c review = new SIB_Course_Review__c();
        review.Course__c = prod.Id;
        insert review;
    }
    
    @isTest
    static void getStoredReviewsTest(){
        SIB_Course_Review__c review = [SELECT Id,Course__c FROM SIB_Course_Review__c LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.COURSE_ID,review.Course__c);
        Test.startTest();
        dataMap = SIB_CourseReviewController.getStoredReviews(dataMap);
        Test.stopTest();
        system.assertEquals(true,dataMap.get(SIB_Constants.IS_SUCCESS),'getStoredReviewsTest assertion failed');
    }
    
    @isTest
    static void getStoredReviewsExceptionTest(){
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.COURSE_ID,'exception35505');
        Test.startTest();
        dataMap = SIB_CourseReviewController.getStoredReviews(dataMap);
        Test.stopTest();
        system.assertEquals(false,dataMap.get(SIB_Constants.IS_SUCCESS),'getStoredReviewsTest assertion failed');
    }
}