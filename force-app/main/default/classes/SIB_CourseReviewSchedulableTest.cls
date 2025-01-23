/**
 * @description       : Test class for SIB_CourseReviewSchedulable
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_CourseReviewSchedulableTest {
	@TestSetup
    static void setup(){
        Product2 prod = new Product2(Name='Test',SIB_Course_Id__c='test',isActive=true);
        insert prod;
        SIB_Course_Review__c review = new SIB_Course_Review__c();
        review.ExternalId__c='2024-05-06 10:22:14Test';
        review.Course__c = prod.Id;
        insert review;
    }
    
    @isTest
    static void schedulableTest(){
    	Test.setMock(HttpCalloutMock.class, new SIB_CourseReviewBatchMock());
        SIB_CourseReviewSchedulable myClass = new SIB_CourseReviewSchedulable();   
        myClass.execute(null);
    }
}