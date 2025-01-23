/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController  {
    global String username {get; set;}
    global String password {get; set;}
    global String error{get;set;}

    global PageReference login() {
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        //return Site.login(username, password, startUrl);
    	error='';
    	if(username.trim()=='')
    	{
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a username.');
        	ApexPages.addMessage(msg);    		
    		error='Please enter a username.';
    		return null;
    	}
    	
    	if(password.trim()=='')
    	{
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a password.');
        	ApexPages.addMessage(msg);    		
    		error='Please enter a password.';
    		return null;
    	}
    	
    	List<Contact> cont = [SELECT User_Id__c,ID,Password__c, GUID__c from Contact WHERE User_Id__c=:username];
    	if(cont.size()==0)
    	{
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No user with username '+username+' found.');
        	ApexPages.addMessage(msg); 
    		error='No user with username '+username+' found.';
    		return null;
    	}
    	
    	else if(cont.size()>1)
    	{
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Multiple users with the same username found.  Please contact the administrator.');
        	ApexPages.addMessage(msg); 
    		error='Error: Multiple users with the same username found.  Please contact the administrator.';
    		return null;
    	}
    	else
    	{
    		if(cont[0].Password__c.equals(password))
    		{
    			
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Login successful!');
        		ApexPages.addMessage(msg); 
    			error='Login successful!';
    			PageReference p = Page.SelectEvent;
    			p.getParameters().put('userId', cont[0].Id);
    			p.getParameters().put('userName', cont[0].User_Id__c);
    			return p;
    			//return null;
    			
    			
    		}
    		else
    		{
    			//ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
        		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Wrong password for username.');
        		ApexPages.addMessage(msg); 
        		error='Wrong password for username.';
    			
        		
    			return null;
    			
    		}
    		return null;
    	}
    	
    	
    	
    
    }
    
   	global SiteLoginController () 
   	{
   		username='';
   		password='';
   		error='';
   	
   	}
    
    global static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = '';
        System.assert(controller.login()==null);
        controller.username='testsf@1234567890qwertyuio';
        controller.password = ''; 
        System.assert(controller.login()==null);
        controller.password='12345';
        System.assert(controller.login()==null);
        Contact c1 = new Contact(LastName='lastname',User_id__c='testsf@1234567890qwertyuio',Password__c='1234', Verify_Password__c='1234');
        Contact c2 = new Contact(LastName='lastname',User_id__c='testsf@1234567890qwertyuio');
        insert c1;
        insert c2;
        System.assert(controller.login()==null);
        delete c2;
        System.assert(controller.login()==null);
        controller.password='1234';
        //System.assert(controller.login()==null);
        
                
                     
    }    
}