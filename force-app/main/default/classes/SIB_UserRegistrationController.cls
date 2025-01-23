/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 10-13-2024
 * @last modified by  : Gaurav Setia
**/
public without sharing class SIB_UserRegistrationController {
    private static final String CLASSNAME = 'SIB_UserRegistrationController';
    private static final String MODULE_NAME = 'User Registration Module';

    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getRegistrationConfiguration(Map<String,Object> mapParams){
        String methodName = 'getRegistrationConfiguration';
        String supportData = '';
        try{
            SIB_UserRegistrationService.getRegistrationConfiguration(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String, Object> initUserRegistration(Map<String, Object> dataMap) {

        String methodName = 'initUserRegistration';
        String supportData = '';
        Savepoint savepointObject = Database.setSavepoint();
        try {
            if (SIB_UserRegistrationHelper.validateRequest(dataMap)) {   
                SIB_UserRegistrationService.registerUser(dataMap);
            } else {
                dataMap.put(SIB_Constants.IS_SUCCESS, false);
                dataMap.put(SIB_Constants.MESSAGE, 'Invalid Request');
            }
        } catch (Exception ex) {
            Database.rollback(savepointObject);
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(SIB_Constants.IS_SUCCESS, false);
            dataMap.put(SIB_Constants.MESSAGE, ex.getMessage());
        }
        return dataMap;
    }

    @AuraEnabled
    public static Map<String, Object> initUserLogin(Map<String, Object> dataMap) {
        String methodName = 'initUserLogin';
        String supportData = '';
        try {
            SIB_UserRegistrationService.getLoginURL(dataMap);
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(SIB_Constants.IS_SUCCESS, false);
            dataMap.put(SIB_Constants.MESSAGE, ex.getMessage());
        }
        return dataMap;
    }

    @AuraEnabled
    public static Map<String, Object> getStrivacityLoginUrl(Map<String, Object> dataMap) {
        String methodName = 'getStrivacityLoginUrl';
        String supportData = '';
        try {
            SIB_UserRegistrationService.getStrivacityLoginUrl(dataMap);
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(SIB_Constants.IS_SUCCESS, false);
            dataMap.put(SIB_Constants.MESSAGE, ex.getMessage());
        }
        return dataMap;
    }
}