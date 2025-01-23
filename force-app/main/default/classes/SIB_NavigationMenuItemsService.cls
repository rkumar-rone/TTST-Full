/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 03-13-2024
 * @last modified by  : sthakur@rafter.one
**/
public with sharing class SIB_NavigationMenuItemsService {

    private static final String CONFIG_TYPE = SIB_SetupConstants.CONFIGURATION_TYPE_MEGA_MENU;
    
    public static Map<String,Object> updateSelectedAddAsDefault(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        //creatPaymentIntentInStripe(mapParams);
        System.debug('updateSelectedAddAsDefault mapParams--- '+ JSON.serialize(mapParams));
        Map<Object,Object> addMap = (Map<Object,Object>) mapParams.get('addData');
        if(addMap.containsKey('Id')){
            String addId = (String) addMap.get('Id');
            list<ContactPointAddress> cpaToUpdateList = [SELECT Id, Name, ActiveToDate, AddressType, Street, City, State, PostalCode, Country, StateCode, CountryCode,  IsDefault, ParentId FROM ContactPointAddress  where id =: addId LIMIT 1];
            String accId;
            for(ContactPointAddress cpa : cpaToUpdateList){
                cpa.IsDefault = true;
                accId = cpa.ParentId;
            }
            update cpaToUpdateList;
            list<ContactPointAddress> cpaToReturnList = [SELECT Id, Name, AddressType, Street, City, State, PostalCode, Country, StateCode, CountryCode,  IsDefault, AddressFirstName, AddressLastName, PhoneNumber, ParentId FROM ContactPointAddress  where ParentId =: accId];
            mapParams.put('cpaToReturnList', cpaToReturnList);
            isSuccess = true;
        }
        else{
            message = 'Error finding selected address details contact admin.';
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    public static Map<String, Object> getMegMenuConfiguration(Map<String, Object> mapParams) {
        Boolean isSuccess = false;
        String message = '';
        Map<String, String> resultMap = new Map<String, String>();
        
        mapParams.put(SIB_SetupConstants.CONFIGURATION_TYPE, CONFIG_TYPE);
        mapParams = SIB_ConfigurationService.getConfigurationJSON(mapParams);
        
        if (mapParams.containsKey(SIB_SetupConstants.CONFIG_JSON)) {
            SIB_MegaMenuConfiguration cartConfig = SIB_MegaMenuConfiguration.parse((String) mapParams.get(SIB_SetupConstants.CONFIG_JSON));
            
            Map<String, Object> configMap = (Map<String, Object>) JSON.deserializeUntyped((String) mapParams.get(SIB_SetupConstants.CONFIG_JSON));
            
            // Extract categories
            List<Object> categoryObjects = (List<Object>) configMap.get(SIB_SetupConstants.CATEGORY);
            for (Object categoryObject : categoryObjects) {
                Map<String, Object> category = (Map<String, Object>) categoryObject;
                String type = (String) category.get(SIB_SetupConstants.TYPE);
                String url = (String) category.get(SIB_SetupConstants.URL);
                
                // Map the category type to its URL
                resultMap.put(type, url);
                
                // Process subcategories and records
                List<Object> subCategoryObjects = (List<Object>) category.get(SIB_SetupConstants.SUB_CATEGORIES);
                for (Object subCategoryObject : subCategoryObjects) {
                    Map<String, Object> subCategory = (Map<String, Object>) subCategoryObject;
                    List<Object> recordObjects = (List<Object>) subCategory.get(SIB_SetupConstants.RECORDS);
                    for (Object recordObject : recordObjects) {
                        Map<String, Object> record = (Map<String, Object>) recordObject;
                        String label = (String) record.get(SIB_SetupConstants.LABEL);
                        String recordURL = (String) record.get(SIB_SetupConstants.URL);
                        
                        resultMap.put(label, recordURL);
                    }
                }
           }
            mapParams.put(SIB_SetupConstants.MEGA_MENU_CONFIG, cartConfig);
            mapParams.put(SIB_SetupConstants.RESULT_MAP, resultMap);
            
            isSuccess = true;
        } else {
            message = SIB_SetupConstants.HEADER_CONFIG_NOT_FOUND_MSG;
        }
        
        mapParams.put(SIB_SetupConstants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_SetupConstants.RESPONSE_MESSAGE, message);
        
        return mapParams;
    }
    
}