/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-27-2024
 * @last modified by  : Gaurang Arora
**/
public with sharing class SIB_ProductListingPageController {
    
    private static final String CLASSNAME = 'SIB_ProductListingPageController';

    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getProductListingConfiguration(Map<String,Object> mapParams){
        String methodName = 'getProductDetailConfiguration';
        String supportData = '';
        try{
            SIB_ProductListingPageService.getPLPConfiguration(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put('isSuccess',false);
            mapParams.put('message',ex.getMessage()); 
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> getProducts(Map<String,Object> mapParams){
        String methodName = 'getProductDetails';
        String supportData = '';
        try{
            SIB_ProductListingPageService.getProducts(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put('isSuccess',false);
            mapParams.put('message',ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getStorefrontModule(String moduleName){
        String methodName = 'getStorefrontModule';
        String supportData = '';
        Map<String,Object> mapParams = new Map<String,Object>();
        try {
            mapParams.put('moduleName', moduleName);
            List<String> sections = SIB_Util.fetchConfigByModule(moduleName);
            mapParams.put(moduleName,sections);
        } catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put('isSuccess',false);
            mapParams.put('message',ex.getMessage());
        }
        return mapParams;
    }

    /**
     * @description get category for a given category name
     * @author garora@rafter.one
     * @created 27 Sep 24
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getCategoryId(Map<String,Object> dataMap){
        try {
            dataMap = SIB_ProductListingPageService.getCategoryId(dataMap);
            dataMap.put(SIB_Constants.IS_SUCCESS, true);
        } catch (Exception e) {
            dataMap.put(SIB_Constants.IS_SUCCESS, false);
            dataMap.put(SIB_Constants.PARAM_EXCEPTION, e);
        }
        return dataMap;
    }
}