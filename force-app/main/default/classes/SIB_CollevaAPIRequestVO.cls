/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : Rajesh Kumar
**/
public with sharing class SIB_CollevaAPIRequestVO {
    public SIB_CollevaAPIRequestVO() {

    }
    @InvocableVariable
    public String email;	    //john.doe.0124.1@yopmail.com

    @InvocableVariable
    public String name;	        //John Doe

    @InvocableVariable
    public String productId;	//TTS_smartPrep

    @InvocableVariable
    public String startDate;	//2025-01-27

    @InvocableVariable
    public String actionName;	//createUSers

    @InvocableVariable
    public String userId;	//created User Id 

    @InvocableVariable
    public Boolean resetBillingPeriod;	//True/false

    @InvocableVariable
    public Integer productCount;	//2
    
    @InvocableVariable
    public Boolean inheritBillingPeriod;	//True/false

    @InvocableVariable
    public String orderSummaryId;	//True/false
}