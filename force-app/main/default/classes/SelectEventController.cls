public with sharing class SelectEventController {

public class MonthGroup
{
    public MonthGroup(Integer i)
    {
        month_number=i;
        events = new List<Campaign>();
    }
    
    public integer year{get;set;}
    public integer month_number{get;set;}
    
    public string getheader()
    {
        return month_name()+' '+String.valueof(year);
        
    }
    public string month_name()
    {
        if(month_number==1) return 'January';
        else if (month_number==2) return 'Feburary';
        else if (month_number==3) return 'March';
        else if (month_number==4) return 'April';
        else if (month_number==5) return 'May';
        else if (month_number==6) return 'June';
        else if (month_number==7) return 'July';
        else if (month_number==8) return 'August';
        else if (month_number==9) return 'September';
        else if (month_number==10) return 'October';
        else if (month_number==11) return 'November';
        else if (month_number==12) return 'December';
        else return ''; 
        
        
    }
    public List<Campaign> events{get;set;}
    public List<Campaign> getClasses(){return events;}
    public integer getCount(){return events.size();}
    
    
    
    
}

public List<Contact> cont{get;set;}
public List<MonthGroup> grouped_events{get;set;}

public List<MonthGroup> getGrouping (){return grouped_events;}

public SelectEventController(){
ApexPages.Message msg;
Integer current_month;
MonthGroup t_month;
grouped_events= new List<MonthGroup>();
String cont_guid = ApexPages.currentPage().getParameters().get('cid');
cont = [SELECT ID,guid__c FROM Contact WHERE guid__c=:cont_guid];

if(cont.size()!=1)
{
        msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid account.  Please log in.');
        ApexPages.addMessage(msg);
}

List<Campaign> events = new List<Campaign>();
events = [SELECT ID,Class_Code__c,StartDate,EndDate,Name, Online_Event_Name__c FROM Campaign WHERE StartDate >=TODAY ORDER BY StartDate ASC];


if(!events.isEmpty())
{
    current_month=events[0].startDate.month();
    t_month= new MonthGroup(current_month);
    t_month.year=events[0].startDate.year();
    t_month.events.add(events[0]);
    for(Integer i=1;i<events.size();i++)
    {
        if(events[i].StartDate.month()==current_month)
            t_month.events.add(events[i]);
        else
        {
            grouped_events.add(t_month);
            current_month=events[i].startDate.month();
            t_month= new MonthGroup(current_month);
            t_month.year=events[i].startDate.year();
            t_month.events.add(events[i]);
            
        }
        
    }
    if(grouped_events[grouped_events.size()-1].month_number!=t_month.month_number)
        grouped_events.add(t_month);
    
    
}

}

public static testMethod void testSelectEventController()
{
    ApexPages.currentPage().getParameters().put('cid','guidguidguidguid');
    SelectEventController controller = new SelectEventController();
    Contact c1 = new Contact(LastName='lastname',guid__c='guidguidguidguid');
    insert c1;
    controller = new SelectEventController();
    List<Campaign> ct = [SELECT ID from Campaign];
   //if(ct.size()>0) delete ct;
    Integer nyear = Date.today().year()+1;
    Integer i;
    String s;
    Campaign ev1 = new Campaign(Name='ev1',StartDate=Date.newInstance(nyear, 1, 1),EndDate=Date.newInstance(nyear, 1, 2));
    Campaign ev2 = new Campaign(Name='ev2',StartDate=Date.newInstance(nyear, 2, 1),EndDate=Date.newInstance(nyear, 2, 2));
    Campaign ev3 = new Campaign(Name='ev3',StartDate=Date.newInstance(nyear, 3, 1),EndDate=Date.newInstance(nyear, 3, 2));
    Campaign ev4 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 4, 1),EndDate=Date.newInstance(nyear, 4, 2));
    Campaign ev5 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 5, 1),EndDate=Date.newInstance(nyear, 5, 2));
    Campaign ev6 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 6, 1),EndDate=Date.newInstance(nyear, 6, 2));
    Campaign ev7 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 7, 1),EndDate=Date.newInstance(nyear, 7, 2));
    Campaign ev8 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 8, 1),EndDate=Date.newInstance(nyear, 8, 2));
    Campaign ev9 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 9, 1),EndDate=Date.newInstance(nyear, 9, 2));
    Campaign ev10 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 10, 1),EndDate=Date.newInstance(nyear, 10, 2));
    Campaign ev11 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 11, 1),EndDate=Date.newInstance(nyear, 11, 2));
    Campaign ev12 = new Campaign(Name='ev4',StartDate=Date.newInstance(nyear, 12, 1),EndDate=Date.newInstance(nyear, 12, 2));
    Campaign ev13 = new Campaign(Name='ev1',StartDate=Date.newInstance(nyear, 1, 3),EndDate=Date.newInstance(nyear, 1, 4));
  //  insert ev1;
  //  insert ev2;
  //  insert ev3;
  //  insert ev4;
  //  insert ev5;
  // insert ev6;
  // insert ev7;
  // insert ev8;
  //  insert ev9;
  //  insert ev10;
  //  insert ev11;
  //  insert ev12;
  //  insert ev13;
    controller = new SelectEventController();
    //System.assert(controller.grouped_events.size()==12);
    for(MonthGroup mg:controller.getGrouping())
    {
        s=mg.month_name();
        s=mg.getheader();
        i=mg.getCount();
        ct=mg.getClasses();
    }
    
}


}