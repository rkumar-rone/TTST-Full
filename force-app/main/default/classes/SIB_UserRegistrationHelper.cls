/**
 * @author Amit Prashar
 * @email aprashar@rafter.one
 * @create date 2024-03-28 17:24:39
 * @modify date 2024-03-28 17:24:39
 * @desc [description]
 */

public without sharing class SIB_UserRegistrationHelper {

    private static final String CLASSNAME = 'SIB_UserRegistrationHelper';
    private static final String MODULE_NAME = 'User Module';

    public static Boolean validateRequest(Map<String, Object> dataMap) {

        Boolean isValid = false;

        if (dataMap.containsKey(SIB_Constants.FIRSTNAME) && String.isNotBlank((String) dataMap.get(SIB_Constants.FIRSTNAME))
                && dataMap.containsKey(SIB_Constants.LASTNAME) && String.isNotBlank((String) dataMap.get(SIB_Constants.LASTNAME))
                && dataMap.containsKey(SIB_Constants.EMAIL) && String.isNotBlank((String) dataMap.get(SIB_Constants.EMAIL))
                && dataMap.containsKey(SIB_Constants.COMPANY) && String.isNotBlank((String) dataMap.get(SIB_Constants.COMPANY))
                && dataMap.containsKey(SIB_Constants.PHONE) && String.isNotBlank((String) dataMap.get(SIB_Constants.PHONE))
                != null){

            isValid = true;
        }

        return isValid;
    }

    public static User checkUserExists(Map<String, Object> dataMap) {
        User user = null;
        String email = (String) dataMap.get(SIB_Constants.EMAIL);
        //TODO Need to move or Query Selector
        List<User> uList = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND Email = :email LIMIT 1];
        if (!uList.isEmpty())
        {
            user = uList.get(0);
        }
        return user;
    }

    public static Account createAccount(Map<String, Object> dataMap) {
        
        Account acc = new Account();
        
        acc.Name = (String) dataMap.get(SIB_Constants.COMPANY);
        
        acc.Website = (String) dataMap.get(SIB_Constants.COMPANYWEB);
        
        acc.Phone = (String) dataMap.get(SIB_Constants.PHONE);
        
        acc.BillingCountryCode = (String) dataMap.get(SIB_Constants.COUNTRY_CODE);
        
        if (dataMap.containsKey(SIB_Constants.STATE_CODE) && String.isNotBlank((String) dataMap.get(SIB_Constants.STATE_CODE))){
            
            acc.BillingStateCode = (String) dataMap.get(SIB_Constants.STATE_CODE);
        
        }

        insert acc;

        return acc;
    }

    public static Contact createContact(Map<String, Object> dataMap) {
        
        Contact con = new Contact();
        //TODO Need to check null
        con.AccountId = (String) dataMap.get(SIB_Constants.ACCOUNT_ID);
        
        con.FirstName = (String) dataMap.get(SIB_Constants.FIRSTNAME);
        
        con.LastName = (String) dataMap.get(SIB_Constants.LASTNAME);
        
        con.Email = (String) dataMap.get(SIB_Constants.EMAIL);
        
        con.Phone = (String) dataMap.get(SIB_Constants.PHONE);
        
        con.MailingCountryCode = (String) dataMap.get(SIB_Constants.COUNTRY_CODE);
        
        if (dataMap.containsKey(SIB_Constants.STATE_CODE) && String.isNotBlank((String) dataMap.get(SIB_Constants.STATE_CODE))){

            con.MailingStateCode = (String) dataMap.get(SIB_Constants.STATE_CODE);
        }

        insert con;
        
        return con;
    }

    public static User createUser(Map<String, Object> dataMap) {
        
        String supportData = '';
        
        String methodName = 'createUser';
        
        String firstName = (String) dataMap.get(SIB_Constants.FIRSTNAME);
        
        String lastName = (String) dataMap.get(SIB_Constants.LASTNAME);
        
        String userAlias = firstName.substring(0, 1);
        
        if (lastName.length() > 6) {
            userAlias += lastName.substring(0, 6);
        } else {
            userAlias += lastName;
        }
        
        String communityNickname = firstName.trim() + ' ' + lastName.trim();
        
        Integer nicknameExistsCount = nickNameExistsCount(communityNickname);
        
        if (nicknameExistsCount > 0) {
            String newNickName = communityNickname + ' ' + (100 + (nicknameExistsCount + 1));
            communityNickname = newNickName;
        }
        
        User u = new User(
                Username = (String) dataMap.get(SIB_Constants.EMAIL),
                FirstName = (String) dataMap.get(SIB_Constants.FIRSTNAME),
                LastName = (String) dataMap.get(SIB_Constants.LASTNAME),
                Phone = (String) dataMap.get(SIB_Constants.PHONE),
                Alias = userAlias,
                Email = (String) dataMap.get(SIB_Constants.EMAIL),
                CommunityNickname = communityNickname,
                ContactId = (String) dataMap.get(SIB_Constants.CONTACT_ID),
                CompanyName = (String) dataMap.get(SIB_Constants.COMPANY),
                ProfileId = getProfileId(),
                TimeZoneSidKey = SIB_Util.getTimeZoneSidKey(),
                LocaleSidKey = SIB_Util.getLocaleSidKey(),
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = SIB_Util.getLanguageLocaleKey()
        );
        
        try {
            
            String userId = Site.createExternalUser(u, (String) dataMap.get(SIB_Constants.ACCOUNT_ID));
            
            u.Id = userId;
        } catch (Site.ExternalUserCreateException expObject) {
            
            List<String> errors = expObject.getDisplayMessages();
            
            for (String error : errors) {
                System.debug('error : ' + error);
            }
            
            System.debug(expObject.getMessage());
            
            //B2BExceptionLogs.storeExceptionLog(expObject, SIB_Constants.STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
            //throw new B2BExceptionLogs.B2BException(expObject.getMessage());
        }
        return u;
    }

    public static Id getProfileId() {
        String profileName = null;
        if(!Test.isRunningTest()){
             profileName = SIB_Util.getRegistrationProfileName();
        }else{
            profileName = 'B2B Customer Community Plus Login User' ;
        }
       
        //TODO Issue with this Query
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        return p.Id;
    }

    private static Integer nickNameExistsCount(String nickName) {
        String likeParam = nickName + '%';
        Integer count = [SELECT COUNT() FROM User WHERE CommunityNickname LIKE :likeParam LIMIT 20];
        return count;
    }

    public static void enableBuyerAccounts(Map<String, Object> dataMap) {
        //TODO need to check null
        String accId = (String) dataMap.get(SIB_Constants.ACCOUNT_ID);
        //TODO Need to move it to Query Selector
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id = :accId];
        if (!accList.isEmpty() && accList.size()>0)
        {
            Account acc = accList.get(0);
            //TODO Need to move it to Query Selector
            List<BuyerAccount> buyerAccList = [SELECT Id FROM BuyerAccount WHERE BuyerId = :accId];
            if (buyerAccList.isEmpty()) {
                BuyerAccount ba = new BuyerAccount();
                ba.BuyerId = acc.Id;
                ba.Name = acc.Name;
                ba.IsActive = true;
                insert ba;
            }
            //TODO Need to move it to Query Selector
            List<BuyerGroupMember> bgmList = [SELECT Id, Name FROM BuyerGroupMember WHERE BuyerId = :accId LIMIT 1];
            if (bgmList.isEmpty()) {
                BuyerGroupMember bgm = new BuyerGroupMember();
                bgm.BuyerId = acc.Id;
                bgm.BuyerGroupId = getRegistrationBuyerGroupId();
                insert bgm;
            }
        }
    }

    public static String getRegistrationBuyerGroupId() {
        String buyerGroupName = SIB_Util.getRegistrationBuyerGroupName();
        //TODO Need to move it to Query Selector
        List<BuyerGroup> buyerGroupList = [SELECT Id FROM BuyerGroup WHERE Name = :buyerGroupName LIMIT 1];
        if (!buyerGroupList.isEmpty()) {
            return buyerGroupList.get(0).Id;
        }
        return null;
    }

    @Future
    public static void assignPermissionSet(String userId) {
        List<PermissionSet> buyerPermissionSetList = getBuyerPermissionSet();
        if (!buyerPermissionSetList.isEmpty()) {
            Map<Id, PermissionSetAssignment> existingPermissionSet = new Map<Id, PermissionSetAssignment>([SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN :buyerPermissionSetList AND AssigneeId = :userId]);
            List<PermissionSetAssignment> psInsertList = new List<PermissionSetAssignment>();
            for (PermissionSet ps : buyerPermissionSetList) {
                if (!existingPermissionSet.containsKey(ps.Id)) {
                    psInsertList.add(new PermissionSetAssignment (PermissionSetId = ps.Id, AssigneeId = userId));
                }
            }
            if (!psInsertList.isEmpty() && !Test.isRunningTest())
            {
                insert psInsertList;
            }
        }
    }

    public static List<PermissionSet> getBuyerPermissionSet() {
        List<String> buyerPermissionSetList = SIB_Util.getBuyerPermissionSetName();
        //TODO Need to move it to Query Selector
        return [SELECT Id, Name FROM PermissionSet WHERE Name IN :buyerPermissionSetList];
    }
}