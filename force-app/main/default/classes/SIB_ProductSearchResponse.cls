/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 05-06-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_ProductSearchResponse extends SIB_BaseResponse  {
    
    @AuraEnabled
    public SearchCategory searchCategory{get;set;}

    @AuraEnabled
    public List<SearchFilter> filters{get;set;}

    @AuraEnabled
    public List<SortRule> sortRules{get;set;}

    @AuraEnabled
    public String locale{get;set;}

    @AuraEnabled
    public Integer pageSize{get;set;}

    @AuraEnabled
    public Integer total{get;set;}

    @AuraEnabled
    public List<SIB_ProductDetail> products{get;set;}


    public class SearchCategory{

        @AuraEnabled
        public Id id{get;set;}

        @AuraEnabled
        public String name{get;set;}

        @AuraEnabled
        public String urlSlug{get;set;}

        @AuraEnabled
        public String description{get;set;}

        @AuraEnabled
        public List<SearchCategory> children{get;set;}

        @AuraEnabled
        public Integer productCount{get;set;}
    }

    public class SearchFilter{

        @AuraEnabled
        public String nameOrId{get;set;}

        @AuraEnabled
        public String attributeType{get;set;}

        @AuraEnabled
        public String displayName{get;set;}

        @AuraEnabled
        public Integer displayRank{get;set;}

        @AuraEnabled
        public String displayType{get;set;}

        @AuraEnabled
        public String facetType{get;set;}

        @AuraEnabled
        public List<FilterValue> values{get;set;}
    }

    public class FilterValue{

        @AuraEnabled
        public String displayName{get;set;}

        @AuraEnabled
        public String nameOrId{get;set;}

        @AuraEnabled
        public Integer productCount{get;set;}

        @AuraEnabled
        public String type{get;set;}

        @AuraEnabled
        public Boolean checked{get;set;}

    }

    public class SortRule{

        @AuraEnabled
        public String displayName{get;set;}

        @AuraEnabled
        public String nameOrId{get;set;}

        @AuraEnabled
        public Integer sortOrder{get;set;}

        @AuraEnabled
        public String sortRuleId{get;set;}

    }


}