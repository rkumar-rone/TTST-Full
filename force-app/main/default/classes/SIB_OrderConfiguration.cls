/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_OrderConfiguration {

    @AuraEnabled
    public String id{get;set;}

    @AuraEnabled
    public String cssTheme{get;set;}

    @AuraEnabled
    public String pageType{get;set;}

    @AuraEnabled
    public String objectApiName{get;set;}

    public static SIB_OrderConfiguration parse(String json){
		return (SIB_OrderConfiguration) System.JSON.deserialize(json, SIB_OrderConfiguration.class);
	}
}