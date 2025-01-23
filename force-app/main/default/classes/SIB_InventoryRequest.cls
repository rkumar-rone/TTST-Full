public with sharing class SIB_InventoryRequest extends SIB_BaseRequest  {
    
    @AuraEnabled
    public List<String> productIds{get;set;}
    

}