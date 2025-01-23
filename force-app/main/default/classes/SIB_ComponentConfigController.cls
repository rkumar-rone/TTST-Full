global without sharing class SIB_ComponentConfigController {
    
    @AuraEnabled
    global static String getComponentConfig(String componentName,String permissionName){
        String communityId = getCurrentCommunitId(); 
        SIB_ComponentConfigResult response = new SIB_ComponentConfigResult(); 
        response.communityId = communityId;
        response.componentConfig = SIB_ComponentConfigHelper.getComponentConfigJson(componentName);
        boolean isComponentAdmin = false;
        if (String.isNotBlank(permissionName)) {
            isComponentAdmin = hasPermissionSet(permissionName);                                                                
        }       
        response.isComponentAdmin = isComponentAdmin;
        response.componentName = componentName;
        return JSON.serialize(response); 
    }
    
    @AuraEnabled
    global static void saveComponentConfigSettings(String componentConfigId,String componentName, String permissionName,String settings){
        SIB_ComponentConfigHelper.saveSettings(componentConfigId, componentName, permissionName, settings);
    }
    
    @AuraEnabled
    global static String getBaseUrl () {
        if (Network.getNetworkId() != null) {
            String baseUrl = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()].UrlPathPrefix;
            if(String.isNotBlank(baseUrl)){
                if(!baseUrl.startsWithIgnoreCase('/')){
                    baseUrl = '/'+baseUrl;
                }
                return baseUrl;
            }
        }
        return '';
    }
    @AuraEnabled
    public static boolean hasPermissionSet(String name) {
        return ([SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.label like :name AND assigneeId = :UserInfo.getUserId()]).size() > 0;
    }
    public static String getCurrentCommunitId() {
        Id networkId ;
        networkId = Network.getNetworkId();      
        String communityId = networkId;
        return communityId;
    }
    
}