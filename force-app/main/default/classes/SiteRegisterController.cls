/**
 * An apex class that creates a portal user
 */
public with sharing class SiteRegisterController {
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    private static Id PORTAL_ACCOUNT_ID = '001T000000h6iSi';
    
    public SiteRegisterController () {
        r_username_err='';
        email_err='';
        firstname_err='';
        lastname_err='';
        phone_err='';
        r_password_err='';
        success='';
        err='';
        l_username_err='';
        l_password_err='';
    }

    public string l_username{get;set;}
    public string l_username_err{get;set;}
    
    public string l_password{get;set;}
    public string l_password_err{get;set;}
    
    
    public String r_username {get; set;}
    public String r_username_err{get;set;}
    
    public String email {get; set;}
    public string email_err{get;set;}
    
    public String firstname {get; set; }
    public string firstname_err{get;set;}
    
    public String lastname {get; set; }
    public string lastname_err{get;set;}
    
    public string phone{get;set;}
    public string phone_err {get;set;}
    
    public string company{get;set;}
    public boolean info_box {get;set;}
    public string email2{get;set;}
    public string hear_about_us{get;set;}
    public String r_password {get; set {r_password = value == null ? value : value.trim(); } }
    public String r_password_err{get;set;}
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    //public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    public string success{get;set;}  
    public string err{get;set;}
    private boolean isValidPassword() {
        return r_password == confirmPassword;
    }
    
    public PageReference cancel_login()
    {
        clear_errors();
        l_username='';
        l_password='';
        return null;
        
    }
    
    public PageReference cancel_registration()
    {
        clear_errors();
        r_username='';
        r_password='';
        confirmPassword='';
        firstname='';
        lastname='';
        email='';
        email2='';
        company='';
        phone='';
        hear_about_us='';
        info_box=false;
        return null;
        
    }
    
    public PageReference registerUser() {
        // it's okay if r_password is null - we'll send the user a random r_password in that case
        List<contact> ct = new List<Contact>();
     List<Account> portal_acct = [SELECT ID from Account WHERE Name ='TTS Sites Users'];
     List<RecordType> r_type = [SELECT ID from RecordType WHERE Name='Sites_User'];  
     Boolean isValidReg = true;
     clear_errors();
    
        if (!isValidPassword()) {
                
                r_password_err='The passwords do not match.';
            isValidReg=false;
            //return null;
        }  
        if(r_username==null||r_username=='')
        {
                
                r_username_err='Please enter a username.';
            isValidReg=false;
            //return null;
                
                
        }
         if(r_password==null||r_password=='')
        {
                
            r_password_err='Please enter a password.';
            isValidReg=false;
            //return null;
                
                
        }
        if(firstname==null||firstname=='')
        {
                
            firstname_err='Please enter a value in the first name field.';
            isValidReg=false;
            //return null;
                
                
        }
        
        if(lastname==null||lastname=='')
        {
                
                lastname_err='Please enter a value in the last name field.';
            isValidReg=false;
            //return null;
                
                
        }
        
        if(email==null||email=='')
        {
                
                email_err='Please enter an email address';
                isValidReg=false;
            //return null;
                
                
        }
        else
        {
                
                Pattern emailPat=Pattern.compile('[\\w\\.\\-]+@([\\w\\-]+\\.)+[a-zA-Z]{2,4}');
    
                Matcher emailMatch=emailPat.matcher(email);
                
                if(!emailMatch.matches())
                {
                        
                        email_err='Invalid email address';
                        isValidReg=false;
                        //return null;
                        
                }
                //success = 'validated email';
                /*
                Boolean EmailValid=true;
                Contact c;
                Try
                {
                        c = new Contact(LastName='fake',Email=email);
                        insert c;
                }
                catch(Exception e)
                {
                        EmailValid=false;
                        email_err='Invalid Email address';
                        
                }
                if(EmailValid)
                {
                        try{
                                delete c;
                        }
                        catch(Exception e)
                        {
                                
                        }
                        
                }
                else return null;
                */
                
                
                
        }
        
        if(phone==null||phone=='')
        {
                
                phone_err='Please enter a phone number.';
            isValidReg=false;
            //return null;
                
                
        }
        //success='querying username.';
        ct = [SELECT ID FROM Contact WHERE User_id__c=:r_username];
        if(!ct.isEmpty())
        {
               
                r_username_err='username already exists.';
            isValidReg=false;
            //success='username is not empty.';
            
                
                
        }
        //else success='username is empty.';
        
        ct = [SELECT ID FROM Contact WHERE RecordTypeID='012A0000000pbKT' AND email=:email];
        if(!ct.isEmpty())
        {
                
                email_err='user with email address already exists.';
            isValidReg=false;
            //success='email exists';
            
                
                
        }
        //else success='email does not exist';
        
        if(!isValidReg){
           //success='registration is not valid';
         return null;
         }
         //else success ='registration is valid';
        
        
        if(portal_acct.isEmpty()) success = 'portal_acct is empty';
        else success ='portal_acct is not empty';
        
        if(!portal_acct.isEmpty())
        {
                
                ct = [SELECT ID,User_Id__c,Password__c,FirstName,LastName,Email,Phone,Company__c,Receive_E_Mails_From_TTS__c,Secondary_Email__c,How_did_you_hear_about_us__c,GUID__c,AccountId,RecordTypeId,Verify_Password__c FROM Contact WHERE email=:email AND RecordTypeID!='012A0000000pbKT'];
                //Contact c = new Contact();
                if(ct.isEmpty())
                	ct.add(new Contact());
                
                ct[0].User_Id__c = r_username;
                ct[0].Password__c=r_password;
                ct[0].FirstName=firstname;
                ct[0].LastName=lastname;
                ct[0].Email = email;
                ct[0].Phone=phone;
                
                ct[0].Company__c=company;
                ct[0].Receive_E_Mails_From_TTS__c=info_box;
                ct[0].Secondary_Email__c=email2;
                ct[0].How_did_you_hear_about_us__c=hear_about_us;
                ct[0].GUID__c=RandomStringUtils.randomUUID();
                if(ct[0].Id == null)
         	       ct[0].AccountId=portal_acct[0].id;
                ct[0].RecordTypeId='012A0000000pbKT';
                ct[0].Verify_Password__c = confirmPassword;
                
                
                
                success='almost at contact creation stage';
                
        
                // lastName is a required field on user, but if it isn't specified, we'll default it to the r_username
                //String userId = Site.createPortalUser(u, accountId, r_password);
                try
                {
                        upsert ct;
                        
                        success='User '+r_username+' created.';
                        PageReference p = Page.SelectEvent;
                        p.getParameters().put('userId', ct[0].Id);
                        p.getParameters().put('userName', ct[0].User_Id__c);
                        p.getParameters().put('new', 'true');
                        success='Login successful!';
                        return p;
                        //return null;
                        
                        
                }
                catch (Exception e)
                {
                        
                        err='An error has occurred= '+e;
                        return null;
                        
                }
        }
        return null;
        /*
        if (userId != null) { 
            if (r_password != null && r_password.length() > 1) {
                return Site.login(r_username, r_password, null);
            }
            else {
                PageReference page = System.Page.SiteRegisterConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
        */
    }
    public Pagereference cancel()
    {
    return new PageReference('/register');
        
    }
    
    public void clear_errors()
    {
        l_username_err='';
        l_password_err='';
        r_username_err='';
        email_err='';
        firstname_err='';
        lastname_err='';
        phone_err='';
        r_password_err='';
        success='';
        err='';
        l_username_err='';
        l_password_err='';
        
        
        
    }
    
    
    
    public PageReference login() {
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        //return Site.login(username, l_password, startUrl);
        
        clear_errors();
        if(l_username.trim()=='')
        {
                l_username_err='Please enter a username.';
                return null;
        }
        
        if(l_password.trim()=='')
        {
                
                l_password_err='Please enter a password.';
                return null;
        }
        
        List<Contact> cont = [SELECT User_Id__c,ID,Password__c, GUID__c from Contact WHERE User_Id__c=:l_username];
        if(cont.size()==0)
        {
                
                l_username_err='No user with username '+l_username+' found.';
                return null;
        }
        
        else if(cont.size()>1)
        {
                
                l_username_err='Error: Multiple users with the same username found.  Please contact the administrator.';
                return null;
        }
        else
        {
                if(cont[0].Password__c.equals(l_password))
                {
                        PageReference p = Page.SelectEvent;
                        p.getParameters().put('userId', cont[0].Id);
                        p.getParameters().put('userName', cont[0].User_Id__c);
                        success='Login successful!';
                        return p;
                        //return null;
                        
                        
                }
                else
                {
                        //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
                        
                        l_password_err='Wrong password for username.';
                        
                        
                        return null;
                        
                }
                return null;
        }
        
        
        
    
    }
    // Test method to bring this class's test coverage over the required 75%
    static testMethod void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        controller.r_username = 'test@force.com';
        controller.r_password='123';
        controller.confirmPassword='1234';
        System.assert(controller.registerUser() == null);
        //System.assert(controller.registerUser()==Page.SelectEvent);
        
        controller.r_username=null;
        controller.r_password=null;
        controller.confirmPassword=null;
        

        controller.r_username = null;
        System.assert(controller.registerUser() == null);
        
        controller.r_username = '';
        System.assert(controller.registerUser() == null);
        
        controller.r_username='test@force.com1234567890qwertyuioasdfghjk';
        
        controller.r_password=null;
        System.assert(controller.registerUser() == null);
        
                controller.r_password='';
        System.assert(controller.registerUser() == null);
        
        controller.r_password='123';
        controller.confirmPassword='123';
        
        
        controller.firstname=null;
        System.assert(controller.registerUser() == null);
        
        controller.firstname='';
        System.assert(controller.registerUser() == null);
        
        controller.firstname='test';
        
        
        controller.lastname=null;
        System.assert(controller.registerUser() == null);    
        
        controller.lastname='';
        System.assert(controller.registerUser() == null);  
        
        controller.lastname='lastname';
        
        controller.email=null;
        System.assert(controller.registerUser() == null);  
        
        controller.email='';
        System.assert(controller.registerUser() == null);  
        
        controller.email='test@salesforce.com';
        controller.email2='test2@salesforce.com';
        
        controller.phone=null;
        System.assert(controller.registerUser() == null); 
        
        controller.phone='';
        System.assert(controller.registerUser() == null); 
        
        controller.phone='555-5555';
        controller.company='trainingthestreet';
        controller.info_box=true;
        controller.hear_about_us='very carefully';
        Contact cont=new Contact(LastName='test',User_Id__c='test@force.com1234567890qwertyuioasdfghjk');
        insert cont;
        controller.registerUser();
        delete cont;
        controller.registerUser();
        
        
    }
}