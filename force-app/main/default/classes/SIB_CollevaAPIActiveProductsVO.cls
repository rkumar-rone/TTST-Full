/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : Colleva-class
 * @last modified on  : 01-28-2025
 * @last modified by  : Rajesh Kumar
**/
public with sharing class SIB_CollevaAPIActiveProductsVO {

    @AuraEnabled
    public String purchaseType;

    @AuraEnabled
    public String externalId;

    @AuraEnabled
    public String usageType;

    @AuraEnabled
    public String validUntil;

    @AuraEnabled
    public String productName;

}