/**
 * @description         : Class used for Bundle Items LWC
 * @author              : Nathan Anderson
 * @last modified on    : 10-11-2023
 * @last modified by    : 
 */
public without sharing class Saltbox_BundleItems {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getBundleProducts(String communityId, String productId){
        
        String webStoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        //New list to received products details
        List<Product2> myProducts = new List<Product2>();
    
        // Need Sharing Setting for external user on this object
        List<Bundle_Item__c> myBundleItems = new List<Bundle_Item__c>();
        
        if(Schema.sObjectType.Bundle_Item__c.fields.Bundle_Item__c.isAccessible() 
            && Schema.sObjectType.Bundle_Item__c.fields.Bundle_Parent_Item__c.isAccessible()) {
                myBundleItems = [SELECT Bundle_Item__c FROM Bundle_Item__c WHERE Bundle_Parent_Item__c = :productId];
        }

        Set<Id> bundleItemIds = new Set<Id>();
        for (Bundle_Item__c myBundleItem : myBundleItems) {
            bundleItemIds.add(myBundleItem.Bundle_Item__c);
        }

       myProducts = [SELECT Id, Name, StockKeepingUnit, Description FROM Product2 WHERE Id IN :bundleItemIds];

        
        if(myProducts.size() > 0) {
            return myProducts;
        } else {
            return null;
        }
    }   
}