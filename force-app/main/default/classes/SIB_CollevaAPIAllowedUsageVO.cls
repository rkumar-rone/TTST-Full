/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : Colleva-class
 * @last modified on  : 01-28-2025
 * @last modified by  : Rajesh Kumar
**/
public with sharing class SIB_CollevaAPIAllowedUsageVO {
    
    @AuraEnabled
    public Integer sessionsLimit;
    
    @AuraEnabled
    public Integer minutesLeft;

    @AuraEnabled
    public Integer sessionsLeft;

    @AuraEnabled
    public Integer minutesLimit;

    @AuraEnabled
    public List<SIB_CollevaAPIActiveProductsVO> activeProducts;

    @AuraEnabled
    public Boolean hasUsageLeft;
    
    @AuraEnabled
    public String validUntil;

    @AuraEnabled
    public Boolean isUnlimited;
}