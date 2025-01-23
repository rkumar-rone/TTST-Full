public with sharing class contactSupportController {

    @AuraEnabled
    public static void submitCase(Case newCase){
        try {
            insert newCase;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 
    @AuraEnabled
    public static void submitLead(Lead newLead){
        try {
            insert newLead;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static User getUserInfo(){
        User currentUser = [SELECT Id, FirstName, LastName, Email, Phone FROM User WHERE Id = :UserInfo.getUserId()];
        return currentUser;
    }
}