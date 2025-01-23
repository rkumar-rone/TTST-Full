/**
 * @description       : Controller class for Course Review related functionality
 * @author            : Gaurang Arora
 * @last modified on  : 11-13-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CourseReviewController {

    private static final String CLASSNAME = 'SIB_CourseReviewController';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Cart Review Module';
    
    @AuraEnabled
    public static Map<String,Object> getStoredReviews(Map<String,Object> dataMap){
        String methodName = 'getStoredReviews';
        String supportData = '';
        try {
            dataMap = SIB_CourseReviewService.getReviews(dataMap);
            dataMap.put(SIB_Constants.IS_SUCCESS, true);
        } catch (Exception ex) {
            dataMap.put(SIB_Constants.IS_SUCCESS, false);
            dataMap.put(SIB_Constants.PARAM_EXCEPTION, ex);
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        } finally {
            SIB_Logger.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }
}