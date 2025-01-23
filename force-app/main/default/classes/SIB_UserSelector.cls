/**
 * @description       : User specific selcetor method(s)
 * @author            : vramachandran@rafter.one
 * @group             : 
 * @last modified on  : 10-21-2024
 * @last modified by  : vramachandran@rafter.com
**/
public with sharing class SIB_UserSelector {
    

    public static String getContactIdForUserId(String userId) {

        String contactId = '';
        List<User> fetchedUserRecords = [SELECT Id, ContactId FROM User WHERE Id =: userId LIMIT 1];

        if(null != fetchedUserRecords && !fetchedUserRecords.isEmpty()) {

            contactId = fetchedUserRecords[0]?.ContactId;
        }

        return contactId;
    }

    public static User getUserInformationForUserId(String userId) {

        User fetchedUser = null;
        List<User> fetchedUsers = [SELECT Id, FederationIdentifier, Contact.Strivacity_Identifier__c 
                                    FROM User
                                    WHERE Id =: userId 
                                    LIMIT 1];
        if(null != fetchedUsers && !fetchedUsers.isEmpty()) {

            fetchedUser = fetchedUsers[0];
        }

        return fetchedUser;
    }
}