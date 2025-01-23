public with sharing class IdentityProviderPostController {
	public Map<String, String> paramMap {get;set;}
	public String[] paramKeys {get;set;}
	private String relayState {get;set;}
	private String samlRequest {get;set;}
	public Boolean error {get;set;}
	public String errorString {get;set;}
	
	public IdentityProviderPostController() {
		error = false;
		if(ApexPages.currentPage().getParameters().containsKey('RelayState')) {
			relayState = ApexPages.currentPage().getParameters().get('RelayState');
			if(ApexPages.currentPage().getParameters().containsKey('RelayState')) {
				if(ApexPages.currentPage().getParameters().containsKey('SAMLRequest')) {
					samlRequest = ApexPages.currentPage().getParameters().get('SAMLRequest');
				}
				else {
					errorString = 'Missing SAMLRequest Value';
					error = true;
				}
			}
		}
		else {
			errorString = 'Missing RelayState Value';
			error = true;
		}
		paramMap = new Map<String, String>();
		paramKeys = new String[0];
		
		for(String s : ApexPages.currentPage().getParameters().keySet()) {
			paramMap.put(s, ApexPages.currentPage().getParameters().get(s));
			paramKeys.add(s);
			if(s == 'RelayState') {
				relayState = ApexPages.currentPage().getParameters().get(s);
			}
		}
	}
    
    public PageReference checkProvider() {
    	if(!error) {
    		SuperSAML.SAMLStatus status = SuperSAML.checkAuthRequest(samlRequest);
    		if(status.requestValid) {
    			return new PageReference('/s/sso?relayState=' + EncodingUtil.urlEncode(relayState, 'UTF-8') + '&assertionid=' + EncodingUtil.urlEncode(status.assertionId, 'UTF-8'));
    		}
    		else {
    			errorString = status.errorMessage;
    			error = true;
    		}
    	}
    	return null;
    }
}