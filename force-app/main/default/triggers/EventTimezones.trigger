trigger EventTimezones on Campaign (before insert, before update) {
	Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getDescribe();
	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	Map<String, String> timezoneMap = new Map<String, String>();
    for( Schema.PicklistEntry f : ple)
	{
		String[] parts = f.GetLabel().split(' ');
		String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
		system.debug('endpart : '+endpart);
		system.debug('f.GetLabel() : '+f.GetLabel());
		timezoneMap.put(endpart, f.getValue());
		timezoneMap.put(f.getLabel(), f.getValue());
		system.debug('timeZoneMap : '+JSON.serializePretty(timeZoneMap));
	}
	system.debug('timeZoneMap : '+timeZoneMap.keySet());
	for(Campaign c : Trigger.new) {
		if(c.Event_Time_Zone__c != null && c.Event_Time_Zone__c != '' && c.Registration_From_AM_PM__c != null && c.Registration_From_AM_PM__c != '' && c.Registration_From_Hours__c != null && c.Registration_From_Hours__c != '' && c.Registration_From_Minutes__c != null && c.Registration_From_Minutes__c != '' && c.Registration_From_Date__c != null) {
			Integer hour = 0;
			hour += Integer.valueOf(c.Registration_From_Hours__c);
			if(c.Registration_From_Hours__c != '12' && c.Registration_From_AM_PM__c == 'PM')
				hour += 12;
			else if(c.Registration_From_Hours__c == '12' && c.Registration_From_AM_PM__c == 'AM')
				hour = 0;
			DateTime t = DateTime.newInstanceGMT(c.Registration_From_Date__c, Time.newInstance(hour, Integer.valueOf(c.Registration_From_Minutes__c), 0, 0));
			System.Debug(t);
			String[] parts = c.Event_Time_Zone__c.split(' ');
			String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			system.debug('endpart : '+endpart);
			String s = t.format('Z', timeZoneMap.get(endpart));
			String sign = s.substring(0, 1);
			String h = s.substring(1, 3);
			String m = s.Substring(3, 5);
			Integer hours = Integer.valueOf(h);
			Integer minutes = Integer.valueOf(m);
			if(sign != '-') {
    			minutes = 0 - minutes;
    			hours = 0 - hours;
			}
			System.debug(hours);
			System.debug(minutes);
			t = t.addHours(hours);
			t = t.addMinutes(minutes);
			c.Registration_From__c = t;
			System.Debug(t);
			System.Debug(t.format());
		}
		else {
			c.Registration_From__c = null;
		}
		if(c.Event_Time_Zone__c != null && c.Event_Time_Zone__c != '' && c.Registration_To_AM_PM__c != null && c.Registration_To_AM_PM__c != '' && c.Registration_To_Hours__c != null && c.Registration_To_Hours__c != '' && c.Registration_To_Minutes__c != null && c.Registration_To_Minutes__c != '' && c.Registration_To_Date__c != null) {
			Integer hour = 0;
			hour += Integer.valueOf(c.Registration_To_Hours__c);
			if(c.Registration_To_Hours__c != '12' && c.Registration_To_AM_PM__c == 'PM')
				hour += 12;
			else if(c.Registration_To_Hours__c == '12' && c.Registration_To_AM_PM__c == 'AM')
				hour = 0;
			DateTime t = DateTime.newInstanceGMT(c.Registration_To_Date__c, Time.newInstance(hour, Integer.valueOf(c.Registration_To_Minutes__c), 0, 0));
			System.Debug(t);
			String[] parts = c.Event_Time_Zone__c.split(' ');
			String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			String s = t.format('Z', timeZoneMap.get(endpart));
			String sign = s.substring(0, 1);
			String h = s.substring(1, 3);
			String m = s.Substring(3, 5);
			Integer hours = Integer.valueOf(h);
			Integer minutes = Integer.valueOf(m);
			if(sign != '-') {
    			minutes = 0 - minutes;
    			hours = 0 - hours;
			}
			System.debug(hours);
			System.debug(minutes);
			t = t.addHours(hours);
			t = t.addMinutes(minutes);
			c.Registration_To__c = t;
			System.Debug(t);
			System.Debug(t.format());
		}
		else {
			c.Registration_To__c = null;
		}
		if(c.Cancellation_Deadline_Hours__c == null || c.Cancellation_Deadline_Hours__c == '')
			c.Cancellation_Deadline_Hours__c = c.Registration_From_Hours__c;
		if(c.Cancellation_Deadline_Minutes__c == null || c.Cancellation_Deadline_Minutes__c == '')
			c.Cancellation_Deadline_Minutes__c = c.Registration_From_Minutes__c;
		if(c.Cancellation_Deadline_AM_PM__c == null || c.Cancellation_Deadline_AM_PM__c == '')
			c.Cancellation_Deadline_AM_PM__c = c.Registration_From_AM_PM__c;
		/*if(c.Cancellation_Deadline_Date__c == null)
			c.Cancellation_Deadline_Date__c = (c.StartDate == null ? null : c.StartDate.addDays(-2));*/
		
		if(c.Disable_WaitList_Hours__c == null || c.Disable_WaitList_Hours__c == '')
			c.Disable_WaitList_Hours__c = c.Registration_From_Hours__c;
		if(c.Disable_WaitList_Minutes__c == null || c.Disable_WaitList_Minutes__c == '')
			c.Disable_WaitList_Minutes__c = c.Registration_From_Minutes__c;
		if(c.Disable_WaitList_AM_PM__c == null || c.Disable_WaitList_AM_PM__c == '')
			c.Disable_WaitList_AM_PM__c = c.Registration_From_AM_PM__c;
		if(c.Disable_Wait_List_Date__c == null)
			c.Disable_Wait_List_Date__c = (c.StartDate == null ? null : c.StartDate.addDays(-2));
		
		if(c.Event_Time_Zone__c != null && c.Event_Time_Zone__c != '' && c.Disable_WaitList_Hours__c != null &&  c.Disable_WaitList_Hours__c != '' && c.Disable_WaitList_Minutes__c != null && c.Disable_WaitList_Minutes__c != '' &&  c.Disable_WaitList_AM_PM__c != null &&  c.Disable_WaitList_AM_PM__c != '' && c.Disable_Wait_List_Date__c != null) {
			Integer hour = 0;
			hour += Integer.valueOf(c.Disable_WaitList_Hours__c);
			if(c.Disable_WaitList_Hours__c != '12' && c.Disable_WaitList_AM_PM__c == 'PM')
				hour += 12;
			else if(c.Disable_WaitList_Hours__c == '12' && c.Disable_WaitList_AM_PM__c == 'AM')
				hour = 0;
			DateTime t = DateTime.newInstanceGMT(c.Disable_Wait_List_Date__c, Time.newInstance(hour, Integer.valueOf(c.Disable_WaitList_Minutes__c), 0, 0));
			System.Debug(t);
			String[] parts = c.Event_Time_Zone__c.split(' ');
			String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			String s = t.format('Z', timeZoneMap.get(endpart));
			String sign = s.substring(0, 1);
			String h = s.substring(1, 3);
			String m = s.Substring(3, 5);
			Integer hours = Integer.valueOf(h);
			Integer minutes = Integer.valueOf(m);
			if(sign != '-') {
    			minutes = 0 - minutes;
    			hours = 0 - hours;
			}
			System.debug(hours);
			System.debug(minutes);
			t = t.addHours(hours);
			t = t.addMinutes(minutes);
			c.Disable_Wait_List__c = t;
			System.Debug(t);
			System.Debug(t.format());
		}
		else {
			c.Disable_Wait_List__c = null;
		}
		
		if(c.Event_Time_Zone__c != null && c.Event_Time_Zone__c != '' && c.Cancellation_Deadline_Hours__c != null &&  c.Cancellation_Deadline_Hours__c != '' && c.Cancellation_Deadline_Minutes__c != null && c.Cancellation_Deadline_Minutes__c != '' &&  c.Cancellation_Deadline_AM_PM__c != null &&  c.Cancellation_Deadline_AM_PM__c != '' && c.Cancellation_Deadline_Date__c != null) {
			Integer hour = 0;
			hour += Integer.valueOf(c.Cancellation_Deadline_Hours__c);
			if(c.Cancellation_Deadline_Hours__c != '12' && c.Cancellation_Deadline_AM_PM__c == 'PM')
				hour += 12;
			else if(c.Cancellation_Deadline_Hours__c == '12' && c.Cancellation_Deadline_AM_PM__c == 'AM')
				hour = 0;
			DateTime t = DateTime.newInstanceGMT(c.Cancellation_Deadline_Date__c, Time.newInstance(hour, Integer.valueOf(c.Cancellation_Deadline_Minutes__c), 0, 0));
			System.Debug(t);
			String[] parts = c.Event_Time_Zone__c.split(' ');
			String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			String s = t.format('Z', timeZoneMap.get(endpart));
			String sign = s.substring(0, 1);
			String h = s.substring(1, 3);
			String m = s.Substring(3, 5);
			Integer hours = Integer.valueOf(h);
			Integer minutes = Integer.valueOf(m);
			if(sign != '-') {
    			minutes = 0 - minutes;
    			hours = 0 - hours;
			}
			System.debug(hours);
			System.debug(minutes);
			t = t.addHours(hours);
			t = t.addMinutes(minutes);
			c.Cancellation_Deadline__c = t;
			System.Debug(t);
			System.Debug(t.format());
		}
		else {
			c.Cancellation_Deadline__c = null;
		}
	}      
}

