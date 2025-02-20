/**
 * Created by junaidmohammed on 1/28/25.
 */

public with sharing class SIB_CollevaAPIDataVO {

    @AuraEnabled
    public Integer id;	//686
    @AuraEnabled
    public String name;	//Gaurav Setia4
    @AuraEnabled
    public String updatedAt;	//1738108034337
    @AuraEnabled
    public String createdAt;	//1738108034337
    @AuraEnabled
    public String email;	//gauravsetia4@yopmail.com
    @AuraEnabled
    public SIB_CollevaAPIAllowedUsageVO allowedUsage;
    
    @AuraEnabled
    public Integer sessionsLimit;
    
    @AuraEnabled
    public Integer minutesLeft;

    @AuraEnabled
    public Integer sessionsLeft;

    @AuraEnabled
    public Integer minutesLimit;

    @AuraEnabled
    public Boolean hasUsageLeft;
    
    @AuraEnabled
    public String validUntil;

    @AuraEnabled
    public Boolean isUnlimited;

    @AuraEnabled
    public List<SIB_CollevaAPIActiveProductsVO> activeProducts;
    
}