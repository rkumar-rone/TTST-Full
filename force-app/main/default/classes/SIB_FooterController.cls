/**
 * @description       : 
 * @author            : Amit Prashar
 * @group             : 
 * @last modified on  : 27-08-2024
 * @last modified by  : Amit Prashar
**/
public with sharing class SIB_FooterController {

    private static final String CLASSNAME = 'SIB_FooterController';

    @AuraEnabled(Cacheable=true)
    public static Map<String,Object> getFooterConfiguration(Map<String,Object> mapParams){
        String methodName = 'getProductDetailConfiguration';
        String supportData = '';
        try{
            SIB_FooterService.getFooterConfiguration(mapParams);
        }catch (Exception ex) {
            mapParams = mapParams==null ? new Map<String,Object>() : mapParams ;
            mapParams.put(SIB_SetupConstants.IS_SUCCESS,false);
            mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE,ex.getMessage());
        }
        return mapParams;
    }
}