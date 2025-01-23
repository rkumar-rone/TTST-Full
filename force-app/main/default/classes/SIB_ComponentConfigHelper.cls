public class SIB_ComponentConfigHelper {
    
    public static String getComponentConfigJson(String componentName) {
        List<SIB_Community_Component_Config__c >  componentConfig = [SELECT Id, Component_Name__c, Permission_Name__c, Settings__c 
                                                                     FROM SIB_Community_Component_Config__c  WHERE Component_Name__c =:componentName.trim()];                   
        String componentConfigJson = '';
        if (!componentConfig.isEmpty()) {
            String componentConfigId = componentConfig.get(0).Id; 
            String  customSettingsJson = componentConfig.get(0).Settings__c;
            componentConfigJson = '"ComponentConfigId": "' + componentConfigId + '", ';
            componentConfigJson += '"ComponentName" : "' + componentName + '", ';
            componentConfigJson += '"PermissionName" : "' + componentConfig.get(0).Permission_Name__c + '", ';
            componentConfigJson += '"Settings" : ' + customSettingsJson;
        }
        componentConfigJson = '{' + componentConfigJson + '}';
        System.debug('ComponentConfigHelper: getComponentConfigJson: componentConfigJson ' + componentConfigJson);
        return componentConfigJson;
    }
    
    public static void saveSettings(String componentConfigId, String componentName,String permissionName, String settings){
        if ((componentConfigId == null) || (componentConfigId.equals('')) || (componentConfigId.equals('null'))) {
            createComponentConfig(componentName, permissionName, settings);
        }    
        else {
            updateComponentConfig(componentConfigId, componentName, permissionName, settings);
        }
    }
    
    public static void createComponentConfig( String componentName,String permissionName, String settings){
        SIB_Community_Component_Config__c   componentConfig = new SIB_Community_Component_Config__c();
        componentConfig.permission_name__c = permissionName;
        componentConfig.Component_Name__c = componentName;
        componentConfig.Settings__c = settings;
        insert componentConfig;        
    }
    
    public static void updateComponentConfig(String componentConfigId, String componentName,String permissionName, String settings){
        SIB_Community_Component_Config__c componentConfig = [SELECT Id, Component_Name__c, Permission_Name__c, Settings__c 
                                                             FROM SIB_Community_Component_Config__c WHERE Id =:componentConfigId LIMIT 1];
        if (componentConfig != null) {
            componentConfig.Component_Name__c = componentName;
            componentConfig.Permission_Name__c = permissionName;
            componentConfig.Settings__c = settings;
            update componentConfig;                                         
        }else {
            createComponentConfig(componentName, permissionName, settings);
        }        
    }
}