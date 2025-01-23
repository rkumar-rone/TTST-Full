/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : Gaurang Arora
**/
public with sharing class SIB_PLPConfiguration {
    
    @AuraEnabled
    public String id{get;set;}

    @AuraEnabled
    public String type{get;set;}

    @AuraEnabled
    public String cssTheme{get;set;}

    @AuraEnabled
    public Boolean showProductImage{get;set;}

    @AuraEnabled
    public Boolean showOriginalPrice{get;set;}

    @AuraEnabled
    public Boolean showNegotiatedPrice{get;set;}

    @AuraEnabled
    public Boolean showLayoutButtons{get;set;}

    @AuraEnabled
    public Boolean showCallToActionButton{get;set;}

    @AuraEnabled
    public Boolean showQuantitySelector{get;set;}

    @AuraEnabled
    public String viewOptionsButtonText{get;set;} //View Options

    @AuraEnabled
    public String addToCartButtonText{get;set;}

    @AuraEnabled
    public String addToCartButtonStyle{get;set;}

    @AuraEnabled
    public String addToCartButtonProcessingText{get;set;}

    @AuraEnabled
    public String minimumQuantityGuideText{get;set;}

    @AuraEnabled
    public String maximumQuantityGuideText{get;set;}

    @AuraEnabled
    public String incrementQuantityGuideText{get;set;}

    @AuraEnabled
    public String quantitySelectorLabelText{get;set;}

    @AuraEnabled
    public String showQuantityRulesText{get;set;}

    @AuraEnabled
    public String unavailablePriceText{get;set;}

    @AuraEnabled
    public String defaultView{get;set;} //Grid

    @AuraEnabled
    public Integer gridMaxColumnsDisplayed{get;set;} //3

    @AuraEnabled
    public Integer searchResultsPageSize{get;set;}

    @AuraEnabled
    public Integer selfStudyPageSize{get;set;}

    @AuraEnabled
    public Integer pageSize{get;set;} //21

    @AuraEnabled
    public List<CardContentMapping> cardContentMapping{get;set;}

    @AuraEnabled
    public List<String> availableLayouts{get;set;}

    @AuraEnabled
    public List<String> searchResultsFields{get;set;}

	public class CardContentMapping {
        @AuraEnabled
        public Boolean showLabel{get;set;}

        @AuraEnabled
        public String name{get;set;}

        @AuraEnabled
        public String label{get;set;}
	}

    public static SIB_PLPConfiguration parse(String json){
        return (SIB_PLPConfiguration) System.JSON.deserialize(json, SIB_PLPConfiguration.class);
    }

   
}