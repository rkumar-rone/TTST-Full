/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 07-18-2024
 * @last modified by  : Jassimran Virdi
**/
public without sharing class SIB_ConfiguratorController {
    @AuraEnabled
    public static void saveConfiguratorColorSettings(String settings){
        try{
            List<SIB_Configurator_Config__c> colorConfiguration = [SELECT Id,Color_Config__c FROM SIB_Configurator_Config__c];
            if(colorConfiguration != null && colorConfiguration.size() > 0) {
                colorConfiguration[0].Color_Config__c  = settings;
                update colorConfiguration[0];  
            }
        }
        catch(Exception ex){
            
        }
    }
    @AuraEnabled
    public static void saveConfiguratorTypographySettings(String settings){
        try{
            List<SIB_Configurator_Config__c> configuratorRecord = [SELECT Id,Font_Config__c FROM SIB_Configurator_Config__c];
            if(configuratorRecord != null && configuratorRecord.size() > 0) {
                configuratorRecord[0].Font_Config__c  = settings;
                update configuratorRecord[0];  
            }
        }
        catch(Exception ex){
            
        }
    }

    @AuraEnabled
    public static void saveConfiguratorTemplateSettings(String selectedTemplate){
        try{
            // SIB_Configurator_Config__c componentConfig = new SIB_Configurator_Config__c();

            List<SIB_Configurator_Config__c> componentConfig = [SELECT Id, Template__c FROM SIB_Configurator_Config__c LIMIT 1];
            if( !componentConfig.isEmpty() ){
                // componentConfig.Id = 'a1ZDM0000032pSh2AI';
                componentConfig[0].Template__c = selectedTemplate;
                update componentConfig;  
            }
        }
        catch(Exception ex){ 
        }
    }

    @AuraEnabled
    public static String getConfiguratorColorSettings(){
        String colorConfig = '';
        try{
            List<SIB_Configurator_Config__c> colorConfiguration = [SELECT Id,Color_Config__c FROM SIB_Configurator_Config__c LIMIT 1];
            if(colorConfiguration[0].Color_Config__c != null){
                colorConfig =  colorConfiguration[0].Color_Config__c;
            }
        }
        catch(Exception ex){  
        }
        return colorConfig;
    }
    @AuraEnabled
    public static String getConfiguratorTypographySettings(){
        String fontConfig = '';
        try{
            List<SIB_Configurator_Config__c> colorConfiguration = [SELECT Id,Font_Config__c FROM SIB_Configurator_Config__c LIMIT 1];
            if(colorConfiguration[0].Font_Config__c != null){
                fontConfig =  colorConfiguration[0].Font_Config__c;
            }
        }
        catch(Exception ex){  
        }
        return fontConfig;
    }

    @AuraEnabled(Cacheable=true)
    public static String getConfiguratorTemplateSettings(){
        String selectedTemplate = '';
        try{
            List<SIB_Configurator_Config__c> colorConfiguration = [SELECT Id,Template__c  FROM SIB_Configurator_Config__c LIMIT 1];
            if(colorConfiguration[0].Template__c  != null){
                selectedTemplate =  colorConfiguration[0].Template__c ;
            }
        }
        catch(Exception ex){  
        }
        return selectedTemplate;
    }
    @AuraEnabled
    public static SIB_Configurator_Config__c getConfiguratorSettings(){
        try{
            return [SELECT Id,Color_Config__c,Font_Config__c FROM SIB_Configurator_Config__c LIMIT 1];
        }
        catch(Exception ex){  
        }
        return null;
    }
    @AuraEnabled
    public static SIB_StorefrontConfiguration__c getStorefrontConfigurationSettings(){
        try{
            String configTypePLP = 'PLP';
            Boolean statusActive = true;
            
            return [SELECT Id,ConfigJSON__c FROM SIB_StorefrontConfiguration__c where ConfigurationType__c=:configTypePLP and Active__c=:statusActive LIMIT 1];
        }
        catch(Exception ex){  
        }
        return null;
    }
}