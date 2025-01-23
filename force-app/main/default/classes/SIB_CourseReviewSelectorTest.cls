/**
 * @description       : Test class for SIB_CourseReviewSelectorTest
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_CourseReviewSelectorTest {
	@TestSetup
    static void setup(){
        Product2 prod = new Product2(Name='Test',isActive=true,SIB_Course_Id__c='test');
        insert prod;
        SIB_Course_Review__c review = new SIB_Course_Review__c();
        review.Course__c = prod.Id;
        review.Rating__c = 5;
        insert review;
    }
    
    @isTest
    static void getReviewsByCourseIdTest(){
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        List<SIB_Course_Review__c> reviews = (List<SIB_Course_Review__c>) SIB_CourseReviewSelector.getReviewsByCourseId(new List<Id>{prod.Id}, true);
        Test.stopTest();
        system.assertEquals(true,reviews.size()>0,'getReviewsByCourseId assertion failed');
    }
    
    @isTest
    static void getAggregateCountTest(){
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        Integer reviews = SIB_CourseReviewSelector.getAggregateCount(prod.Id);
        Test.stopTest();
        system.assertEquals(1,reviews,'getAggregateCountTest assertion failed');
    }
    
    @isTest
    static void getAggregateAvgTest(){
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        Decimal reviews = SIB_CourseReviewSelector.getAggregateAvg(prod.Id);
        Test.stopTest();
        system.assertEquals(5,reviews,'getAggregateAvg assertion failed');
    }
}