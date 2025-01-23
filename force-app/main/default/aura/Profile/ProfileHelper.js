({
	loadProfile : function(component, event) {
	    var action = component.get("c.loadProfile");
        this.getParams(component, event);
        action.setParams({ username : component.get("v.username"),
                          key : component.get("v.key")});
        action.setCallback(this, function(response) {
			var state = response.getState();
        	if (state === "SUCCESS") {
                if(response.getReturnValue() !== null) {
                    component.set("v.firstname", response.getReturnValue().firstName);
                    component.set("v.lastname", response.getReturnValue().lastName);
                    component.set("v.email", response.getReturnValue().email);
                    component.set("v.emailconfirm", response.getReturnValue().email);
                    component.set("v.secondaryemail", response.getReturnValue().secondary);
                    component.set("v.secondaryemailconfirm", response.getReturnValue().secondary);
                    component.set("v.phone", response.getReturnValue().phone);
                    component.set("v.company", response.getReturnValue().company);
                    component.set("v.country", response.getReturnValue().country);
                    component.set("v.street", response.getReturnValue().street);
                    component.set("v.city", response.getReturnValue().city);
                    component.set("v.state", response.getReturnValue().state);
                    component.set("v.postalcode", response.getReturnValue().postalcode);
                    component.set("v.receiveemails", response.getReturnValue().receive);
                    component.set("v.userId", response.getReturnValue().userId);
                    //this.checkEmail(component, event);
                    //this.checkSecondaryEmail(component, event);
                }
                else {
                    component.set("v.errormessage", "Error Loading the Profile.");
                    
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
    validateProfile : function(component, event) {
        var validProfile = component.find('regform').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        return validProfile;
	},
    toggleEdit : function(component, event) {
        component.set("v.editing", !component.get("v.editing"));
    },
    saveProfile : function(component, event) {
        var action = component.get("c.saveProfile");
        action.setParams({ username : component.get("v.username"),
                          key : component.get("v.key"),
                          firstname : component.get("v.firstname"),
                          lastname : component.get("v.lastname"),
                          email : component.get("v.email"),
                          secondaryemail : component.get("v.secondaryemail"),
                          phone : component.get("v.phone"),
                          company : component.get("v.company"),
                          country : component.get("v.country"),
                          receiveemails : (component.get("v.receiveemails") === undefined ? false : component.get("v.receiveemails")),
                          street : component.get("v.street"),
                          city : component.get("v.city"),
                          state : component.get("v.state"),
                          postalcode : component.get("v.postalcode")});
		
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               if(response.getReturnValue() === 'Success') {
               		var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
                            "mode":"sticky",
					        "title": "Profile Updated",
					        "message": "Your profile has been successfully updated."
					    });
					    toastEvent.fire();
                   		this.loadProfile(component, event);
                   		//this.toggleEdit(component, event);
                        component.set("v.changed", false);
                        var origURL = component.get("v.origURL");
                        if(origURL !== undefined && origURL !== null && origURL != '') {
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
	       	                    "isredirect": true,
	                            "url": origURL
		                    });
		                    urlEvent.fire();
                        }
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
						component.set("v.errormessage",errors[0].message);
                    }
                } else {
                    component.set("v.errormessage","Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
     checkEmail : function(component, event) {
        var emailconfirm = component.find('regformemailconfirm');
        emailconfirm.setCustomValidity(""); 
        emailconfirm.showHelpMessageIfInvalid();
        var emailval = component.get('v.email');
        var emailconfirmval = component.get('v.emailconfirm');
      	if(emailval !== null && emailval !== '' && emailval === emailconfirmval) {
            return true;
        }
	    //pass.set('v.validity', {valid : false, badInput: true});
        emailconfirm.setCustomValidity("Email and Confirmation must match.");
        //pass.showHelpMessageIfInvalid();
        emailconfirm.showHelpMessageIfInvalid();
        return false;
    },

    checkSecondaryEmail : function(component, event) {
        var secondaryemailconfirm = component.find('secondaryemailconfirm');
        secondaryemailconfirm.setCustomValidity(""); 
        secondaryemailconfirm.showHelpMessageIfInvalid();
        var secondaryemailval = component.get('v.secondaryemail');
        var secondaryemailconfirmval = component.get('v.secondaryemailconfirm');
      	if(secondaryemailval !== null && secondaryemailval !== '' && secondaryemailval === secondaryemailconfirmval) {
            return true;
        }
	    //pass.set('v.validity', {valid : false, badInput: true});
        secondaryemailconfirm.setCustomValidity("Secondary Email and Confirmation must match.");
        //pass.showHelpMessageIfInvalid();
        secondaryemailconfirm.showHelpMessageIfInvalid();
        return false;
    },
    changePassword : function (component, event) {
        var modalBody;
        var modalFooter;
        $A.createComponents([["c:ChangePassword", {user : component.get("v.username"),
                          key : component.get("v.key")}]],
           function(components, status) {
               if (status === "SUCCESS") {
                   modalBody = Array.isArray(components) ? components[0] : components;
                   component.find('overlayLib').showCustomModal({
                       header: "Change Password",
                       body: modalBody, 
                       showCloseButton: false,
                       closeCallback: function() {
                       }
                   })
               }                               
           });
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