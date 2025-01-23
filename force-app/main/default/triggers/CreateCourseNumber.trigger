trigger CreateCourseNumber on Campaign (before insert) {
	
	for(Campaign c:Trigger.new)
	{
		c.Class_Code__c=RandomStringUtils.randomUUID().substring(0, 6).toUpperCase();
		
	}

}