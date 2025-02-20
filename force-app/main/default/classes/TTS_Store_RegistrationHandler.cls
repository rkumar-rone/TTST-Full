/**
    * @description : Implements the RegistrationHandler Interface for the Strivacity OpenID Connect Auth Provider
    * @created Date : 1st October 2023
    * @Author : Tom Fredrickson
    * @LastModified 22th February 2024
    * @decription Updated createUser side to handle finding existing Contacts that are related to Business Accounts and ensuring those relationships stay intact
*/

global class TTS_Store_RegistrationHandler implements Auth.RegistrationHandler{
    
    /*
       * @description : This method ensures the UserData was sent properly from the Provider
       * @params : Auth.UserData 
       * @created Date : 10-01-2023
       * @Return : return  boolean
   */
    global boolean canCreateUser(Auth.UserData data) {
        {
            System.debug('@@@@@@@@@@@@@@ data: ' + data);
            System.debug('@@@@@@@@@@@@@@ data.indentifiers: ' + data.attributeMap.get('identifiers'));
            String identifiersString = data.attributeMap.get('identifiers');
            String formattedString = identifiersString.replaceAll('(\\w+)[\\s]*[=:]', '"$1":');
            formattedString = formattedString.replaceAll(':[\\s]*([^"\',\\s]+)[\\s]*(?=[,\\}])', ':"$1"');
            System.debug('@@@@@@@@@@@@@ JSON' + formattedString);
            Map<String,String> idMap = (Map<String,String>) JSON.deserialize(formattedString, Map<String,String>.class);
            System.debug('@@@@@@@@@@@@@@ parsedEmail: ' + data.attributeMap.get('email'));
            System.debug('@@@@@@@@@@@@@@ username: ' + idMap.get('username'));
            System.debug('@@@@@@@@@@@@@@ phone: ' + data.attributeMap.get('phone_number'));
            System.debug('@@@@@@@@@@@@@@ source: ' + data.attributeMap.get('source'));
            System.debug('@@@@@@@@@@@@@@ country: ' + data.attributeMap.get('country'));
            if(data.attributeMap.get('email') !=null)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    /*
       * @description : This method is called if Salesforce does not recognize a user record based on the data from the Provider
       * @description : This method then checks for an existing user and returns it, or creates all the required data for a new user and returns that
       * @params : portalId (not required) and Auth.UserData from provider 
       * @created Date : 10-01-2023
       * @Return : return  User
   */
    global User createUser(Id portalId, Auth.UserData data){
        {
            if(canCreateUser(data))
            {
                System.debug('@@@@@@@@@@@@@@@ : IN CREATE');
                String identifiersString = data.attributeMap.get('identifiers');
                String formattedString = identifiersString.replaceAll('(\\w+)[\\s]*[=:]', '"$1":');
                formattedString = formattedString.replaceAll(':[\\s]*([^"\',\\s]+)[\\s]*(?=[,\\}])', ':"$1"');
                Map<String,String> idMap = (Map<String,String>) JSON.deserialize(formattedString, Map<String,String>.class);

                List<User> users = [select Id from User where FederationIdentifier=:data.identifier];
                if(users.size()==1)
                {
                    System.debug('#1##'+users[0]);
                    return users[0];
                }
                else
                {
                    //Setup the account
                    Id personId = handleAccountCreation(data, idMap);
                    Boolean collevaAccess = false;
                    SobjectType objType = personId.getSobjectType();
                    //Get fresh account record to retrieve the PersonContactId if the Id returned is an Accoung
                    if (String.valueOf(objType) == 'Account') {
                        Account newAcc = [SELECT Id, FirstName, LastName, PersonContactId,PersonContact.Colleva_Id__c FROM Account WHERE Id = :personId];
                        personId = newAcc.PersonContactId;
                        if(newAcc.PersonContact.Colleva_Id__c > 0){
                            collevaAccess = true;
                        }
                    }
                    
                    //Prep and assign the user information, including Profile and Permission Set assignments
                    //We'll set username up to be the TTS User Identifier from Strivacity + @tts.user since user won't be interacting with this value
                    //We'll also set that Identifier to the Federation Id for rechecking on login/registration in the future
                    User u = new User();
                    Profile p = [SELECT Id FROM profile WHERE name='B2B Customer Community Plus Login User'];
                    u.username = data.identifier + '@tts.user';
                    u.email = data.attributeMap.get('email');
                    u.lastName = data.lastName;
                    u.firstName = data.firstName;
                    u.phone = data.attributeMap.get('phone_number');
                    u.CompanyName = data.attributeMap.get('company');
                    String alias = data.firstName.substring(0,1)+data.lastName.substring(0,2)+data.identifier.substring(0,4);
                    if(alias.length() > 8)
                    {
                        alias = alias.substring(0, 8);
                    }
                    u.alias = alias;
                    u.languagelocalekey = 'en_US';
                    u.localesidkey = 'en_US';
                    u.emailEncodingKey = 'UTF-8';
                    u.timeZoneSidKey = 'America/Los_Angeles';
                    u.profileId = p.Id;
                    u.FederationIdentifier = data.identifier;
                    u.contactId = personId;
                    if(collevaAccess)
                    {
                        u.CollevaAccess__c = true;
                    }
                    //insert u;
                    //Add Permission Set Assignments
                    if (!Test.isRunningTest()) {
                        handlePermissions(u.username);
                        
                    }
                    return u;
                }
            }
            else
            {
                return null;
            }
        }
    }

    /*
       * @description : This method is called when Salesforce does recognize an existing user, and runs any required updates based on the Provider data
       * @params : userId (found user), portalId (not required), Auth.UserData (from Provider)
       * @created Date : 10-01-2023
       * @Return : return  void
   */
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        
        System.debug('@@@@@@@@@@@@@@@@: IN UPDATE');
        String identifiersString = data.attributeMap.get('identifiers');
        String formattedString = identifiersString.replaceAll('(\\w+)[\\s]*[=:]', '"$1":');
        formattedString = formattedString.replaceAll(':[\\s]*([^"\',\\s]+)[\\s]*(?=[,\\}])', ':"$1"');
        Map<String,String> idMap = (Map<String,String>) JSON.deserialize(formattedString, Map<String,String>.class);
        String phone = data.attributeMap.get('phone_number');
        String company = data.attributeMap.get('company');
        String source = data.attributeMap.get('source');
        String country = data.attributeMap.get('country');
        String firstName = data.firstName;
        String lastName = data.lastName;
        String email = data.attributeMap.get('email');

        User u = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        String aId = u.AccountId;
       
        u.email = email;
        u.lastName = lastName;
        u.firstName = firstName;
        u.phone = phone;
        u.CompanyName = company;
        
        update u;

        if (!Test.isRunningTest()) {
            updateAccountInfo(aId, email, phone, firstName, lastName, company, source, country, idMap);
        }
    }

    /*
       * @description : This method is used to find an existing person account or create a new account, including calling Buyer info methods
       * @params : Auth.UserData (from Provider), idMap (parsed sub-map passed from createUser method)
       * @created Date : 10-01-2023
       * @Return : return Id 
   */
    global Id handleAccountCreation(Auth.UserData data, Map<String,String> idMap) {
        //Get the correct Account record type
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        //Find an existing Person Account record by matching Strivacity Username
        //TODO -- find and handle matching CONTACT and convert to PA
        List<Account> existingPA = [SELECT Id, Name, Strivacity_Username__pc, PersonEmail, FirstName, LastName FROM Account WHERE RecordTypeId = :recordTypeId AND Strivacity_Username__pc = :idMap.get('username')];
        
        //If Person Account is found, check to see if fully setup as a buyer, if not call method to setup BuyerAccount and return Account record
        if(existingPA.size() > 0) {
            BuyerAccount existingBA = [Select Id FROM BuyerAccount WHERE BuyerId = :existingPA[0].Id];
            if (existingBA == null) {
               handleBuyerSetup(existingPA[0]);
            }
            return existingPA[0].Id;

        //Check next for an existing Contact record matching by email address
        } else {
            Boolean hasNewPA = false;
            Account convertedPA;
            Account existingAcc;
            List<Contact> existingContact = [SELECT Id, Email, Account.RecordTypeId, AccountId, Account.Name FROM Contact WHERE Email = :data.attributeMap.get('email')];
            if(existingContact.size() > 0) {

                //Save original parent Account id
                String ogAccount = existingContact[0].AccountId;
                System.debug('ogAccount: ' + ogAccount);

                //Create new Account record
                convertedPA = new Account();
                convertedPA.Name = data.firstName + ' ' + data.lastName;
                insert convertedPA;
                hasNewPA = true;

                //Update existing Contact record with new AccountId and populate other fields
                existingContact[0].AccountId = convertedPA.Id;
                existingContact[0].FirstName = data.firstName;
                existingContact[0].LastName = data.lastName;
                existingContact[0].Email = data.attributeMap.get('email');
                existingContact[0].User_Id__c = data.identifier + '@tts.user';
                existingContact[0].Strivacity_Username__c = idMap.get('username');
                existingContact[0].Strivacity_Identifier__c = data.identifier;
                existingContact[0].MobilePhone = data.attributeMap.get('phone_number');
                existingContact[0].Company__c = data.attributeMap.get('company');
                existingContact[0].How_did_you_hear_about_us__c = data.attributeMap.get('source');
                existingContact[0].Country_of_Residence__c = data.attributeMap.get('country');
                existingContact[0].OwnerId = UserInfo.getUserId();
                update existingContact[0];

                //Update created Account record to have Person recordType
                Account accToUpdate = [SELECT Id, FirstName, LastName, Original_Parent_Account__c FROM Account WHERE Id = :convertedPA.Id LIMIT 1];
                accToUpdate.RecordTypeId = recordTypeId;
                update accToUpdate;

                //Update created Account record to populate Original_Parent_Account__c with original parent Account
                Account accToUpdate2 = [SELECT Id, Original_Parent_Account__c FROM Account WHERE Id = :convertedPA.Id LIMIT 1];
                accToUpdate2.Original_Parent_Account__c = ogAccount;
                update accToUpdate2;

                //Requery created Account record
                Account completedPA = [SELECT Id, FirstName, LastName FROM Account WHERE Id = :convertedPA.Id LIMIT 1];

                //Handle Buyer setup
                handleBuyerSetup(completedPA); //Create Buyer Account, Get Buyer Group, Create Buyer Group Member

                return existingContact[0].Id;
            
            //Handle creation of new Person Account if not found   
            } else {
                try {
                    List<Group_Recepient__c> grpRecep = [select id, Name, Colleva_Id__c, Recepient_Email__c from Group_Recepient__c where Recepient_Email__c =: data.attributeMap.get('email') AND Colleva_Id__c != null limit 1];
                    Account newPA = new Account();
                    newPA.RecordTypeId = recordTypeId;
                    newPA.FirstName = data.firstName;
                    newPA.LastName = data.lastName;
                    newPA.PersonEmail = data.attributeMap.get('email');
                    newPA.User_Id__pc = data.identifier + '@tts.user';
                    newPA.Strivacity_Username__pc = idMap.get('username');
                    newPA.Strivacity_Identifier__pc = data.identifier;
                    newPA.PersonMobilePhone = data.attributeMap.get('phone_number');
                    newPA.Company__pc = data.attributeMap.get('company');
                    newPA.How_did_you_hear_about_us__pc = data.attributeMap.get('source');
                    newPA.Country_of_Residence__pc = data.attributeMap.get('country');
                    if(grpRecep != null && !grpRecep.isEmpty()) {
                        newPA.Colleva_Id__pc = grpRecep[0].Colleva_Id__c;
                    }
                    insert newPA;
    
                    if(newPA.Id != null) {
                        handleBuyerSetup(newPA);
                    }  
                    if(newPA.Id != null && grpRecep != null && !grpRecep.isEmpty() && String.isNotBlank(grpRecep[0].Recepient_Email__c) ) {
                        //update contact on  Colleva Detail
                        updateContactOnColleva(newPA.Id , grpRecep[0].Recepient_Email__c);
                    }
                    return newPA.Id;
                } catch (Exception e) {
                    System.debug('@@@@@@@@@@@@ Failure in HandleAccountCreation: ' + e.getMessage());
                    return null;
                }   
            }
        }
    }

    /*
       * @description : This method is used to setup Buyer Account and Buyer Group Account records for Store Access
       * @params : Account record
       * @created Date : 10-01-2023
       * @Return : return  boolean
   */    
    global boolean handleBuyerSetup(Account a) {
        //Prep and assign the Buyer Group Information
        //TODO -- Address?
        try {
            //Create Buyer Account
            BuyerAccount ba = new BuyerAccount();
            ba.BuyerId = a.Id;
            ba.BuyerStatus = 'Active';
            ba.CommerceType = 'Buyer';
            ba.CreditStatus = 'Good Credit';
            ba.isActive = true;
            ba.Name = a.FirstName + ' ' + a.LastName;
            insert ba;

            //Get Buyer Group
            BuyerGroup bg = [SELECT Id FROM BuyerGroup WHERE Name = 'TTS B2B Store Buyer Group' LIMIT 1];
            
            //Create Buyer Group Member
            BuyerGroupMember bgm = new BuyerGroupMember();
            bgm.BuyerGroupId = bg.Id;
            bgm.BuyerId = ba.BuyerId;
            insert bgm; 

            return true;
        } catch (Exception e) {
            System.debug('@@@@@@@@@ Exception in handleBuyerSetup: ' + e.getMessage());
            return null;
        }
    }
    /*
       * @description : Future method to setup PermissionAssignments for the user
       * @params : String (username)
       * @created Date : 10-01-2023
       * @Return : return  void
   */    
    @future
    global static void handlePermissions(String username) {
        User u = [SELECT Id FROM User WHERE Username = :username];
        PermissionSetGroup psg = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'TTS_Store_Users'];

        PermissionSetAssignment psa = new PermissionSetAssignment();
        if(u != null) {
            psa.PermissionSetGroupId = psg.Id;
            psa.AssigneeId = u.Id;
            insert psa;
        } 
    }

    /*
       * @description : Future method to Account object updates for the user
       * @params : String (username)
       * @created Date : 10-23-2023
       * @Return : return  void
    */   
    @future
    global static void updateAccountInfo(String aId, String email, String phone, String firstName, String lastName, String company, String source, String country, Map<String,String> idMap) {
        Account a = [Select Id, isPersonAccount FROM Account WHERE Id = :aId];
        
        if(a.isPersonAccount == true) {
            a.PersonEmail = email;
            a.LastName = lastName;
            a.FirstName = firstName;
            a.Strivacity_Username__pc = idMap.get('username');
            a.PersonMobilePhone = phone;
            a.Company__pc = company;
            a.How_did_you_hear_about_us__pc = source;
            a.Country_of_Residence__pc = country;

            update a;
        }
        
    }

    @future
    global static void contactToPAConversion (String serializedListContact, String serializedSavedUsers, String serializedUserContactMap, String serializedUserDataMap){
        List<Contact> contactsToConvert = (List<Contact>) JSON.deserialize(serializedListContact, List<Contact>.class);
        List<User> savedUsers = (List<User>) JSON.deserialize(serializedSavedUsers, List<User>.class);
        Map<String, String> almostUserContactMap = (Map<String, String>) JSON.deserialize(serializedUserContactMap, Map<String, String>.class);
        Map<User, String> userContactMap = new Map<User, String>();
        for (String cid : almostUserContactMap.keySet()){
            userContactMap.put((User) JSON.deserialize(almostUserContactMap.get(cid), User.class), cid);
        }

        Map<String, String> userDataMap = (Map<String, String>) JSON.deserialize(serializedUserDataMap, Map<String, String>.class);

        //Get Person Account Record Type Id
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account convertedPA;
        String ogAccount;

        //Get Buyer Group
        BuyerGroup bg = [SELECT Id FROM BuyerGroup WHERE Name = 'TTS B2B Store Buyer Group' LIMIT 1];

        System.debug('Entering contactsToConvert process...');
        //Loop through Contacts to convert to create new Account records
        Map<String, Account> contactAccountMap = new Map<String, Account>();
        for (Contact contact : contactsToConvert) {
            Account account = new Account();
            account.Name = contact.LastName + ', ' + contact.FirstName;
            account.OwnerId = contact.OwnerId;
            account.CurrencyIsoCode = contact.CurrencyIsoCode;
            account.ParentId = null;
            account.Original_Parent_Account__c = contact.AccountId;
    
            contactAccountMap.put(contact.Id, account);
        }
    
        //Insert new Account records
        if (!contactAccountMap.isEmpty()) {
            insert contactAccountMap.values();
        }
    
        //Loop through Contacts to update AccountId and ReportsTo
        Map<Id, Contact> existingContactMap = new Map<Id, Contact>();
        for (Contact contact : contactsToConvert) {
            contact.AccountId = contactAccountMap.get(contact.Id).Id;
            contact.ReportsTo = null;
            existingContactMap.put(contact.Id, contact);
        }
    
        //Update Contacts
        if (!existingContactMap.isEmpty() && !Test.isRunningTest()) {
            update existingContactMap.values();
        }
    
        //Update Account Record Type to Person Account Record Type
        List<Account> personAccounts = new List<Account>();
        for (Account account : contactAccountMap.values()) {
            personAccounts.add(new Account(
                    Id = account.Id,
                    RecordTypeId = recordTypeId));
        }
        if (!Test.isRunningTest()) {
            update personAccounts;
        }

        //Handle Buyer Account and Buyer Group Member creation
        for (Account account : contactAccountMap.values()) {
            //Create Buyer Account
            BuyerAccount ba = new BuyerAccount();
            ba.BuyerId = account.Id;
            ba.BuyerStatus = 'Active';
            ba.CommerceType = 'Buyer';
            ba.CreditStatus = 'Good Credit';
            ba.isActive = true;
            ba.Name = account.Name;
            insert ba;
            
            //Create Buyer Group Member
            BuyerGroupMember bgm = new BuyerGroupMember();
            bgm.BuyerGroupId = bg.Id;
            bgm.BuyerId = ba.BuyerId;
            insert bgm; 
        }

        User u;
        List<User> usersToInsert = new List<User>();
        for (User dUser : savedUsers){
            u = new User();
            u.username = userDataMap.get(dUser.Id+'+Username');
            u.email = userDataMap.get(dUser.Id+'+Email');
            u.lastName = dUser.lastName;
            u.firstName = dUser.firstName;
            u.phone = dUser.phone;
            u.CompanyName = dUser.CompanyName;
            u.alias = dUser.Alias;
            u.languagelocalekey = dUser.languagelocalekey;
            u.localesidkey = dUser.localesidkey;
            u.emailEncodingKey = dUser.emailEncodingKey;
            u.timeZoneSidKey = dUser.timeZoneSidKey;
            u.profileId = dUser.profileId;
            u.FederationIdentifier = userDataMap.get(dUser.Id+'+FederationIdentifier');
            u.contactId = userContactMap.get(dUser);

            usersToInsert.add(u);
        }

        if (!Test.isRunningTest()) {
            insert usersToInsert;
        }

    }

    
    global static void updateContactOnColleva(String accountId, String email) {
        List<SIB_Colleva_Details__c> collevaDetailList = [select id,name,Contact__c,Colleva_Id__c from SIB_Colleva_Details__c where Email__c  =: email];
        System.debug('collevaDetailList : '+collevaDetailList);
        System.debug('collevaDetailList : accountId '+accountId);
        System.debug('collevaDetailList : email '+email);
        if(collevaDetailList != null && !collevaDetailList.isEmpty() && String.isNotBlank(accountId))
        {
            List<Account> newAccList = [SELECT Id, FirstName, LastName, PersonContactId,PersonContact.Colleva_Id__c FROM Account WHERE Id = :accountId];
            if(newAccList!= null && !newAccList.isEmpty() && String.isNotBlank(newAccList[0].PersonContactId) )
            collevaDetailList[0].Contact__c = newAccList[0].PersonContactId;
            update collevaDetailList;
        }

    }

}