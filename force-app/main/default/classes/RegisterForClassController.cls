public with sharing class RegisterForClassController {
	
	
	
	Public class Registration_w{
		public Session__c sess{get;set;}
		public Registration__c reg{get;set;}
		public boolean isChecked {get;set;}
		public String Status{get;set;}
		public boolean hasReg{get;set;}
		public String coupon_code{get;set;}
		
		public Registration_w(Session__c s)
		{
			isChecked=false;
			sess=s;
			if(sess.Session_Members__r.size()>0)
			{
				reg=sess.session_members__r[0];
				if(reg.status__c!=null)
				if(reg.Status__c.equalsIgnoreCase('Waiting List')||reg.Status__c.equalsIgnoreCase('Registered'))
					isChecked=true;
				Status=reg.Status__c;
				hasReg=true;
			}
			else hasReg=false;
			
			
		}
		
		
	}
	
	
	
	Public List<Session__c> sessions{get;set;}
	public List<Contact> cont{get;set;}
	public List<Campaign> evt{get;set;}
	public List<Registration_w> regs{get;set;}
	
	
	
	
	
	
	public RegisterForClassController()
	{
		sessions = new List<Session__c>();
		String cont_guid = ApexPages.currentPage().getParameters().get('cid');
		String evt_id = ApexPages.currentPage().getParameters().get('eid');
		//string evt_id='1234';
		//string cont_guid='test-guid';
		ApexPages.Message msg;
		regs=new List<Registration_w>();
		cont = [SELECT ID,guid__c FROM Contact WHERE guid__c=:cont_guid];
		if(cont.size()!=1)
		{
			msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid user. '+cont.size().format());
        	ApexPages.addMessage(msg);
        	return;
			
		}
		
		evt = [SELECT ID, CurrencyISOCode from Campaign WHERE Class_Code__c=:evt_id];
		if(evt.isEmpty())
		{
			msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Class.');
        	ApexPages.addMessage(msg);
        	return;
			
			
		}
		sessions = [Select Waiting_List_Members__c, Session_Code__c, Seats_Available__c, Required__c, Name, (Select Name, Status__c, Registration_Code__c,Contact__c,Unique_Identifier__c,	Waiting_List_Ranking__c,Waiting_List__c From Session_Members__r WHERE Contact__c=:cont[0].id) From Session__c WHERE Session__c.event__r.Class_Code__c=:evt_id Order By Name ASC];
		if(sessions.isEmpty())
		{
			msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'No sessions have been created for this class');
        	ApexPages.addMessage(msg);
        	return;
			
		}
		for(Session__c s:sessions)
			regs.add(new Registration_w(s));
		
	}
	
	public PageReference Submit()
	{
		Registration__c reg;
		List<Registration__c> regs_for_upsert = new List<Registration__c>();
		List<Registration_w> req_regs = new List<Registration_w>();
		Boolean needs_required = false;
		List<CampaignMember> mem = new List<CampaignMember>();
		CampaignMember cmem;
		ApexPages.Message msg;
		if(regs.size()>0)
		{
			
			
			mem = [SELECT ID from CampaignMember WHERE ContactID=:cont[0].id AND CampaignID=:evt[0].id];
			if(mem.size()==0)
			{
				cmem = new CampaignMember(CurrencyIsoCode = evt[0].Id, CampaignId=evt[0].id,ContactId=cont[0].id);
				insert cmem;
				
			}
			
			
			for(Registration_w r:regs)
			{
				if(r.isChecked==true&&r.sess.Required__c==true)needs_required=true;
				
				
			}
			
			if(needs_required==true)
			{
				for(Registration_w r:regs)
				{
					if(r.sess.Required__c==true&&r.isChecked==false)
					{
						msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please register for all required classes.');
        				ApexPages.addMessage(msg);
						
					}
					
					
				}
				
				
			}
			
			
			
			for(Registration_w r:regs)
			{
				if(r.hasReg==true)
				{
					reg=r.reg;
					reg.Coupon_Code__c=r.coupon_code;
					if(reg.Status__c==null&& r.isChecked==true)
						reg.Status__c='Registered';
					else
					{
						if(r.isChecked==false && (reg.Status__c.equalsIgnoreCase('Waiting List')||reg.Status__c.equalsIgnoreCase('Registered')))
							reg.Status__c='Cancelled';
						else if (r.isChecked==false && reg.Status__c.equalsIgnoreCase('Inactive'))
							reg.Status__c='Inactive';
						else reg.Status__c='Registered' ;
					}
					
					
					regs_for_upsert.add(reg);
					
				}
				else
				{
					reg= new Registration__c(Unique_Identifier__c=r.sess.Session_Code__c+cont[0].id,Contact__c=cont[0].id,Session__c=r.sess.id);
					reg.Coupon_Code__c=r.coupon_code;
					if(r.isChecked)
						reg.Status__c='Registered';
					else reg.Status__c='Inactive';
					regs_for_upsert.add(reg);
				}
				upsert regs_for_upsert;
				
			}
			
		}
		
		
		msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, regs_for_upsert.size().format()+' registrations have been updated.');
        ApexPages.addMessage(msg);
		if(sessions.size()>0) update sessions;
		return null;
	
	}
	static testMethod void testRegisterForClassController ()
	{
		RegisterForClassController controller;
		ApexPages.currentPage().getParameters().put('cid', 'guidguidguid');
		controller = new RegisterForClassController();
	}
	static testMethod void testRegisterForClassController2 () {
		RegisterForClassController controller;
		Contact c1 = new Contact(LastName='lastname',guid__c='guidguidguid');
		insert c1;
		ApexPages.currentPage().getParameters().put('eid', '1234567890');
		controller = new RegisterForClassController();
	}
	static testMethod void testRegisterForClassController3 () {
		RegisterForClassController controller;
		Campaign camp1 = new Campaign();
		camp1.EndDate=Date.newInstance(2011, 9, 10);
		camp1.StartDate = Date.newInstance(2011, 9, 1);
		camp1.Name='TestTestClass';
		insert camp1;
		camp1=[SELECT Class_Code__c,ID,Name from Campaign WHERE ID=:camp1.id];
		ApexPages.currentPage().getParameters().put('cid', 'guidguidguid');
		ApexPages.currentPage().getParameters().put('eid', camp1.Class_Code__c);
		controller = new RegisterForClassController();
	}
	static testMethod void testRegisterForClassController4 () {
		List<Session__c> sess = new List<Session__c>();
		RegisterForClassController controller;
		Campaign camp1 = new Campaign();
		camp1.EndDate=Date.newInstance(2011, 9, 10);
		camp1.StartDate = Date.newInstance(2011, 9, 1);
		camp1.Name='TestTestClass';
		CreateSession.CreateSessionFromEvent(camp1.id);
		controller = new RegisterForClassController();
		sess=[SELECT ID from Session__c WHERE Event__c=:camp1.id];
		System.assert(sess.size()==controller.regs.size());
		
		
		Integer i=0;
		for(i=0;i<controller.regs.size()/2;i++)
			controller.regs[i].isChecked=true;
		
		controller.Submit();
		ApexPages.currentPage().getParameters().put('cid', 'guidguidguid');
		ApexPages.currentPage().getParameters().put('eid', camp1.Class_Code__c);
		controller = new RegisterForClassController();
		//controller.regs[0].ischecked=false;
		//controller.regs[1].ischecked=false;
		controller.Submit();
		sess=[SELECT ID,Required__c from Session__c WHERE Event__c=:camp1.id];
		//sess[0].Required__c=true;
		//sess[sess.size()-1].Required__c=true;
		update sess;
		controller = new RegisterForClassController();
		controller.submit();
		controller = new RegisterForClassController();
		//controller.regs[0].isChecked=true;
		//controller.regs[controller.regs.size()-1].ischecked=true;
		controller.Submit();
	}
	

}