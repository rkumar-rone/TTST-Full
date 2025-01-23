/**
 * @description: Utility Class to retrieve Managed Content from CMS for use in custom LWC components
 * @author: Nathan Anderson
 * @last modified date: 10-3-2021
 * @last modified by: Shane Smyth
 */
public with sharing class Saltbox_CMSConnector { 
    /**
     * @description: This method retrieves CMS content pieces by providing the content key via a selector in Experience Builder
     * @return: map of content details
     */
    @AuraEnabled(cacheable=true)
    public static String getManagedContentByContentKeys(String[] managedContentIds){
        Map<String, Object> returnMap = new Map<String, Object>{'success' => false};
        try {
            //Gather details about the community domain and path for use in constructing URL as well as passing into Connect API call
            String networkPathPrefix;
            String communityId;
            if(Test.isRunningTest()){
                String NETWORK_ID = System.Label.Saltbox_Network_ID;
                networkPathPrefix = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :NETWORK_ID LIMIT 1].UrlPathPrefix;
                communityId = NETWORK_ID;
            } else {
                networkPathPrefix = [SELECT Id, UrlPathPrefix FROM Network WHERE Id =: Network.getNetworkId() LIMIT 1].UrlPathPrefix;
                communityId = Network.getNetworkId();
            }
            
            System.debug('networkPathPrefix: ' + networkPathPrefix);
            Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = :networkPathPrefix LIMIT 1];
            String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
            System.debug('Community url: ' + communityUrl);
            //Make connectAPI call and pass into a return Map for parsing
            ConnectApi.ManagedContentVersionCollection imageContentList = ConnectApi.ManagedContent.getManagedContentByContentKeys(communityId, managedContentIds, 0, 25, 'en_US', 'cms_image', false);
            returnMap.put('imageContentList', (String)JSON.serialize(imageContentList));
            for(ConnectApi.ManagedContentVersion contentVersion : imageContentList.items) {
                Map<String, Object> contentVersionMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(contentVersion));
                Map<String, Object> contentVersionNodesMap = (Map<String, Object>)contentVersionMap.get('contentNodes');
                Map<String, Object> urlMap = (Map<String, Object>)contentVersionNodesMap.get('source');
                //Construct URL for the returned CMS image and add to return map
                returnMap.put('image', communityUrl + (String)urlMap.get('url'));
            }
            returnMap.put('success', true);
        }
        catch(ConnectApi.ConnectApiException e){
            System.debug('Error Message : ' + e);
            returnMap.put('ConnectApiException', e);
        }
        
        return JSON.serialize(returnMap); 
    }
}