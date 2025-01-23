({
	checkURL : function(component, event) {
        var vars = {};
        var passwordKey = '';
        var user = '';
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
	       function(m,key,value) {
           		vars[key] = value;	
               if(key === "key") {
                   passwordKey = decodeURIComponent(value).replace(/\+/g, ' ');
               }
               else if(key === "user") {
                   user = decodeURIComponent(value).replace(/\+/g, ' ');
               }
       });
        if(user !== undefined && user !== null && user !== '' && passwordKey !== undefined && passwordKey !== null && passwordKey !== '') {
            var action = component.get("c.checkUserKey");
        	action.setParams({ username : user,
                              key : passwordKey});
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    if(response.getReturnValue() == 'Success') {
                        component.set("v.username", user);
                        component.set("v.key", passwordKey);
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
        }
        else {
            component.set("v.errormessage", "The reset URL is invalid or has expired.");
        }
	},
     checkPassword : function(component, event) {
        var passconfirm = component.find('passwordconfirm');
        passconfirm.set('v.validity', {valid : true});
        var passval = component.get('v.password');
        var passconfirmval = component.get('v.passwordconfirm');
      	if(passval !== null && passval !== '' && passval === passconfirmval) {
            return true;
        }
        passconfirm.set('v.validity', {valid : false, badInput: true});
        passconfirm.showHelpMessageIfInalid();
        return false;
     },
    resetPassword : function(component, event) {
    	var action = component.get("c.resetPassword");
        action.setParams({ username : component.get('v.username'),
                           key : component.get('v.key'),
                          password : component.get('v.password'),
                          confirm : component.get('v.passwordconfirm')});
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
	                         "url": "/mycourses"
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
    checkAndSetPassword : function(component, event) {
    	if(this.checkPassword(component, event)) {
            this.resetPassword(component, event);
        }
	}
})