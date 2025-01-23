({
	showToast : function(component, event) {
        let vars = {};
        let cancelrefund = false;
        let cancel = false;
        let sess = '';
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
	       function(m,key,value) {
           		vars[key] = value;	
               if(key === "cancel") {
                   cancel = true;
               }
               if(key === "cancelrefund") {
                   cancelrefund = true;
               }
               if(key === "sess") {
                   sess = value;
               }
       	});
        if(cancel || cancelrefund) {
        	var toastEvent = $A.get("e.force:showToast");
    					toastEvent.setParams({
                            "mode":"sticky",
        					"title":"Course Cancelled!",
                            "message": (cancelrefund ? "You have been cancelled from the course. Your refund is being processed." : "You have been cancelled from the course.")
    					});
    					toastEvent.fire();
    	}
        else if(sess !== '') {
            var action = component.get("c.getRegisteredEmails");
            action.setParams({ username : component.get("v.username"),
                              key : component.get("v.key"),
                              sess : sess
                             });
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    if(response.getReturnValue() !== null) {
                        var message = "Thank you for registering, we have sent email confirmation(s) to:\n";
                        message += response.getReturnValue().userEmail;
                        if(response.getReturnValue().cardEmail !== undefined && response.getReturnValue().cardEmail !== null && response.getReturnValue().cardEmail !== '' && response.getReturnValue().cardEmail !== response.getReturnValue().userEmail) {
                            message += ("\n" + response.getReturnValue().cardEmail);
                        }
                        var toastEvent = $A.get("e.force:showToast");
    					toastEvent.setParams({
                            "mode":"sticky",
        					"title":"Successful Registration!",
                            "message": message
    					});
    					toastEvent.fire();
                    }
            	}
        	});
        	$A.enqueueAction(action);
        }
	}
})