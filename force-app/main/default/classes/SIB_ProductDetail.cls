/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-25-2024
 * @last modified by  : Gaurang Arora
**/
public class SIB_ProductDetail extends SIB_BaseResponse {

    @AuraEnabled
    public Id productId{get;set;}

    @AuraEnabled
    public String name{get;set;}

    @AuraEnabled
    public Boolean isSubscription{get;set;}

    @AuraEnabled
    public String productSku{get;set;}

    @AuraEnabled
    public String productCode{get;set;}

    @AuraEnabled
    public Id variationParentId{get;set;}

    @AuraEnabled
    public String productClass{get;set;}

    @AuraEnabled
    public String productType{get;set;}

    @AuraEnabled
    public String productGroup{get;set;}

    @AuraEnabled
    public Boolean isCourse{get;set;}

    @AuraEnabled
    public Boolean isMostPopular{get;set;}

    @AuraEnabled
    public Boolean isNewCourse{get;set;}

    @AuraEnabled
    public SIB_ProductMedia defaultImage{get;set;}

    @AuraEnabled
    public List<SIB_ProductMedia> images{get;set;}

    @AuraEnabled
    public List<SIB_ProductMedia> attachments{get;set;}

    @AuraEnabled
    public List<SIB_ProductMedia> videos{get;set;}

    @AuraEnabled
    public Map<String, String> fieldsMap{get;set;}

    @AuraEnabled
    public SIB_ProductPricing price{get;set;}

    @AuraEnabled
    public QuantityRule quantityRule{get;set;}

    @AuraEnabled
    public Integer inventory{get;set;}

    @AuraEnabled
    public String description{get;set;}

    @AuraEnabled
    public String longDescription{get;set;}

    @AuraEnabled
    public List<String> bundleEventChildNames{get;set;}

    @AuraEnabled
    public List<SObject> eventSessions{get;set;}

    @AuraEnabled
    public Id campaignId{get;set;}

    //For bundle or self study courses
    @AuraEnabled
    public Integer productCount {get;set;}

    //For public courses
    @AuraEnabled
    public Integer totalDays {get;set;}

    @AuraEnabled
    public Boolean sessionFlag {get;set;}

    @AuraEnabled
    public String productCurrency {get;set;}

    @AuraEnabled
    public String productSlugURL {get;set;}

    @AuraEnabled
    public List<SIB_CategoryPath> categoryPath{get;set;}

    @AuraEnabled
    public SIB_VariationAttributeSetSummary variationAttributeSet{get;set;}

    @AuraEnabled
    public SIB_ProductAttributeSet productVariationAttributeSet{get;set;}

    @AuraEnabled
    public SIB_ProductVariationInfo variationInfo{get;set;}

    public class SIB_ProductMedia {

        @AuraEnabled
        public Id id{get;set;}

        @AuraEnabled
        public String title{get;set;}

        @AuraEnabled
        public String type{get;set;}

        @AuraEnabled
        public String altText{get;set;}

        @AuraEnabled
        public String url{get;set;}

        public SIB_ProductMedia(Id id, String title,String type, String altText,String url){
            this.id = id ;
            this.title = title ;
            this.type = type ;
            this.altText = altText ;
            this.url = url ;
        }
    }

    public class SIB_CategoryPath {

        @AuraEnabled
        public Id id{get;set;}

        @AuraEnabled
        public String name{get;set;}

        @AuraEnabled
        public String description{get;set;}

        @AuraEnabled
        public String url{get;set;}

        @AuraEnabled
        public Boolean isLast{get;set;}

        public SIB_CategoryPath(Id id, String name,String description,String urlSlug){
            this.id = id ;
            this.description = description ;
            this.name = name ;
            this.url = urlSlug ;
        }
    }

    public class QuantityRule{

        @AuraEnabled
        public Integer increment{get;set;}

        @AuraEnabled
        public Integer maximum{get;set;}

        @AuraEnabled
        public Integer minimum{get;set;}

        public QuantityRule(Integer increment,Integer maximum,Integer minimum){
            this.increment = increment;
            this.maximum = maximum;
            this.minimum = minimum;
        }
    }

    //variation
    public class SIB_ProductAttributeSet {

        @AuraEnabled
        public String developerName {get;set;}

        @AuraEnabled
        public Map<String, String> attributes{get;set;}

