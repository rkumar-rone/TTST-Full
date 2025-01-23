public virtual with sharing class SIB_BaseRequest {

    @AuraEnabled
    public Id accountId{get;set;}

    @AuraEnabled
    public Id webstoreId{get;set;}

    @AuraEnabled
    public Id communityId{get;set;}


}