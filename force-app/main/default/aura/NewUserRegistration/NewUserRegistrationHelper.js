({
    createUser : function(component, event) {
        
        var action = component.get("c.registerUser");
        action.setParams({ username : component.get("v.username"),
                          password : component.get("v.password"),
                          confirm : component.get("v.passwordconfirm"),
                          firstname : component.get("v.firstname"),
                          lastname : component.get("v.lastname"),
                          email : component.get("v.email"),
                          secondaryemail : component.get("v.secondaryemail"),
                          phone : component.get("v.phone"),
                          company : component.get("v.company"),
                          hear : (component.get("v.hear") === "Other" ? component.get("v.hearother") : component.get("v.hear")),
                          receiveemails : (component.get("v.receiveemails") === undefined ? false : component.get("v.receiveemails")),
                          country : component.get("v.country")});
		
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
                    event.getSource().set("v.disabled",false);
					component.set("v.errormessage", response.getReturnValue());
                    if(response.getReturnValue() === 'Username already exists.' || response.getReturnValue() === 'This username is not available as it’s in use on a TTS legacy system. Please choose another.' || response.getReturnValue() == 'The password must be at least eight characters consisting of at least one uppercase, one lowercase, and one number.') {
                        component.set("v.pageone", true);
                    }
	            }
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
						component.set("v.errormessage",errors[0].message);
                    }
                } else {
                    component.set("v.errormessage","Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
	validateRegistration : function(component, event) {
        var validUser = component.find('regform').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(validUser) {
            if(component.find("agreeTerms").getElement().checked) {
                return true;
            }
            component.set("v.errormessage", "You must agree to the Privacy Policy and Terms of Use to continue.");
            //if(this.checkPassword(component, event) && this.checkEmail(component, event)) {
                
            //}
        }
        return false;
	},
    checkEmail : function(component, event) {
        var emailconfirm = component.find('regformemailconfirm');
        emailconfirm.setCustomValidity(""); 
        var emailval = component.get('v.email');
        var emailconfirmval = component.get('v.secondaryemail');
      	if(emailval !== null && emailval !== '' && emailval === emailconfirmval) {
            return true;
        }
	    //pass.set('v.validity', {valid : false, badInput: true});
        emailconfirm.setCustomValidity("Email and Confirmation must match.");
        //pass.showHelpMessageIfInvalid();
        emailconfirm.showHelpMessageIfInvalid();
        return false;
    },
    checkPassword : function(component, event) {
        //var pass = component.find('regformpass');
        var passconfirm = component.find('regformpassconfirm');
        //pass.set('v.validity', {valid : true});
        passconfirm.setCustomValidity("");
        var passval = component.get('v.password');
        var passconfirmval = component.get('v.passwordconfirm');
      	if(passval !== null && passval !== '' && passval === passconfirmval) {
            return true;
        }
	    //pass.set('v.validity', {valid : false, badInput: true});
        passconfirm.setCustomValidity("Password and Confirmation must match.");
        //pass.showHelpMessageIfInvalid();
        passconfirm.showHelpMessageIfInvalid();
        return false;
    },
  	setStepTwo : function(component, event) {
        component.set("v.pageone", false);
    },
    stepTwo : function(component, event) {
        component.find('regformuser').showHelpMessageIfInvalid();
        component.find('regformpass').showHelpMessageIfInvalid();
        component.find('regformpassconfirm').showHelpMessageIfInvalid();
        if(this.checkPassword(component, event) && component.find('regformuser').checkValidity() && component.find('regformpassconfirm').checkValidity()) {
			this.setStepTwo(component, event);
        }   
    },
    createUserWithCheck : function(component, event) {
        event.getSource().set("v.disabled", true);
        component.set("v.errormessage", null);
		var valid = this.validateRegistration(component, event);
        // If we pass error checking, do some real work
        if(valid){
            this.createUser(component, event);
        }
        else {
            event.getSource().set("v.disabled", false);
        }
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