/**
 * @description       : Test class for SIB_CourseReviewBatch
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_CourseReviewBatchTest {
	@TestSetup
    static void setup(){
        Product2 prod = new Product2(Name='Test',isActive=true,SIB_Course_Id__c='test');
        insert prod;
        SIB_Course_Review__c review = new SIB_Course_Review__c();
        review.Course__c = prod.Id;
        insert review;
    }
    
    @isTest
    static void executeTest(){
        Test.startTest();
        database.executeBatch(new SIB_CourseReviewBatch(),1);
        Test.stopTest();
    }
}