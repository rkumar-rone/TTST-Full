/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 03-06-2024
 * @last modified by  : Jassimran Virdi
**/
public with sharing class SIB_OrderController {
    
    private static final String CLASSNAME = 'SIB_OrderController';

    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getOrderConfiguration(Map<String,Object> mapParams){
        String methodName = 'getOrderConfiguration';
        String supportData = '';
        try{
            SIB_OrderService.getOrderConfiguration(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put('isSuccess',false);
            mapParams.put('message',ex.getMessage());
        }
        return mapParams;
    }

    @AuraEnabled
    public static Map<String,Object> getOrderDetails(Map<String,Object> mapParams){
        String methodName = 'getOrderDetails';
        String supportData = '';
        try{
            SIB_OrderService.getOrderDetails(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put('isSuccess',false);
            mapParams.put('message',ex.getMessage());
        }
        return mapParams;
    }
}