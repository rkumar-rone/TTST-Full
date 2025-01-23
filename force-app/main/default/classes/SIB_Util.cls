/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-12-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_Util {

    private static Map<String,SObjectType> globalDescribe = Schema.getGlobalDescribe();
    
    public static String getAllObjectFields(String sObjectName) {
        return getAllObjectFields(sObjectName, null);
    }
    
    public static String getAllObjectFields(String sObjectName, Set<String> excludeFields) {
        Schema.SObjectType targetType = globalDescribe.get(sObjectName);
        Set<String> fieldList = targetType.getDescribe().fields.getMap().keySet();
        if (excludeFields != null) fieldList.removeAll(excludeFields);
        String allFields = String.join(new List<String>(fieldList), ', ');
        return allFields;
    }

    public static String getRegistrationBuyerGroupName(){
        String buyerGroupName = fetchConfigByValue('DefaultBuyerGroup');
        return buyerGroupName;
    }

    public static String getRegistrationProfileName() {
        return fetchConfigByValue('DefaultUserProfile');
    }
    
    public static List<String> getBuyerPermissionSetName(){
        String buyerPermissionSetNameStr = fetchConfigByValue('RequiredPermissionSet');
        List<String> buyerPermissionSetList = new List<String>();
        if(String.isNotBlank(buyerPermissionSetNameStr)){
            buyerPermissionSetList = buyerPermissionSetNameStr.split(',');
        }
        return buyerPermissionSetList;
    }

    public static String getTimeZoneSidKey() {
        return fetchConfigByValue('DefaultUserTimeZoneSidKey'); //'America/New_York';
    }

    public static String getLocaleSidKey() {
        return fetchConfigByValue('DefaultUserLocaleSidKey'); //'en_US';
    }

    public static String getLanguageLocaleKey() {
        return fetchConfigByValue('DefaultLanguageLocaleKey'); //'en_US';
    }

    public static String fetchConfigByValue(String labelName) {
        String value = '';  
        SIB_Storefront_Configuration__mdt config = SIB_Storefront_Configuration__mdt.getInstance(labelName);
        if(config!=null){
            value = String.isNotBlank(config.Value__c) ? config.Value__c : '';
        }
        return value;
    }

    /**
     * @description used for Self-Study
     * @author garora@rafter.one
     * @created 10 Sep 24
     */
    public static List<String> fetchConfigByModule(String moduleName) {
        List<String> values = new List<String>();  
        for(SIB_Storefront_Configuration__mdt config: [SELECT MasterLabel, Value__c FROM SIB_Storefront_Configuration__mdt WHERE Module_Name__c = :moduleName ORDER BY MasterLabel]){
            values.add(config.Value__c);
        }
        return values;
    }

    public static Map<String, Object> fetchConfigMapByModule(String moduleName) {
        Map<String, Object> mapConfig = new Map<String, Object>();  
        for(SIB_Storefront_Configuration__mdt config: [SELECT MasterLabel, Value__c FROM SIB_Storefront_Configuration__mdt WHERE Module_Name__c = :moduleName ORDER BY MasterLabel]){
            mapConfig.put(config.MasterLabel, config.Value__c);
        }
        return mapConfig;
    }

    /**
     * @description helper method to check if cart is a group cart
     * @author vramachandran@rafter.one
     * @created 11 Sep 24
     */
    public static Boolean checkForGroupOrderCart(List<CartItem> cartItems) {
        Boolean isGroupCart = true;
        if(null != cartItems && !cartItems.isEmpty()) {
            
            for(CartItem cartItemRecord : cartItems) {

                if(cartItemRecord?.Quantity > 1) {
                    isGroupCart = false;
                    break;
                }
            }
        }

        return isGroupCart;
    }

    /**
     * @description method returns flag to indicate if sandbox or not
     * @created vramachandran@rafter.one
     */
    public static Boolean isSandboxOrg() {
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        return isSandbox;
    }

    /**
     * @description generic method to make HttpCallout
     * @author garora@rafter.one
     * @created 25 Sep 24
     */
    public static Map<String,Object> makeHttpCallout(Map<String,Object> dataMap){
        HttpRequest req = new HttpRequest();
        if(dataMap.get(SIB_Constants.HTTP_ENDPOINT) != null){
            req.setEndpoint((String)dataMap.get(SIB_Constants.HTTP_ENDPOINT));
        }
        if(dataMap.get(SIB_Constants.HTTP_AUTHORIZATION_HEADER)!=null){
            if(dataMap.get(SIB_Constants.HTTP_AUTHORIZATION_HEADER) == SIB_Constants.HTTP_BASIC_AUTHORIZATION){
                Blob headerValue = Blob.valueOf('{!$Credential.UserName}' + ':' + '{!$Credential.Password}');
                String authorizationHeader = SIB_Constants.HTTP_BASIC_AUTHORIZATION + ' ' + EncodingUtil.base64Encode(headerValue);
                req.setHeader(SIB_Constants.HTTP_AUTHORIZATION_HEADER, authorizationHeader);
            }
        }
        if(dataMap.get(SIB_Constants.HTTP_METHOD)!=null){
            req.setMethod((String)dataMap.get(SIB_Constants.HTTP_METHOD));
        }
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if(res.getStatusCode()==200){
            dataMap.put(SIB_Constants.HTTP_RESPONSE,res.getBody());
        }
        return dataMap;
    }

    public static List<sObject> updateSObjectsList(List<sObject> sObjectsToUpdate) {
        if(null != sObjectsToUpdate && !sObjectsToUpdate.isEmpty()){
            update sObjectsToUpdate;
        }

        return sObjectsToUpdate;
    }    
}