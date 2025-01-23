public without sharing class TTSEventRichTextController {
    @AuraEnabled
    public static String getTTSEventRichText(String recordId) {
        String richText = '';
        List<Campaign> ttsEvents = [SELECT Id, Image_URL__c FROM Campaign WHERE Id = :recordId];
        if (ttsEvents.size() > 0) {
            richText = ttsEvents[0].Image_URL__c;
        }
        return richText;
    }

    public static void doAfterInsert(List<ContentVersion> cvList) {
            Set<Id> ids = new Set<Id>();
            Set<Id> products = new Set<Id>();
            if(!cvList.IsEmpty()){
                List<ContentDistribution> cdListToInsert = new List<ContentDistribution>();
                List<Account> listToInsert = new List<Account>();
    
                for(ContentVersion cv : cvList){
                    cdListToInsert.add(new ContentDistribution(
                        ContentVersionId = cv.Id,
                        Name = cv.Title
                    ));
                    ids.add(cv.Id);
                    products.add(cv.FirstPublishLocationId);
                }
                if(!cdListToInsert.IsEmpty())INSERT cdListToInsert;
                ContentDistribution c = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN:ids LIMIT 1];
                List<Account> dataProduct = [SELECT Image_URL__c From Account WHERE Id IN:products];
                for(Account d: dataProduct ){
                    d.Image_URL__c = c.ContentDownloadUrl;
                    System.debug(d.Image_URL__c);
                    listToInsert.add(d);
                }
                if(!listToInsert.IsEmpty())update listToInsert;
            }
    }
    
}