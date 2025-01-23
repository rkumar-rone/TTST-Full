global class CreateSession {

WebService static String CreateSessionFromEvent(String id)
{
	List<Campaign> camp = new List<Campaign>();
	List<Session__c> sess =new List<Session__c>();
	Session__c temp_s;
	Date sd,ed;
	Integer i=0;
	camp = [SELECT Name,ID,CurrencyIsoCode, Primary_Contact__c,StartDate,EndDate from Campaign WHERE ID=:id];
	if(camp.size()==0) return 'Invalid campaign';
	if(camp[0].StartDate==null) return 'No Start Date';
	if(camp[0].EndDate==null) return 'No End Date';
	
	
	sd=camp[0].StartDate;
	ed=camp[0].EndDate;
	for(i=1;sd.daysBetween(ed) >= 0;sd=sd.addDays(1))
	{
		temp_s = new Session__c(CurrencyIsoCode = camp[0].CurrencyIsoCode, Event__c=camp[0].Id);
		temp_s.Name='Day '+i.format();
		temp_s.Session_Date__c=sd;
		temp_s.Instructor__c= camp[0].Primary_Contact__c;
		sess.add(temp_s);
		i++;
		System.debug('Value for days inbetween '+sd.daysBetween(ed).format());
		
	}
	insert sess;
	return sess.size().format()+' sessions have been created';
	
	
	
}
WebService static String CreateSessionFromEventNoWE(String id)
{
	List<Campaign> camp = new List<Campaign>();
	List<Session__c> sess =new List<Session__c>();
	Session__c temp_s;
	Date sd,ed, temp_date;
	Integer i=0;
	Boolean isWeekend=false;
	camp = [SELECT Name,CurrencyISOCode,ID,Primary_Contact__c,StartDate,EndDate from Campaign WHERE ID=:id];
	if(camp.size()==0) return 'Invalid campaign';
	if(camp[0].StartDate==null) return 'No Start Date';
	if(camp[0].EndDate==null) return 'No End Date';
	
	
	sd=camp[0].StartDate;
	ed=camp[0].EndDate;
	for(i=1;sd.daysBetween(ed) >= 0;sd=sd.addDays(1))
	{
		temp_date=sd.toStartOfWeek();
		if(temp_date.isSameDay(sd)) isWeekend=true;
		
		if(temp_date.daysBetween(sd)==6) isWeekend=true;
		if(!isWEekend)
		{
			temp_s = new Session__c(CurrencyIsoCode = camp[0].CurrencyIsoCode, Event__c=camp[0].Id);
			temp_s.Name='Day '+i.format();
			temp_s.Session_Date__c=sd;
			temp_s.Instructor__c= camp[0].Primary_Contact__c;
			sess.add(temp_s);
			i++;
		}
		isWeekend=false;
		System.debug('Value for days inbetween '+sd.daysBetween(ed).format());
		
	}
	insert sess;
	return sess.size().format()+' sessions have been created';
}

static testMethod void session_test()
{
	Campaign camp;
	String result;
	result=CreateSessionFromEvent('0');	
	System.assert(result.equals('Invalid campaign'));
	result=CreateSessionFromEventNoWE('0');
	System.assert(result.equals('Invalid campaign'));
	camp = new Campaign(Name='test');
	insert camp;
	
	result=CreateSessionFromEvent(camp.id);	
	System.assert(result.equals('No Start Date'));
	result=CreateSessionFromEventNoWE(camp.id);
	System.assert(result.equals('No Start Date'));
	
	camp.StartDate = Date.today();
	update camp;
	
	result=CreateSessionFromEvent(camp.id);	
	System.assert(result.equals('No End Date'));
	result=CreateSessionFromEventNoWE(camp.id);
	System.assert(result.equals('No End Date'));
	
	Test.startTest();
	
	camp.StartDate = Date.newInstance(2011, 3, 1);
	camp.EndDate = Date.newInstance(2011, 3, 8);
	update camp;
	
	result=CreateSessionFromEvent(camp.id);	
	System.debug(result);
	System.assert(result.equals('8 sessions have been created'));
	result=CreateSessionFromEventNoWE(camp.id);
	System.debug(result);
	System.assert(result.equals('6 sessions have been created'));
	
	test.stopTest();
	
}
}