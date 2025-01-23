({
	cancelCourse : function(component, event) {
        var vars = {};
        var cmid = '';
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
	       function(m,key,value) {
           		vars[key] = value;	
               if(key === "id") {
                   cmid = value;
               }
       });
       component.set("v.campaignmemberid", cmid);
        this.cancelCourseServer(component, event);
    },
    cancelCourseServer : function(component, event) {
         var action = component.get("c.cancelCourseProcess");
            action.setParams({ username : component.get("v.username"),
                              key : component.get("v.key"),
                              campaignMemberId : component.get("v.campaignmemberid")});
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    let respval = response.getReturnValue();
                    if(respval !== null) {
                        if(respval === "Success") {
					        var urlEvent = $A.get("e.force:navigateToURL");
    						urlEvent.setParams({
      							"url": "/s/mycourses?cancel=true"
                            });
    						urlEvent.fire();
                        }
                        if(respval === "Success - Refund") {
					        var urlEvent = $A.get("e.force:navigateToURL");
    						urlEvent.setParams({
      							"url": "/s/mycourses?cancelrefund=true"
                            });
    						urlEvent.fire();
                        }
                        else {
                        	component.set("v.errormessage", respval);    
                        }
                    }
                    else {
                        component.set("v.errormessage", "Error Cancelling the Course.");
                        
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
})