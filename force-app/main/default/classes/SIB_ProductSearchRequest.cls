/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 05-21-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_ProductSearchRequest extends SIB_BaseRequest  {

    @AuraEnabled
    public String categoryId{get;set;}

    @AuraEnabled
    public String catalogId{get;set;}

    @AuraEnabled
    public Boolean includePrices{get;set;}

    @AuraEnabled
    public Integer page{get;set;}

    @AuraEnabled
    public Integer pageSize{get;set;}

    @AuraEnabled
    public List<RefinementInput> refinements{get;set;}

    @AuraEnabled
    public String searchTerm{get;set;}

    @AuraEnabled
    public String sortRuleId{get;set;}

    public class RefinementInput {

        @AuraEnabled
        public String nameOrId{get;set;}

        @AuraEnabled
        public String attributeType{get;set;}

        @AuraEnabled
        public List<String> values{get;set;}

    }

}