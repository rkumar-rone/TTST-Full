/**
 * @description       : Test class for SIB_CourseReviewService
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_CourseReviewServiceTest {
	@TestSetup
    static void setup(){
        Product2 prod = new Product2(Name='Test',isActive=true,SIB_Course_Id__c='test');
        insert prod;
        SIB_Course_Review__c review = new SIB_Course_Review__c();
        review.Course__c = prod.Id;
        insert review;
    }
    
    @isTest
    static void getReviewsTest(){
        SIB_Course_Review__c review = [SELECT Id,Course__c FROM SIB_Course_Review__c LIMIT 1];
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put(SIB_Constants.COURSE_ID,review.Course__c);
        Test.startTest();
        dataMap = SIB_CourseReviewService.getReviews(dataMap);
        Test.stopTest();
        system.assertEquals(1,dataMap.get(SIB_Constants.TOTAL_RATINGS),'getReviews assertion failed');
    }
    
    @isTest
    static void getReviewsFromCalloutTest(){
        List<Product2> prods = [SELECT Id,SIB_Course_Id__c FROM Product2 WHERE IsActive = true AND SIB_Course_Id__c<>NULL];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SIB_CourseReviewBatchMock());
        Map<String,Object> response = SIB_CourseReviewService.getReviewsFromCallout(prods);
        Test.stopTest();  
        system.assertEquals(true,response.get(SIB_Constants.IS_SUCCESS),'getReviewsFromCalloutTest assertion failed');
    }
}