({
	submitsso : function(component, event) {
		var action = component.get("c.samlAssertion");
        var urlparams = this.getUrlVars();
        action.setParams({ username : component.get("v.username"),
                          key : component.get("v.key"),
                          assertionId : urlparams["assertionid"]});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("samlresponse").getElement().value = response.getReturnValue().assertion;
                var urlparams = this.getUrlVars();
        		var ssoform = component.find("ssoform");
                var formelement = ssoform.getElement();
                if("relaystate" in urlparams) {
                	formelement.action = response.getReturnValue().destination;// + '?RelayState=' + urlparams["relaystate"];
                    var relaystate = component.find("relaystate");
                    var relaystateelement = relaystate.getElement();
                    relaystateelement.value = decodeURIComponent(urlparams["relaystate"]);
                }
        		formelement.submit();
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       component.set("v.errormessage", errors[0].message);
                    }
                } else {
                    component.set("v.errormessage", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    getUrlVars : function() {
    	var vars = {};
    	var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        	vars[key.toLowerCase()] = value;
    	});
    	return vars;
	}
})