/**
 * @description       : 
 * @author            : Amit Prashar
 * @group             : 
 * @last modified on  : 08-27-2024
 * @last modified by  : Amit Prashar
**/
public with sharing class SIB_FooterService {

    public static Map<String,Object> getFooterConfiguration(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        mapParams.put(SIB_SetupConstants.CONFIGURATION_TYPE,SIB_SetupConstants.CONFIG_TYPE );
        SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams != null && mapParams.containsKey(SIB_SetupConstants.CONFIG_JSON) && mapParams.get(SIB_SetupConstants.CONFIG_JSON) != null ) {
            SIB_FooterConfiguration footerConfig = SIB_FooterConfiguration.parse((String)mapParams.get(SIB_SetupConstants.CONFIG_JSON));
            mapParams.put(SIB_SetupConstants.FOOTER_CONFIG, footerConfig);
            isSuccess = true;
        }else{
            message = SIB_SetupConstants.FOOTER_CONFIG_NOT_FOUND;
        }
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        return mapParams;
    }
}