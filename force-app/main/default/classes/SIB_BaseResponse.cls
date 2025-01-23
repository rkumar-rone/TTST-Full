public virtual with sharing class SIB_BaseResponse {

    @AuraEnabled
    public Boolean isSuccess{get;set;}

    @AuraEnabled
    public String message{get;set;}

}