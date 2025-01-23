/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 07-12-2024
 * @last modified by  : Jassimran Virdi
**/
public with sharing class SIB_CartConfiguration {

    @AuraEnabled
    public String id{get;set;}

    @AuraEnabled
    public String type{get;set;}

    @AuraEnabled
    public String cssTheme{get;set;}

    @AuraEnabled
    public Boolean allowPromoCode{get;set;}

    @AuraEnabled
    public Boolean showUniqueCount{get;set;}

    @AuraEnabled
    public Integer pageSize{get;set;}

    @AuraEnabled
    public Boolean showRemoveItemOption{get;set;}

    @AuraEnabled
    public Boolean showMoreItemsOption{get;set;}

    @AuraEnabled
    public Boolean showLineItemTotal{get;set;}

    @AuraEnabled
    public Boolean showOriginalPrice{get;set;}

    @AuraEnabled
    public Boolean showSKU{get;set;}

    @AuraEnabled
    public Boolean showProductImage{get;set;}

    @AuraEnabled
    public Boolean showPricePerUnit{get;set;}

    @AuraEnabled
    public Boolean showActualPrice{get;set;}

    @AuraEnabled
    public Boolean hideQuantitySelector{get;set;}

    @AuraEnabled
    public Boolean showSavedAmount{get;set;}

    @AuraEnabled
    public List<ProductFields> productFields{get;set;} 

    public class ProductFields {
        @AuraEnabled
        public Boolean showLabel{get;set;}

        @AuraEnabled
        public String name{get;set;}

        @AuraEnabled
        public String label{get;set;}
	}

    public static SIB_CartConfiguration parse(String json){
        return (SIB_CartConfiguration) System.JSON.deserialize(json, SIB_CartConfiguration.class);
    }
}