public with sharing class LoginAsUserExtension {
	public Contact c {get;set;}
	
    public LoginAsUserExtension(ApexPages.StandardController std) {
    	c = (Contact) std.getRecord();	
    }
    
    public PageReference loginAs() {
    	c.Session_Expiration__c = DateTime.now().addMinutes(30);
    	String hashString = Crypto.getRandomInteger().format().replaceAll(',', '') + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
		Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
		String hexSession = EncodingUtil.convertToHex(hash);
		c.Session_Key__c = hexSession;
		update c;
		Site s = [Select Id from Site where Name='TTS_Portal'];
		SiteDetail sd = [Select Id, SecureUrl from SiteDetail where DurableId = :s.Id];
		return new PageReference(sd.SecureUrl.removeEnd('/') + '/s/mycourses?s=' + c.Session_Key__c + '&u=' + c.User_Id__c);

		//return null;
    }

	public Boolean isSandbox(){
        String host = URL.getSalesforceBaseUrl().getHost();
        String server = host.substring(0,host.indexOf('.'));

        // It's easiest to check for 'my domain' sandboxes first 
        // even though that will be rare
        if(server.contains('--'))
            return true;

        // tapp0 is a unique "non-cs" server so we check it now
        if(server == 'tapp0')
            return true;

        // If server is 'cs' followed by a number it's a sandbox
        if(server.length()>2){
            if(server.substring(0,2)=='cs'){
                try{
                    Integer.valueOf(server.substring(2,server.length()));
                }
                catch(exception e){
                    //started with cs, but not followed by a number
                    return false;
                }

                //cs followed by a number, that's a hit
                return true;
            }
        }

        // If we made it here it's a production box
        return false;
    }
}