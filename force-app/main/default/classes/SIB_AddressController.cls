/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 23-09-2024
 * @last modified by  : Gaurang Arora
**/
public with sharing class SIB_AddressController {

    private static final String STOREFRONT = 'B2B Storefront';
    private static final String CLASSNAME = 'SIB_ShippingController';
    private static final String MODULE_NAME = 'Shipping Module';

    @AuraEnabled
    public static Map<String,Object> getAllAddressesForAccount(Map<String,Object> mapParams){
        String methodName = 'getAllAddresses';
        String supportData = '';
        try{
            mapParams = SIB_AddressHelper.getAllAddressesForAccount(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams ;
            mapParams.put('isSuccess', false);
            mapParams.put('msg', ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    /**
    * @description Gets contact point address related to current Account
     * @param dataMap - Input Param
    * @return Map<List,Object>
    */
    @AuraEnabled
    public static Map<String,Object> getContactPointAddresses(Map<String,Object> dataMap) {
        String methodName ='getContactPointAddresses';
        String supportData = '';
        try{
            dataMap = SIB_AddressHelper.getContactPointAddresses(dataMap);
            dataMap.put(SIB_Constants.IS_SUCCESS, true);
        }
        catch(Exception ex){
            dataMap.put(SIB_Constants.IS_SUCCESS, false);
            dataMap.put(SIB_Constants.PARAM_EXCEPTION, ex);
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

    /**
     * @description this method upserts CPA and populates address on cart and cart delivery group
     * @author garora@rafter.one
     * @param dataMap - Input Param
     * @created 16 Sep 24
     * @return Map<String,Object>
     */
    @AuraEnabled
    public static Map<String,Object> updateCartWithCPA(Map<String,Object> dataMap){
        String methodName = 'updateCartWithCPA';
        String supportData = '';
        try {
            dataMap = SIB_AddressHelper.updateCartWithCPA(dataMap);
            dataMap.put(SIB_Constants.IS_SUCCESS, true);
        } catch (Exception ex) {
            dataMap.put(SIB_Constants.IS_SUCCESS, false);
            dataMap.put(SIB_Constants.PARAM_EXCEPTION, ex);
            dataMap.put('Stack',ex.getStackTraceString());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

}