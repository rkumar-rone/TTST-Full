public with sharing class Forgot_Username {

        public string email{get;set;}
    public string status{get;set;}
    public string username{get;set;}
    public string Renderlink{
        get
        {
            if(username=='') return 'false';
            else return 'true';
        
        }
     }
    
    public Forgot_Username()
    {
        email='';
        status='';
        username='';
    }
    
    public PageReference redirect_to_login()
    {
        PageReference p = Page.SiteRegister;
        return p;
    
    }

    public PageReference submit()
    {
        
        username='';
        status='';
        List<Contact> ct = [SELECT ID,User_Id__c,Email From Contact WHERE email=:email];
        
        if(ct.size()==0)
        {
            status='No Usernames found with the specified email address.';
            return null;
            
        }
        else if(ct.size()==1)
        {
            
            username=ct[0].User_Id__c;
            status='The username associated with this email address is : ';
            return null;
        }
        else
        {
            
            status='Error multiple users found with the email address '+email+'.';
            return null;
        }
        
        
        
    }
    public PageReference cancel()
    {
        
        PageReference p = Page.SiteRegister;
        return p;
        
    }
    public static TestMethod void forgot_username_test()
    {
        PageReference p;
        Forgot_username controller = new Forgot_username();
        controller.email='zxcvbnm@zxc.com';
        p=controller.submit();
        System.debug('controller status='+controller.status);
        Contact ct = new Contact(Lastname='blah',User_id__c='zxcvbnm',Email='zxcvbnm@zxc.com');
        insert ct;
        controller = new Forgot_username();
        controller.email='zxcvbnm@zxc.com';
        p=controller.submit();  
        System.assert(controller.status=='The username associated with this email address is : ');
        Contact ct1 = new Contact(Lastname='blah',User_id__c='zxcadsvbnm',Email='zxcvbnm@zxc.com');
        insert ct1;
        controller = new Forgot_username();
        controller.email='zxcvbnm@zxc.com';
        p=controller.submit();  
        System.assert(controller.status=='Error multiple users found with the email address zxcvbnm@zxc.com.');
    }
     

}