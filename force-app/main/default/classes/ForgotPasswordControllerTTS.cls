public with sharing class ForgotPasswordControllerTTS {
    
    public String username {get; set;}
    public String error {get;set;} 
    public String message{get;set;}
    
    public ForgotPasswordControllerTTS() { 
        username='';
        error='';
        message='';
    }
    
    public PageReference cancel()
    {
        username='';
        error='';
        message='';
        return Page.SiteRegister;
    }
    
    public PageReference forgotPassword() {
        
        List<Contact> con = new List<Contact>();
        ApexPages.Message msg;
        if(username=='')
        {
            msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Please enter a username.');
            ApexPages.addMessage(msg);
            error='Please enter a username.';
            return null;
            
        }
        con = [SELECT Password__c,Secondary_Email__c,User_Id__c,Email FROM Contact WHERE User_id__c=:username];
        if(con.size()==0)
        {
            msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Username does not exist.');
            ApexPages.addMessage(msg);
            error='Username does not exist.';
            return null;
        }
        else if(con.size()>1)
        {
            msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error. Multiple users with the same username.');
            ApexPages.addMessage(msg);
            error='Error. Multiple users with the same username.';
            return null;
            
        }
        else
        {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {con[0].Email}; 
            
            String[] ccAddresses = new String[] {con[0].Secondary_Email__c};
            mail.setToAddresses(toAddresses);
            if(con[0].Secondary_Email__c!=null)
                mail.setCcAddresses(ccAddresses);
            
            
            mail.setSubject('Training The Street Password');
            mail.setBccSender(false);
            mail.setPlainTextBody('Your Training The Street password is '+con[0].Password__c);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'An email has been sent.');
            ApexPages.addMessage(msg);
             message='An email has been sent.';
            return null;
            
        }
    }
    
    public static testMethod void testForgotPasswordControllerTTS()
    {
        ForgotPasswordControllerTTS controller = new ForgotPasswordControllerTTS();
        System.assert(controller.forgotPassword()==null);
        controller.username='testsf@salesforce123456';
        System.assert(controller.forgotPassword()==null);
        Contact c1 = new Contact(LastName='blah',User_Id__c='testsf@salesforce123456',Password__c='blah',Email='blah@blah.com',Secondary_Email__c='blah2@blah.com', Verify_Password__c ='blah');
        Contact c2 = new Contact(LastName='blah',User_Id__c='testsf@salesforce123456',Password__c='blah',Email='blah@blah.com',Secondary_Email__c='blah2@blah.com', Verify_Password__c ='blah');
        insert c1;
        insert c2;
        System.assert(controller.forgotPassword()==null);
        delete c2;
        System.assert(controller.forgotPassword()==null);
        
    }

}