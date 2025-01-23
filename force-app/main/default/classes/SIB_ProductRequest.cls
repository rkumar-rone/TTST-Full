/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_ProductRequest  extends SIB_BaseRequest  {

    @AuraEnabled
    public Id productId{get;set;}

    @AuraEnabled
    public List<Id> productIds{get;set;}

    @AuraEnabled
    public List<Id> relatedProductIds{get;set;}

    @AuraEnabled
    public Boolean showInventory{get;set;}
    
    @AuraEnabled
    public Boolean showPricing{get;set;}

    public SIB_ProductRequest(Id productId,Boolean showInventory,Boolean showPricing){
        this.productId = productId;
        this.showInventory = showInventory ;
        this.showPricing = showPricing ;
    }

    public SIB_ProductRequest(List<Id> productIds,Boolean showInventory,Boolean showPricing){
        this.productIds = productIds;
        this.showInventory = showInventory ;
        this.showPricing = showPricing ;
    }

}