        @AuraEnabled
        public String id {get;set;}

        public SIB_ProductAttributeSet(String developerName, Map<String, String> attributes, String id){
            this.developerName = developerName;
            this.attributes = attributes;
            this.id = id;
        }
    }

    public class SIB_ProductVariationInfo {

        @AuraEnabled
        public List<SIB_ProductAttributesToProductEntry> attributesToProductMappings {get;set;}

        @AuraEnabled
        public Map<String, SIB_ProductAttributeInfo> variationAttributeInfo{get;set;}

        public SIB_ProductVariationInfo(List<SIB_ProductAttributesToProductEntry> attributesToProductMappings, Map<String, SIB_ProductAttributeInfo> variationAttributeInfo){
            this.attributesToProductMappings = attributesToProductMappings;
            this.variationAttributeInfo = variationAttributeInfo;
        }
    }

    public class SIB_ProductAttributeSetInfo {

        @AuraEnabled
        public Map<String, SIB_ProductAttributeInfo> variationAttributeInfo{get;set;}

        @AuraEnabled
        public String description{get;set;}

        @AuraEnabled
        public String developerName{get;set;}

        @AuraEnabled
        public String id{get;set;}

        @AuraEnabled
        public String masterLabel{get;set;}

        @AuraEnabled
        public String sequence{get;set;}
        

        public SIB_ProductAttributeSetInfo(Map<String, SIB_ProductAttributeInfo> variationAttributeInfo, String description, String developerName, String id, String masterLabel, String sequence){
            this.variationAttributeInfo = variationAttributeInfo;
            this.description = description;
            this.developerName = developerName;
            this.id = id;
            this.masterLabel = masterLabel;
            this.sequence = sequence;
        }
    }

    public class SIB_ProductAttributeInfo {

        @AuraEnabled
        public List<String> allowableValues {get;set;}

        @AuraEnabled
        public String apiName{get;set;}

        @AuraEnabled
        public List<String> availableValues {get;set;}

        @AuraEnabled
        public String fieldEnumOrId{get;set;}

        @AuraEnabled
        public String label{get;set;}

        @AuraEnabled
        public String objectName {get;set;}

        @AuraEnabled
        public Integer sequence {get;set;} //comes as Integer in connectApi

        public SIB_ProductAttributeInfo(List<String> allowableValues, String apiName, List<String> availableValues, String fieldEnumOrId, String label, String objectName, Integer sequence){
            this.allowableValues = allowableValues;
            this.apiName = apiName;
            this.availableValues = availableValues;
            this.fieldEnumOrId = fieldEnumOrId;
            this.label = label;
            this.objectName = objectName;
            this.sequence = sequence;
        }
    }

    public class SIB_ProductAttributesToProductEntry {

        @AuraEnabled
        public String canonicalKey {get;set;}

        @AuraEnabled
        public String productId {get;set;}

        @AuraEnabled
        public List<SIB_AttributesSummary> selectedAttributes {get;set;}

        @AuraEnabled
        public String urlName {get;set;}

        public SIB_ProductAttributesToProductEntry(String canonicalKey, String productId, List<SIB_AttributesSummary> selectedAttributes, String urlName){
            this.canonicalKey = canonicalKey;
            this.productId = productId;
            this.selectedAttributes = selectedAttributes;
            this.urlName = urlName;
        }
    }


    public class SIB_VariationAttributeSetSummary{

        @AuraEnabled
        public String apiName{get;set;}

        @AuraEnabled
        public List<SIB_AttributesSummary> attributes{get;set;}

        @AuraEnabled
        public String label{get;set;}

        public SIB_VariationAttributeSetSummary(String apiName,List<SIB_AttributesSummary> attributes,String label){
            this.apiName = apiName;
            this.attributes = attributes;
            this.label = label;
        }
    }

    public class SIB_AttributesSummary {

        @AuraEnabled
        public String apiName{get;set;}

        @AuraEnabled
        public String label{get;set;}

        @AuraEnabled
        public Integer sequence{get;set;}

        @AuraEnabled
        public String value{get;set;}

        public SIB_AttributesSummary(String apiName,String label,Integer sequence,String value){
            this.apiName = apiName;
            this.label = label;
            this.sequence = sequence;
            this.value = value;
        }
    }
}