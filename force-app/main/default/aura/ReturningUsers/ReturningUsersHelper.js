({
	loginClick : function(component, event) {
        var action = component.get("c.login");
        action.setParams({ username : component.get("v.username"),
                          password : component.get("v.password")});
        action.setCallback(this, function(response) {
	        var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue().startsWith('Success')) {
               		var parts = response.getReturnValue().split(' - ');
                   	document.cookie='user=' + parts[2] + ';secure';
                   	document.cookie='skey=' + parts[1] + ';secure';
                   	var urlEvent = $A.get("e.force:navigateToURL");
				 	urlEvent.setParams({
	                	"isredirect": true,
	                    "url": component.get("v.origURL")
					});
				    urlEvent.fire();
                }
                else {
					component.set("v.errormessage", response.getReturnValue());
	            }
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
    clearLoginClick : function(component, event) {
		component.set("v.errormessage", null);
        this.loginClick(component, event);        
    },
    getParams : function(component, event) {
        var vars = {};
        var url = component.get("v.origURL");
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
	       function(m,key,value) {
           		vars[key] = value;	
               if(key === "origURL") {
                   url = decodeURIComponent(value);
               }
       });
       component.set("v.origURL", url);
    }
})