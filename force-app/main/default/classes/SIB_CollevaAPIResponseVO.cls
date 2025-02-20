/**
 * @description       : 
 * @author            : Rajesh Kumar
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : Rajesh Kumar
**/
public with sharing class SIB_CollevaAPIResponseVO {

    public SIB_CollevaAPIResponseVO(){}
    
    @InvocableVariable
    public List<String> errors;

    @InvocableVariable
    public SIB_CollevaAPIDataVO data;

    @InvocableVariable
    public Integer code;

}