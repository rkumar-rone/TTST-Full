/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 10-12-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_CybersourceController {

    private static final String CLASSNAME = 'SIB_CybersourceController';

    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> generateKey(Map<String,Object> mapParams){
        String methodName = SIB_SetupConstants.CYBERSOURCE_METHOD_GENERATEKEY;
        String supportData = '';
        try{
            SIB_CybersourceService.generateKey(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.MESSAGE,ex.getMessage());
        }

        return mapParams;
    }

    /**
     * @description Aura enabled method to get authorization for payment
     * @created 18 Sep 24
     * @param paymentsData | Map<String,Object>
     * @returns Map<String, Object>
     */
    @AuraEnabled 
    public static Map<String, Object> proceedToPayment(Map<String, Object> paymentsData) {
        String methodName = 'proceedToPayment';

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);
        try{
            if(null != paymentsData && !paymentsData.isEmpty()) {
                Map<String, Object> paymentResponse =  SIB_CybersourceService.authorizePayment(paymentsData);
                responseMap.putAll(paymentResponse);
                responseMap.put(SIB_Constants.PARAM_PAYMENTTYPE, SIB_Constants.PARAM_PAYMENTTYPE_AUTH);
            }

        }catch(Exception e) {
            responseMap.put(SIB_Constants.MESSAGE, e.getMessage());
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
        }

        return responseMap;
    }

    /**
     * @description Aura enabled method to update the payment method and payment group on the cart after payment authorization
     * @created 26 Sep 24
     * @params requestMap | Map<String, Object>
     * @returns Map<String, Object>
     */
    @AuraEnabled 
    public static Map<String, Object> updatePaymentMethodOnCart(Map<String, Object> requestMap) {
        String methodName = 'updatePaymentMethodOnCart';
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try{
            Map<String, Object> paymentResponse = SIB_CybersourceService.updatePaymentMethodOnCart(requestMap);
            responseMap.putAll(paymentResponse);
        }catch(Exception e) {
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_CouldNotCompleteAuthroization); 
        }

        return responseMap;
    }

    /**
     * @description Returns information user account
     * @created Oct 3 24
     * @params effectiveAccountId | String
     * @returns Map<String, Object> 
     */
    @AuraEnabled
    public static Map<String, Object> getAccountInformation(Map<String, Object> requestMap) {
        String methodName = 'getAccountInformation';
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            responseMap = SIB_CybersourceService.getAccountInformation(requestMap);
            
        }catch(Exception e) {
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_GenericExceptionMessage);
        }
        return responseMap;
    }

    /**
     * @description Aura Enabled method to capture a payment authorization 
     */
    @AuraEnabled
    public static Map<String, Object> capturePaymentAuthorization(Map<String, Object> requestMap) {
        String methodName = 'capturePaymentAuthorization';
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            responseMap = SIB_CybersourceService.capturePaymentFromAuthorization(requestMap);
        }catch(Exception e) {
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_GenericExceptionMessage);
        }

        return responseMap;
    }

    /**
     * @description Revert an authorization on card
     * 
     */
    @AuraEnabled 
    public static Map<String, Object> revertAuthorization(Map<String, Object> requestMap) {
        String methodName = 'revertAuthorization';
        Map<String, Object> responseMap = new Map<String, Object>();

        try{
            responseMap = SIB_CybersourceService.revertAuthorization(requestMap);
        }catch(Exception e){
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_GenericExceptionMessage);
        }

        return responseMap;
    }

    @AuraEnabled 
    public static Map<String, Object> getCartPaymentStatus(Map<String, Object> requestMap) {
        String methodName = 'getCartPaymentStatus';
        Map<String, Object> responseMap = new Map<String, Object>();

        try{

            responseMap = SIB_CybersourceService.getCartPaymentStatus(requestMap);
        }catch(Exception e) {
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_GenericExceptionMessage);
        }

        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getPaymentModule(Map<String,Object> mapParams){
        String methodName = 'getPaymentModule';
        try {
            mapParams = SIB_CybersourceService.getPaymentModule(mapParams);
        } catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.MESSAGE,ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled 
    public static Map<String, Object> getAuthorizationInformation(Map<String, Object> requestMap) {
        String methodName = 'getAuthorizationInformation';

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);

        try{
            responseMap = SIB_CybersourceService.getAuthorizationInformation(requestMap);
        }catch(Exception e) {
            responseMap.put(SIB_Constants.PARAM_EXCEPTION, e);
            responseMap.put(SIB_Constants.MESSAGE, System.Label.SIB_GenericExceptionMessage);
        }

        return responseMap;
    }
}