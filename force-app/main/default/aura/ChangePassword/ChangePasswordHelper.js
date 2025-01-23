({
	cancel: function(component, event) {
		component.find("overlayLib").notifyClose();
	},
    changePasswordButton : function(component, event) {
        component.set("v.error", '');
		var oldpass = component.get("v.oldpassword");
        var pass = component.get("v.password");
        var conf = component.get("v.confirmpassword");
        if(pass !== conf) {
            component.set("v.error", "The password and confirmation do not match.");
            return;
        }
	    var action = component.get("c.changePassword");
        	action.setParams({ username : component.get("v.user"),
                              key : component.get("v.key"),
                              password : pass,
                              confirm : conf, 
							  oldPassword: oldpass });
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    if(response.getReturnValue() === 'Success') {
                    	var toastEvent = $A.get("e.force:showToast");
    					toastEvent.setParams({
                            "mode": 'sticky',
        					"title":"Password Changed!",
        					"message": "Your password was changed successfully."
    					});
    					toastEvent.fire();
                        component.find("overlayLib").notifyClose();
                    }
                    else if(response.getReturnValue().endsWith('- Redirect')) {
						var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
	       	                    "isredirect": true,
	                            "url": '/'
		                    });
		                    urlEvent.fire();
                    }
					else {
						component.set("v.error", response.getReturnValue());
					}
            	}
            	else if (state === "INCOMPLETE") {
            	}
            	else if (state === "ERROR") {
            	}
        	});
        	$A.enqueueAction(action);
    }
})