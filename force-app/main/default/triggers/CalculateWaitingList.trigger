trigger CalculateWaitingList on Session__c (after update) {
/*	Set<string> sess_ids = new Set<String>();
	String current_session;
	Integer reg_count=0;
	List<Registration__c> regs;
	Map<id,decimal> seats_available = new Map<id,Decimal>();
	Map<id,decimal> seats_occupied = new Map<id,Decimal>();
	Map<id,decimal> wait_list_rank = new Map<id,Decimal>();
	Decimal s_avail,s_occ,wl_rank;
	
	for(Session__c sess:Trigger.new)
		sess_ids.add(sess.id);
		
	regs = [SELECT ID,Session__c,Waiting_List__c,Session__r.Seats_Available__c,Status__c FROM Registration__c WHERE  Session__c in :sess_ids AND Session__r.Seats_Available__c!=null ORDER BY CreatedDate ASC];
	if(regs.size()>0)
	{
	for(Registration__c reg:regs)
	{
		seats_available.put(reg.Session__c,reg.Session__r.Seats_Available__c);
		seats_occupied.put(reg.Session__c,0);
		wait_list_rank.put(reg.Session__c,1.0);
		
	}
	

	
	for(Registration__c reg:regs)
	{
		if(reg.Status__c.equalsIgnoreCase('Inactive')||reg.Status__c.equalsIgnoreCase('Cancelled')||reg.Status__c.equalsIgnoreCase('No Show'))
		{
			reg.Waiting_List__c=false;
			reg.Waiting_List_Ranking__c=0.0;
			
		}
		else
		{
			if(seats_available.containskey(reg.session__c))
			{
				s_avail=seats_available.get(reg.session__c);
				System.debug('Seats available='+s_avail.format());
				s_occ=seats_occupied.get(reg.session__c);
				System.debug('Seats occupied='+s_occ.format());
				wl_rank = wait_list_rank.get(reg.session__c);
				if(s_occ<s_avail)
				{
					System.debug('Registered user');
					reg.Status__c='Registered';
					s_occ=s_occ+1.0;
					System.debug('new seat occupied result='+s_occ.format());
					seats_occupied.put(reg.session__c,s_occ);
				}
				else
			    {
			    	System.debug('Placed user in waiting list');
			    	reg.Status__c='Waiting List';
			    	reg.Waiting_List__c=true;
			    	System.debug('Old waiting list rank='+wl_rank.format());
			    	reg.Waiting_List_Ranking__c=wl_rank;
			    	wl_rank=wl_rank+1;
			    	System.debug('new waiting list rank='+wl_rank.format());
			    	wait_list_rank.put(reg.session__c,wl_rank+1.0);
			    	
			    }
				
				
				
			}
			
			
		}
		
	}
	update regs;
	}
*/
}