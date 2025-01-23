/**
 * @description       : Mock callout class for SIB_CourseReviewBatch
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
global class SIB_CourseReviewBatchMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{ "reviews" : [ { "date": "2024-05-06T10:22:14", "rating": "5" , "name": "Test" , "comment": "Test" }]}');
        res.setStatusCode(200);
        return res;
    }
}