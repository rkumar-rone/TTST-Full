public with sharing class ThankYou {
	public Sess[] wSessions {get;set;}
	
	public ThankYou() {
		wSessions = new Sess[0];
		String[] s = new String[0];
		String[] p = new String[0];
		if(ApexPages.currentPage().getParameters().containsKey('sessName')) {
			s = ApexPages.currentPage().getParameters().get('sessName').split(',');
			p = ApexPages.currentPage().getParameters().get('pos').split(',');
		}
		for(Integer i = 0; i < s.size(); i++) {
			Sess sTemp = new Sess();
			sTemp.SessionName = s[i];
			sTemp.position = p[i];
			wSessions.add(sTemp);
		}
		
	}
	public PageReference selectMore() {
		PageReference p = Page.SelectEvent;
		String userId = ApexPages.currentPage().getParameters().get('userId');
		String userName = ApexPages.currentPage().getParameters().get('userName');
		if(userId != null)
			p.getParameters().put('userId', userId);
		if(userName != null)
			p.getParameters().put('userName', userName);
		p.setRedirect(true);
		return p;
	}
	public class Sess {
		public String sessionName {get;set;}
		public String position {get;set;}
	}
	
	public Boolean getWaitlist() {
		if(wSessions.size() > 0)
			return true;
		return false;
	}
}