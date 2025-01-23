trigger SessionTimeZones on Session__c (before insert, before update) {
    Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    Map<String, String> timezoneMap = new Map<String, String>();
    for( Schema.PicklistEntry f : ple)
    {
        String[] parts = f.GetLabel().split(' ');
        String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
        timezoneMap.put(endpart, f.getValue());
        System.Debug('>>> endpart: '+endpart);
        System.Debug('>>> f.getValue: '+f.getValue()); 
    }
    String[] events = new String[0];
    for(Session__c s : Trigger.new) {
		System.Debug('>>> s.Event__c: '+s.Event__c);
        events.add(s.Event__c);
    }
    Map<Id, Campaign> eventMap = new Map<Id, Campaign>([Select Id, Event_Time_Zone__c from Campaign where Id in :events]);
	System.debug('>>> eventMap: '+eventMap);
    for(Session__c s : Trigger.New) {
        if(eventMap.containsKey(s.Event__c) && eventMap.get(s.Event__c).Event_Time_Zone__c != null && eventMap.get(s.Event__c).Event_Time_Zone__c != '' && s.Start_AM_PM__c != null && s.Start_AM_PM__c != '' && s.Start_Hours__c != null && s.Start_Hours__c != '' && s.Start_Minutes__c != null && s.Start_Minutes__c != '' && s.Session_Date__c != null) {
            System.debug('>>> Entered Session Start NOT NULL');
			Integer hour = 0;
            hour += Integer.valueOf(s.Start_Hours__c);
            if(s.Start_Hours__c != '12' && s.Start_AM_PM__c == 'PM')
                hour += 12;
            else if(s.Start_Hours__c == '12' && s.Start_AM_PM__c == 'AM')
                hour = 0;
            DateTime t = DateTime.newInstanceGMT(s.Session_Date__c, Time.newInstance(hour, Integer.valueOf(s.Start_Minutes__c), 0, 0));
            System.Debug('>>> t: '+t);
            System.Debug('>>> s.Event__c: '+s.Event__c);
            System.Debug('>>> eventMap.get(s.Event__c).Event_Time_Zone__c: '+eventMap.get(s.Event__c).Event_Time_Zone__c);
            String[] parts = eventMap.get(s.Event__c).Event_Time_Zone__c.split(' ');
            String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
            String s2 = t.format('Z', timeZoneMap.get(endpart));
            String sign = s2.substring(0, 1);
            String h = s2.substring(1, 3);
            String m = s2.Substring(3, 5);
            Integer hours = Integer.valueOf(h);
            Integer minutes = Integer.valueOf(m);
            if(sign != '-') {
                minutes = 0 - minutes;
                hours = 0 - hours;
            }
            System.debug('>>> hours: '+hours);
            System.debug('>>> minutes: '+minutes);
            t = t.addHours(hours);
            t = t.addMinutes(minutes);
            s.Session_Start__c = t;
            System.Debug('>>> t: '+t);
            System.Debug('>>> t.format: '+t.format());
        }
        else {
			System.debug('>>> s.Session_Start__c = null;');
            s.Session_Start__c = null;
        }
        if(eventMap.containsKey(s.Event__c) && eventMap.get(s.Event__c).Event_Time_Zone__c != null && eventMap.get(s.Event__c).Event_Time_Zone__c != '' && s.end_AM_PM__c != null && s.end_AM_PM__c != '' && s.end_Hours__c != null && s.end_Hours__c != '' && s.end_Minutes__c != null && s.end_Minutes__c != '' && s.Session_Date__c != null) {
            System.debug('>>> Entered Session End NOT NULL');
			Integer hour = 0;
            hour += Integer.valueOf(s.end_Hours__c);
            if(s.end_Hours__c != '12' && s.end_AM_PM__c == 'PM')
                hour += 12;
            else if(s.end_Hours__c == '12' && s.end_AM_PM__c == 'AM')
                hour = 0;
            DateTime t = DateTime.newInstanceGMT(s.Session_Date__c, Time.newInstance(hour, Integer.valueOf(s.end_Minutes__c), 0, 0));
            System.Debug('>>> f.getValue: '+t);
            String[] parts = eventMap.get(s.Event__c).Event_Time_Zone__c.split(' ');
            String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
            String s2 = t.format('Z', timeZoneMap.get(endpart));
            String sign = s2.substring(0, 1);
            String h = s2.substring(1, 3);
            String m = s2.Substring(3, 5);
            Integer hours = Integer.valueOf(h);
            Integer minutes = Integer.valueOf(m);
            if(sign != '-') {
                minutes = 0 - minutes;
                hours = 0 - hours;
            }
            System.debug('>>> hours: '+hours);
            System.debug('>>> minutes: '+minutes);
            t = t.addHours(hours);
            t = t.addMinutes(minutes);
            s.Session_end__c = t;
            System.Debug('>>> t: '+t);
            System.Debug('>>> t.format: '+t.format());
        }
        else {
			System.debug('>>> s.Session_end__c = null;');
            s.Session_end__c = null;
        }
    }
}