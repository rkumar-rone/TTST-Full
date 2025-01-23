/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Gaurav Setia
**/
public without sharing class SIB_UserRegistrationService {

    private static final String CLASSNAME = 'SIB_UserRegistrationService';
    private static final String CONFIG_TYPE = 'SIGNUP';

    public static Map<String,Object> getRegistrationConfiguration(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        mapParams.put(SIB_SetupConstants.CONFIGURATION_TYPE,CONFIG_TYPE );
        mapParams = SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams.containsKey(SIB_SetupConstants.CONFIG_JSON)){
            SIB_SignUpConfiguration signUpConfig = SIB_SignUpConfiguration.parse((String)mapParams.get(SIB_SetupConstants.CONFIG_JSON));
            mapParams.put(SIB_SetupConstants.SIGNUP_CONFIG, signUpConfig);
            isSuccess = true;
        }else{
            message = SIB_SetupConstants.SIGNUP_CONFIG_NOT_FOUND;
        }
        mapParams.put(SIB_Constants.IS_SUCCESS, isSuccess);
        mapParams.put(SIB_Constants.PARAM_MESSAGE, message);
        return mapParams;
    }
    
    //TODO USE CONSTANT FOR HARDCODED VALUES
    public static Map<String, Object> registerUser(Map<String, Object> dataMap) {
        
        Boolean isSuccess = false;
        Boolean isUserExist = false;
        String msg = '';
        
        User existingUser = SIB_UserRegistrationHelper.checkUserExists(dataMap);
        if (existingUser == null) {
            Account acc = SIB_UserRegistrationHelper.createAccount(dataMap);
            dataMap.put(SIB_Constants.ACCOUNT_ID, acc.Id);
            Contact con = SIB_UserRegistrationHelper.createContact(dataMap);
            dataMap.put(SIB_Constants.CONTACT_ID, con.Id);
            User u = SIB_UserRegistrationHelper.createUser(dataMap);
            if (u != null) {
                if(dataMap.get(SIB_Constants.PASSWORD) != null && dataMap.get(SIB_Constants.CONFIRM_PASSWORD) != null) {
                  
                    String password = (String)dataMap.get(SIB_Constants.PASSWORD);
                    if(!Test.isRunningTest()){
                        System.setPassword(u.Id, password);
                    }

                    ApexPages.PageReference pageRef = Site.login(
                        (String)dataMap.get(SIB_Constants.EMAIL), password, '');
                    if(pageRef != null) {
                        dataMap.put(SIB_Constants.LOGIN_URL, pageRef.getUrl());
                    }
                }
                SIB_UserRegistrationHelper.enableBuyerAccounts(dataMap);
                SIB_UserRegistrationHelper.assignPermissionSet(u.Id);
                isSuccess = true;
                msg = 'User created successfully';
            } else {
                isSuccess = false;
                msg = 'User creation failed, please try again';
            }
        } else {
            isSuccess = false;
            isUserExist = true;   
            msg = 'This email already exists.  Please use the forgot password link or contact support.' ;
        }
        dataMap.put(SIB_Constants.IS_USER_EXIST, isUserExist);
        dataMap.put(SIB_Constants.IS_SUCCESS, isSuccess); 
        dataMap.put(SIB_Constants.MESSAGE, msg);
        return dataMap;
    }

    public static Map<String, Object> getLoginURL(Map<String, Object> dataMap) {
        
        PageReference redirectPage = Site.login((String) dataMap.get(SIB_Constants.EMAIL), (String) dataMap.get(SIB_Constants.PASSWORD), (String) dataMap.get(SIB_Constants.COMMUNITY_PATH));
        String loginURL = '';
        if(!Test.isRunningTest()){
            loginURL = redirectPage.getUrl();
        }
        dataMap.put(SIB_Constants.LOGIN_URL, loginURL);
        dataMap.put(SIB_Constants.IS_SUCCESS, String.isNotBlank(loginURL));
        return dataMap;
    }

    public static Map<String, Object> getStrivacityLoginUrl(Map<String, Object> dataMap) {
        Boolean isSuccess = false;
        String msg = '';

        if(dataMap != null && dataMap.containsKey(SIB_Constants.START_URL) && dataMap.get(SIB_Constants.START_URL) != null) {

            String communityUrl = System.Label.SIB_LWRSiteURL;
            String startUrl = (String) dataMap.get(SIB_Constants.START_URL);
            Map<String, Object> configMap = SIB_Util.fetchConfigMapByModule(SIB_Constants.SSO_MODULE);
            if(configMap != null) {
                String authProvider = (String)configMap.get(SIB_Constants.STRIVACITY_AUTH_PROVIDER);
                String ssoUrl = Auth.AuthConfiguration.getAuthProviderSsoDomainUrl(communityUrl, startUrl, authProvider);
                dataMap.put(SIB_Constants.SSO_URL, ssoUrl);
                isSuccess = true;
            }
        } else {
            isSuccess = false;
            msg = '';
        }
        dataMap.put(SIB_Constants.IS_SUCCESS, isSuccess); 
        dataMap.put(SIB_Constants.MESSAGE, msg);
        return dataMap;
    }
}