/*trigger EventTimezones on Campaign (before insert, before update) {
	Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getDescribe();
	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	Map<String, String> timezoneMap = new Map<String, String>();
	for( Schema.PicklistEntry f : ple)
	{
		String endpart = '';
		if(!f.getLabel().contains('/')){
			endpart = f.GetLabel().substringAfterLast('(').substringBeforeLast(')');
		}else{
			String[] parts = f.GetLabel().split(' ');
			endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
		}
		// String[] parts = f.GetLabel().split(' ');
    	// String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
		timezoneMap.put(endpart, f.getValue());
		timezoneMap.put(f.getLabel(), f.getValue());
	}
	for(Campaign c : Trigger.new) {
		String endpart = '';
		if(c.Event_Time_Zone__c != null && c.Event_Time_Zone__c != '' && c.Registration_From_AM_PM__c != null && c.Registration_From_AM_PM__c != '' && c.Registration_From_Hours__c != null && c.Registration_From_Hours__c != '' && c.Registration_From_Minutes__c != null && c.Registration_From_Minutes__c != '' && c.Registration_From_Date__c != null) {
			Integer hour = 0;
			hour += Integer.valueOf(c.Registration_From_Hours__c);
			if(c.Registration_From_Hours__c != '12' && c.Registration_From_AM_PM__c == 'PM')
				hour += 12;
			else if(c.Registration_From_Hours__c == '12' && c.Registration_From_AM_PM__c == 'AM')
				hour = 0;
			DateTime t = DateTime.newInstanceGMT(c.Registration_From_Date__c, Time.newInstance(hour, Integer.valueOf(c.Registration_From_Minutes__c), 0, 0));
			System.Debug(t);
			if(!c.Event_Time_Zone__c.contains('/')){
				endpart = c.Event_Time_Zone__c.substringAfterLast('(').substringBeforeLast(')');
			}else{
				String[] parts = c.Event_Time_Zone__c.split(' ');
				endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			}
			system.debug('timeZoneMap: '+timeZoneMap);
			system.debug('timeZoneMap.containsKey: '+timeZoneMap.containsKey(endpart));
			system.debug('endpart: '+endpart);
			// String[] parts = c.Event_Time_Zone__c.split(' ');
			// String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			String s = t.format('Z', timeZoneMap.get(endpart));
			String sign = s.substring(0, 1);
			String h = s.substring(1, 3);
			String m = s.Substring(3, 5);
			Integer hours = Integer.valueOf(h);
			Integer minutes = Integer.valueOf(m);
			if(sign != '-') {
    			minutes = 0 - minutes;
    			hours = 0 - hours;
			}
			System.debug(hours);
			System.debug(minutes);
			t = t.addHours(hours);
			t = t.addMinutes(minutes);
			c.Registration_From__c = t;
			System.Debug(t);
			System.Debug(t.format());
		}
		else {
			c.Registration_From__c = null;
		}
		if(c.Event_Time_Zone__c != null && c.Event_Time_Zone__c != '' && c.Registration_To_AM_PM__c != null && c.Registration_To_AM_PM__c != '' && c.Registration_To_Hours__c != null && c.Registration_To_Hours__c != '' && c.Registration_To_Minutes__c != null && c.Registration_To_Minutes__c != '' && c.Registration_To_Date__c != null) {
			Integer hour = 0;
			hour += Integer.valueOf(c.Registration_To_Hours__c);
			if(c.Registration_To_Hours__c != '12' && c.Registration_To_AM_PM__c == 'PM')
				hour += 12;
			else if(c.Registration_To_Hours__c == '12' && c.Registration_To_AM_PM__c == 'AM')
				hour = 0;
			DateTime t = DateTime.newInstanceGMT(c.Registration_To_Date__c, Time.newInstance(hour, Integer.valueOf(c.Registration_To_Minutes__c), 0, 0));
			System.Debug(t);
			if(!c.Event_Time_Zone__c.contains('/')){
				endpart= c.Event_Time_Zone__c.substringAfterLast('(').substringBeforeLast(')');
			}else{
				String[] parts = c.Event_Time_Zone__c.split(' ');
				endpart= parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			}
			// String[] parts = c.Event_Time_Zone__c.split(' ');
			// String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			String s = t.format('Z', timeZoneMap.get(endpart));
			String sign = s.substring(0, 1);
			String h = s.substring(1, 3);
			String m = s.Substring(3, 5);
			Integer hours = Integer.valueOf(h);
			Integer minutes = Integer.valueOf(m);
			if(sign != '-') {
    			minutes = 0 - minutes;
    			hours = 0 - hours;
			}
			System.debug(hours);
			System.debug(minutes);
			t = t.addHours(hours);
			t = t.addMinutes(minutes);
			c.Registration_To__c = t;
			System.Debug(t);
			System.Debug(t.format());
		}
		else {
			c.Registration_To__c = null;
		}
		if(c.Cancellation_Deadline_Hours__c == null || c.Cancellation_Deadline_Hours__c == '')
			c.Cancellation_Deadline_Hours__c = c.Registration_From_Hours__c;
		if(c.Cancellation_Deadline_Minutes__c == null || c.Cancellation_Deadline_Minutes__c == '')
			c.Cancellation_Deadline_Minutes__c = c.Registration_From_Minutes__c;
		if(c.Cancellation_Deadline_AM_PM__c == null || c.Cancellation_Deadline_AM_PM__c == '')
			c.Cancellation_Deadline_AM_PM__c = c.Registration_From_AM_PM__c;
		/*if(c.Cancellation_Deadline_Date__c == null)
			c.Cancellation_Deadline_Date__c = (c.StartDate == null ? null : c.StartDate.addDays(-2));*
		
		if(c.Disable_WaitList_Hours__c == null || c.Disable_WaitList_Hours__c == '')
			c.Disable_WaitList_Hours__c = c.Registration_From_Hours__c;
		if(c.Disable_WaitList_Minutes__c == null || c.Disable_WaitList_Minutes__c == '')
			c.Disable_WaitList_Minutes__c = c.Registration_From_Minutes__c;
		if(c.Disable_WaitList_AM_PM__c == null || c.Disable_WaitList_AM_PM__c == '')
			c.Disable_WaitList_AM_PM__c = c.Registration_From_AM_PM__c;
		if(c.Disable_Wait_List_Date__c == null)
			c.Disable_Wait_List_Date__c = (c.StartDate == null ? null : c.StartDate.addDays(-2));
		
		if(c.Event_Time_Zone__c != null && c.Event_Time_Zone__c != '' && c.Disable_WaitList_Hours__c != null &&  c.Disable_WaitList_Hours__c != '' && c.Disable_WaitList_Minutes__c != null && c.Disable_WaitList_Minutes__c != '' &&  c.Disable_WaitList_AM_PM__c != null &&  c.Disable_WaitList_AM_PM__c != '' && c.Disable_Wait_List_Date__c != null) {
			Integer hour = 0;
			hour += Integer.valueOf(c.Disable_WaitList_Hours__c);
			if(c.Disable_WaitList_Hours__c != '12' && c.Disable_WaitList_AM_PM__c == 'PM')
				hour += 12;
			else if(c.Disable_WaitList_Hours__c == '12' && c.Disable_WaitList_AM_PM__c == 'AM')
				hour = 0;
			DateTime t = DateTime.newInstanceGMT(c.Disable_Wait_List_Date__c, Time.newInstance(hour, Integer.valueOf(c.Disable_WaitList_Minutes__c), 0, 0));
			System.Debug(t);
			if(!c.Event_Time_Zone__c.contains('/')){
				endpart= c.Event_Time_Zone__c.substringAfterLast('(').substringBeforeLast(')');
			}else{
				String[] parts = c.Event_Time_Zone__c.split(' ');
				endpart= parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			}
			// String[] parts = c.Event_Time_Zone__c.split(' ');
			// String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			String s = t.format('Z', timeZoneMap.get(endpart));
			String sign = s.substring(0, 1);
			String h = s.substring(1, 3);
			String m = s.Substring(3, 5);
			Integer hours = Integer.valueOf(h);
			Integer minutes = Integer.valueOf(m);
			if(sign != '-') {
    			minutes = 0 - minutes;
    			hours = 0 - hours;
			}
			System.debug(hours);
			System.debug(minutes);
			t = t.addHours(hours);
			t = t.addMinutes(minutes);
			c.Disable_Wait_List__c = t;
			System.Debug(t);
			System.Debug(t.format());
		}
		else {
			c.Disable_Wait_List__c = null;
		}
		
		if(c.Event_Time_Zone__c != null && c.Event_Time_Zone__c != '' && c.Cancellation_Deadline_Hours__c != null &&  c.Cancellation_Deadline_Hours__c != '' && c.Cancellation_Deadline_Minutes__c != null && c.Cancellation_Deadline_Minutes__c != '' &&  c.Cancellation_Deadline_AM_PM__c != null &&  c.Cancellation_Deadline_AM_PM__c != '' && c.Cancellation_Deadline_Date__c != null) {
			Integer hour = 0;
			hour += Integer.valueOf(c.Cancellation_Deadline_Hours__c);
			if(c.Cancellation_Deadline_Hours__c != '12' && c.Cancellation_Deadline_AM_PM__c == 'PM')
				hour += 12;
			else if(c.Cancellation_Deadline_Hours__c == '12' && c.Cancellation_Deadline_AM_PM__c == 'AM')
				hour = 0;
			DateTime t = DateTime.newInstanceGMT(c.Cancellation_Deadline_Date__c, Time.newInstance(hour, Integer.valueOf(c.Cancellation_Deadline_Minutes__c), 0, 0));
			System.Debug(t);
			if(!c.Event_Time_Zone__c.contains('/')){
				endpart= c.Event_Time_Zone__c.substringAfterLast('(').substringBeforeLast(')');
			}else{
				String[] parts = c.Event_Time_Zone__c.split(' ');
				endpart= parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			}
			// String[] parts = c.Event_Time_Zone__c.split(' ');
			// String endpart = parts[parts.size() - 1].replaceAll('\\(', '').replaceAll('\\)', '');
			String s = t.format('Z', timeZoneMap.get(endpart));
			String sign = s.substring(0, 1);
			String h = s.substring(1, 3);
			String m = s.Substring(3, 5);
			Integer hours = Integer.valueOf(h);
			Integer minutes = Integer.valueOf(m);
			if(sign != '-') {
    			minutes = 0 - minutes;
    			hours = 0 - hours;
			}
			System.debug(hours);
			System.debug(minutes);
			t = t.addHours(hours);
			t = t.addMinutes(minutes);
			c.Cancellation_Deadline__c = t;
			System.Debug(t);
			System.Debug(t.format());
		}
		else {
			c.Cancellation_Deadline__c = null;
		}
	}      
}*/


/**
 * 
 



 */