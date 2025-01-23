/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 04-02-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_SignUpConfiguration {

    @AuraEnabled
    public String id{get;set;}

    @AuraEnabled
    public String cssTheme{get;set;}

    @AuraEnabled
    public Boolean showPasswordFields {get;set;}

    public static SIB_SignUpConfiguration parse(String json){
        return (SIB_SignUpConfiguration) System.JSON.deserialize(json, SIB_SignUpConfiguration.class);
    }
}