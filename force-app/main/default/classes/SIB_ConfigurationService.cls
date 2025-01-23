public with sharing class SIB_ConfigurationService {

    private static final String CLASSNAME = 'SIB_ConfigurationService';
    

    public static Map<String,Object> getConfigurationJSON(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        //Logger.debug('SIB_ConfigurationService: getConfigurationJSON: config parameters - mapParams: '+mapParams,'Configuration');

        if(mapParams.containsKey('configurationType')){
            String configurationType = String.valueOf(mapParams.get('configurationType'));
            //Logger.debug('SIB_ConfigurationService: getConfigurationJSON: configurationType: '+configurationType,'Configuration');
            Sobject storeConfig = SIB_ConfigurationSelector.getConfigurationSelectorByType(configurationType) ;
            //Logger.debug('SIB_ConfigurationService: getConfigurationJSON: storeConfig: '+storeConfig,'Configuration');
            if(storeConfig != null){
                mapParams.put('configJSON', (String)storeConfig.get(SIB_ConfigurationSelector.getConfigJSONField()));
                isSuccess = true;
            }else{
                message = configurationType+' Configuration not found.';
            }
        }else{
            message = 'Invalid Request : configurationType not found.';
        }
        //Logger.saveLog();
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    public static Map<String, Object> getEncryptedFederationId() {

        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(SIB_Constants.IS_SUCCESS, false);

        User fetchedUser = SIB_UserSelector.getUserInformationForUserId(UserInfo.getUserId());
        if(null != fetchedUser && String.isNotBlank(fetchedUser?.FederationIdentifier)
        && String.isNotBlank(fetchedUser?.Contact?.Strivacity_Identifier__c)) {

            String federationId = fetchedUser?.Contact?.Strivacity_Identifier__c;
            if(String.isNotBlank(federationId)) {

                String encryptedFederationId = SIB_EncryptionUtil.encryptWithManagedIV(federationId);
                responseMap.put(SIB_Constants.ENCRYPTED_FEDERATION_ID, encryptedFederationId);
                responseMap.put(SIB_Constants.IS_SUCCESS, true);
            }
        } 

        return responseMap;
    }

}