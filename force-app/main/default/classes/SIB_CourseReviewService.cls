/**
 * @description       : Service class for SIB_CourseReviewController and SIB_CourseReviewBatch
 * @author            : Gaurang Arora
 * @last modified on  : 11-13-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CourseReviewService {

    public class CourseReviewResponse{
        public DateTime enteredDate;
        public Integer rating;
        public String name;
        public String comment;
    }

    public class CourseReviewResponses{
        public List<CourseReviewResponse> reviews;
    }

    public static Map<String,Object> getReviewsFromCallout(List<Product2> scope){
        Map<String,Object> responseMap = new Map<String,Object>();
        try{
            if(!scope.isEmpty()){
                List<Id> courseIds = new List<Id>();
                for (Product2 course : scope) {
                    courseIds.add(course.Id);
                }

                Map<String, Id> existingCourseReviews = new Map<String, Id>();
                for (SIB_Course_Review__c review : (List<SIB_Course_Review__c>)SIB_CourseReviewSelector.getReviewsByCourseId(courseIds,true)) 
                {
                    existingCourseReviews.put(review.ExternalId__c, review.Id);
                }

                List<SIB_Course_Review__c> courseReviews = new List<SIB_Course_Review__c>();

                for (Product2 course : scope) {
                    CourseReviewResponses courseReviewsResponse = makeRequest(course.SIB_Course_Id__c);
                
                    if (courseReviewsResponse.reviews != null) {
                        for (CourseReviewResponse review : courseReviewsResponse.reviews) {
                            SIB_Course_Review__c courseReview = new SIB_Course_Review__c(
                                Name = review.name,
                                Date__c = review.enteredDate,
                                Comment__c = review.comment,
                                Rating__c = review.rating,
                                Course__c = course.Id,
                                ExternalId__c = review.enteredDate + review.name
                            );

                            // Check against existing reviews
                            if (existingCourseReviews!=null && existingCourseReviews.containsKey(courseReview.ExternalId__c)) {
                                courseReview.Id = existingCourseReviews.get(courseReview.ExternalId__c);
                            }
                            courseReviews.add(courseReview);
                        }
                    }
                }
                if(!courseReviews.isEmpty()){
                    upsert courseReviews;
                }
                responseMap.put(SIB_Constants.IS_SUCCESS, true);
            }
        }
        catch(Exception e){
            responseMap.put(SIB_Constants.IS_SUCCESS, false);
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
            responseMap.put('Stack: ',e.getStackTraceString());
        }
        return responseMap;
    }

    public static CourseReviewResponses makeRequest(String courseId){
        CourseReviewResponses reviews = new CourseReviewResponses();
        List<String> namedCredential = SIB_Util.fetchConfigByModule(SIB_Constants.COURSECHECK_MODULE);
        if(!namedCredential.isEmpty()){
            String callout = namedCredential[0];
            Map<String,Object> dataMap = new Map<String,Object>();
            String endpoint = callout + '?' + SIB_Constants.COURSE_PARAM + '=' + courseId;
            dataMap.put(SIB_Constants.HTTP_ENDPOINT, endpoint);
            dataMap.put(SIB_Constants.HTTP_AUTHORIZATION_HEADER, SIB_Constants.HTTP_BASIC_AUTHORIZATION);
            dataMap.put(SIB_Constants.HTTP_METHOD,SIB_Constants.HTTP_GET_METHOD);
            dataMap = SIB_Util.makeHttpCallout(dataMap);
            if(dataMap!=null && dataMap.containsKey(SIB_Constants.HTTP_RESPONSE) && dataMap.get(SIB_Constants.HTTP_RESPONSE)!=null){
                String jsonString = (String)dataMap.get(SIB_Constants.HTTP_RESPONSE);
                jsonString = jsonString.replace('"date":', '"enteredDate":');
                reviews = (CourseReviewResponses)JSON.deserialize(jsonString, CourseReviewResponses.class);
            }
        }
        return reviews;
    }

    public static Map<String,Object> getReviews(Map<String,Object> dataMap){
        if(dataMap!=null && dataMap.containsKey(SIB_Constants.COURSE_ID) && dataMap.get(SIB_Constants.COURSE_ID)!=null) {
            List<Id> productIds = new List<Id>();
            String parentCourseId = null;
            String courseId = (String)dataMap.get(SIB_Constants.COURSE_ID);
            List<ProductAttribute> productAttributes = [SELECT ProductId, VariantParentId FROM ProductAttribute WHERE ProductId = :courseId];

            if(productAttributes != null && !productAttributes.isEmpty()) {
                parentCourseId = productAttributes.get(0).VariantParentId;
                productIds.add(parentCourseId);
            } else {
                productIds.add(courseId);
            }

            if(productIds != null && !productIds.isEmpty()) {
                List<SIB_Course_Review__c> reviews = (List<SIB_Course_Review__c>) SIB_CourseReviewSelector.getReviewsByCourseId(productIds, false);

                Map<String,List<SIB_Course_Review__c>> productIdAndReviewMap = new Map<String,List<SIB_Course_Review__c>>();
                for(SIB_Course_Review__c reviewObj : reviews) {
                    if(!productIdAndReviewMap.containsKey(reviewObj.Course__c)) {
                        productIdAndReviewMap.put(reviewObj.Course__c, new List<SIB_Course_Review__c>());
                    } 
                    List<SIB_Course_Review__c> reviewList = productIdAndReviewMap.get(reviewObj.Course__c);
                    reviewList.add(reviewObj);
                    productIdAndReviewMap.put(reviewObj.Course__c, reviewList);
                }

                List<SIB_Course_Review__c> productReviewList = productIdAndReviewMap.get(courseId);
                if(productReviewList != null && !productReviewList.isEmpty()) {
                    dataMap.put(SIB_Constants.REVIEWS, productReviewList);
                    dataMap.put(SIB_Constants.AVERAGE_RATING, SIB_CourseReviewSelector.getAggregateAvg(courseId));
                    dataMap.put(SIB_Constants.TOTAL_RATINGS, SIB_CourseReviewSelector.getAggregateCount(courseId));
                } else if(parentCourseId != null) {
                    List<SIB_Course_Review__c> parentProductReviewList = productIdAndReviewMap.get(parentCourseId);
                    dataMap.put(SIB_Constants.REVIEWS, parentProductReviewList);
                    dataMap.put(SIB_Constants.AVERAGE_RATING, SIB_CourseReviewSelector.getAggregateAvg(parentCourseId));
                    dataMap.put(SIB_Constants.TOTAL_RATINGS, SIB_CourseReviewSelector.getAggregateCount(parentCourseId));
                } else {
                    dataMap.put(SIB_Constants.REVIEWS, null);
                    dataMap.put(SIB_Constants.AVERAGE_RATING, null);
                    dataMap.put(SIB_Constants.TOTAL_RATINGS, null);
                }
            }
        }
        return dataMap;
    }
}