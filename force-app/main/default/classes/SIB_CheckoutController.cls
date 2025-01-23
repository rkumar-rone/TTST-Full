/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-10-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CheckoutController {
    
    private static final String CLASSNAME = 'SIB_CheckoutController';

    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getCheckoutConfiguration(Map<String,Object> mapParams){
        String methodName = 'getCartConfiguration';
        String supportData = '';
        try{
            SIB_CheckoutService.getCheckoutConfiguration(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }

    /**
     * @description this method fetches data required for group order functionality
     * @author vramachandran@rafter.one
     * @created 10 Sep 24
     */
    @AuraEnabled 
    public static Map<String, Object> getGroupOrderInformation(Map<String, Object> requestMap){
        String methodName = 'getGroupOrderInformation';

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);
        try{
            responseMap.putAll(SIB_CheckoutService.getGroupOrderInformation(requestMap));
            responseMap.put(SIB_Constants.IS_SUCCESS, true);
        }catch (Exception e) {
    
            responseMap.put(SIB_Constants.MESSAGE, System.Label.B2B_GenericExceptionMessage);
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
        }
        
        return responseMap;
    }

    /**
     * @description this method updates cart to mark as waitlisted
     * @author vramachandran@rafter.one
     * @created 16 Sep 24
     */
    @AuraEnabled 
    public static Map<String, Object> updateCartAndCartItems(Map<String, Object> requestMap) {
        String methodName = 'updateCartAndCartItems';

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);
        try{
            responseMap.putAll(SIB_CheckoutService.updateCartAndCartItems(requestMap));
        }catch(Exception e) {
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_GenericExceptionMessage);
        }

        return responseMap;
    }
}