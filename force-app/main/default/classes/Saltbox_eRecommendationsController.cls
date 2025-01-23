/**
 * @description: Class to get the recommendations for a webstore using Einstein
 * @author: Nicolas Gala
 * @last modified date: 12-06-2022
 * @last modified by: Nicolas Gala
 */
public without sharing class Saltbox_eRecommendationsController {

    /**
     * @description: This method sends a request to Einstein for the recommendations based on the parameters
     * @return: Einstein http response
     */
    @AuraEnabled
    public static String getERecommendations(String recommender, String anchorValues, String cookie) {
        try {
            String orgDomain = URL.getOrgDomainUrl().toExternalForm().replaceFirst('https://', '');
            String webstoreName = System.label.Saltbox_Webstore;
            String webstoreId = [SELECT id FROM Webstore WHERE name = :webstoreName WITH SECURITY_ENFORCED LIMIT 1].id;
            String endpoint = 'https://'+orgDomain+'/services/data/v55.0/commerce/webstores/'+webstoreId+'/ai/recommendations?language=en-US&asGuest=true&recommender='+recommender;
            if (anchorValues.length() > 0) {
                endpoint += '&anchorValues='+anchorValues;
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setHeader('Cookie', cookie);
            req.setMethod('GET');
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            return res.getBody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}