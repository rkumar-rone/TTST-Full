/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : sthakur@rafter.one
**/
public with sharing class SIB_PDPConfiguration {

    @AuraEnabled
    public String id{get;set;}

    @AuraEnabled
    public String type{get;set;}

    @AuraEnabled
    public String cssTheme{get;set;}

    @AuraEnabled
    public String customPDP{get;set;}

    @AuraEnabled
    public List<ProductType> productTypeList{get;set;}

    public with sharing class ProductType{
        @AuraEnabled
        public String productType{get;set;}

        @AuraEnabled
        public String shortDescriptionField{get;set;}

        @AuraEnabled
        public TierConfiguration tierPricingConfig{get;set;}

        @AuraEnabled
        public Boolean displayPromotionalPrice{get;set;}

        @AuraEnabled
        public Boolean displayPageSections{get;set;}

        @AuraEnabled
        public String pageSectionStyle{get;set;}//accordion or tab

        @AuraEnabled
        public List<PageSection> pageSections{get;set;}

        @AuraEnabled
        public Boolean displayRelatedProduct{get;set;}

        @AuraEnabled
        public List<RelatedProductType> relatedProductTypes{get;set;}
    }

    public with sharing class PageSection{

        @AuraEnabled
        public String title{get;set;}

        @AuraEnabled
        public String apiName{get;set;}

        @AuraEnabled
        public String fieldAPIName{get;set;}

        @AuraEnabled
        public Boolean showOnlyWhenApplicable{get;set;}
    }

    public with sharing class RelatedProductType{

        @AuraEnabled
        public String displayName{get;set;}

        @AuraEnabled
        public String apiName{get;set;}

        @AuraEnabled
        public String language{get;set;}//future
    }

    public with sharing class TierConfiguration{
        @AuraEnabled
        public String displayType{get;set;}
    }


    public static SIB_PDPConfiguration parse(String json){
		return (SIB_PDPConfiguration) System.JSON.deserialize(json, SIB_PDPConfiguration.class);
	}
}