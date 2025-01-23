/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-29-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CartController {
    
    private static final String CLASSNAME = 'SIB_CartController';
    private static final String STOREFRONT = 'B2B Storefront';
    private static final String MODULE_NAME = 'Cart Module';

    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getCartConfiguration(Map<String,Object> mapParams){
        String methodName = 'getCartConfiguration';
        String supportData = '';
        try{
            SIB_CartService.getCartConfiguration(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams; 
    }

    @AuraEnabled
    public static Map<String,Object> getCartDetails(Map<String,Object> mapParams){
        String methodName = 'getCartDetails';
        String supportData = '';
        try{
            SIB_CartService.getCartConfiguration(mapParams);
            //fetch cart details
            SIB_CartService.getCartSummary(mapParams);
            //fetch cart items
            SIB_CartService.getCartItems(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage()+'-'+ex.getStackTraceString());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> updateCartItem(Map<String,Object> mapParams){
        String methodName = 'updateCartItem';
        String supportData = '';
        try{
            SIB_CartService.updateCartItem(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> deleteCartItem(Map<String,Object> mapParams){
        String methodName = 'deleteCartItem';
        String supportData = '';
        try{
            SIB_CartService.deleteCartItem(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> clearCart(Map<String,Object> mapParams){
        String methodName = 'clearCart';
        String supportData = '';
        try{
            SIB_CartService.clearCart(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> activateCart(Map<String,Object> mapParams){
        String methodName = 'activateCart';
        String supportData = '';
        try{
            SIB_CartService.activateCart(mapParams);
            mapParams.put(SIB_Constants.IS_SUCCESS, true);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> addCartItem(Map<String,Object> mapParams){
        String methodName = 'addCartItem';
        String supportData = '';
        try{
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Started');
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Request Param');
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , JSON.serialize(mapParams));
            SIB_CartService.addCartItem(mapParams);
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_EXIT , 'End');
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> calculateCart(Map<String,Object> mapParams){
        String methodName = 'calculateCart';
        String supportData = '';
        try{
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Started');
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , 'Request Param');
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_ENTRY , JSON.serialize(mapParams));
            SIB_CartService.calculateCart(mapParams);
            SIB_Logger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , SIB_LoggingConstant.MESSAGING_EXIT , 'End');
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> preserveGuestCart(Map<String,Object> mapParams){
        String methodName = 'preserveGuestCart';
        String supportData = '';
        try{
            SIB_CartService.preserveGuestCart(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> compareCurrency(Map<String,Object> mapParams){
        String methodName = 'compareCurrency';
        String supportData = '';
        try{
            SIB_CartService.compareCurrency(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> updateCheckOutCartStatus(Map<String,Object> mapParams){
        String methodName = 'updateCheckOutCartStatus';
        String supportData = '';
        try{
            SIB_CartService.updateCheckOutCartStatus(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
            SIB_ExceptionLog.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        }finally
        {
            SIB_Logger.handleApplicationLogging(mapParams);
        }
        return mapParams;
    }
}