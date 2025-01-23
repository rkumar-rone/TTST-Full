/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_ProductDetailController {

    private static final String CLASSNAME = 'SIB_ProductDetailController';

    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getProductDetailConfiguration(Map<String,Object> mapParams){
        String methodName = 'getProductDetailConfiguration';
        String supportData = '';
        try{
            SIB_ProductDetailService.getPDPConfiguration(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> getProductDetails(Map<String,Object> mapParams){
        String methodName = 'getProductDetails';
        String supportData = '';
        try{
            SIB_ProductDetailService.getProductDetails(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getRelatedProducts(Map<String,Object> mapParams){
        String methodName = 'getRelatedProducts';
        String supportData = '';
        try{
            SIB_ProductDetailService.getRelatedProducts(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> updateBuyerAndAccountCurrency(Map<String,Object> mapParams){
        String methodName = 'updateBuyerAndAccountCurrency';
        String supportData = '';
        try{
            SIB_ProductDetailService.updateBuyerAndAccountCurrency(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> getEventRelationshipChildNames(Map<String,Object> mapParams){
        String methodName = 'getEventRelationshipChildNames';
        String supportData = '';
        try{
            SIB_ProductDetailService.getEventRelationshipChildNames(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> getProductCurrency(Map<String,Object> mapParams){
        String methodName = 'getProductCurrency';
        String supportData = '';
        try{
            SIB_ProductDetailService.getProductCurrency(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_Constants.IS_SUCCESS,false);
            mapParams.put(SIB_Constants.PARAM_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }
}