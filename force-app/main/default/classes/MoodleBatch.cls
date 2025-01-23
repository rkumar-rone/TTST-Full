public with sharing class MoodleBatch  implements  Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    public final Boolean full;
    
    public Set<Id> contactIds =  new Set<Id>();
    
    // To Run Full Moodle
    public MoodleBatch() {
        this.full = true;
    }
    
    // To Run Moodle based on the boolean as full/partial
    public MoodleBatch(Boolean full) {
        this.full = full;
    }
    
    //To run Moodle based on the Event Ids
    public MoodleBatch(Set<Id> eventIds) {
        for(CampaignMember cm:[SELECT Id,ContactId FROM CampaignMember WHERE CampaignId IN:eventIds]){
            contactIds.add(cm.ContactId);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(!contactIds.isEmpty()){
            return Database.getQueryLocator([SELECT Id, LMS_Id__c, (SELECT Id FROM CampaignMembers) from Contact where LMS_Id__c != null AND Id IN:contactIds]);
        }else{
            if(full) {
            String lastLoginDays = System.Label.Moodle_Last_Login_Days;
        String fullRunQuery = 'SELECT ID,LMS_Id__c, (SELECT Id FROM CampaignMembers WHERE Campaign.Date_RC_Access_Ends__c >=TODAY OR Campaign.Date_RC_Access_Ends__c=LAST_N_DAYS:2 OR Campaign.Date_RC_Access_Ends__c=null)';
        fullRunQuery = fullRunQuery + 'from Contact where LMS_Id__c != null AND Last_Login__c=LAST_N_DAYS:'+lastLoginDays;
        
                return Database.getQueryLocator(fullRunQuery);
                //return Database.getQueryLocator([SELECT Id, LMS_Id__c,(SELECT Id FROM CampaignMembers where Campaign.Date_RC_Access_Ends__c >=TODAY or Campaign.Date_RC_Access_Ends__c=LAST_N_DAYS:2) from Contact where LMS_Id__c != null AND Last_Login__c =Last_N_days:7]);
            }else {
                List<AuthSession> todaySessions = [SELECT Id, UsersId,Users.ContactId FROM AuthSession WHERE CreatedDate=TODAY AND
                                                   LoginType='Chatter Communities External User Third Party SSO' ];
                
                Set<Id> loggedInContactIds = new Set<Id>();
                for(AuthSession authSess:todaySessions){
                    loggedInContactIds.add(authSess.Users.ContactId);
                }
                return Database.getQueryLocator([SELECT Id, LMS_Id__c, (SELECT Id FROM CampaignMembers where Campaign.Date_RC_Access_Ends__c >=TODAY or Campaign.Date_RC_Access_Ends__c=LAST_N_DAYS:2) from Contact where LMS_Id__c != null AND Id IN :loggedInContactIds]);
            }
        }
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Contact> validConts = new List<Contact>();
        for(Contact cont:scope){
            if(cont.CampaignMembers.size()>0){
                validConts.add(cont);
            }
        }
        
        if(!validConts.isEmpty()){
            MoodleBatchHelper.GetUsers(validConts);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        Moodle_Configuration__mdt settings = [Select Id, Enable_Auto_Deactivation_of_Accounts__c from Moodle_Configuration__mdt where Active__c = true limit 1];
        if(settings.Enable_Auto_Deactivation_of_Accounts__c) {
            MoodleDeactivateBatch mdb = new MoodleDeactivateBatch();
            Database.executeBatch(mdb, 5);
        }
    }
         
     
     public void execute(SchedulableContext ctx){
        MoodleBatch mb = new MoodleBatch(full);
        Database.executeBatch(mb, 2);   
     }
       
}