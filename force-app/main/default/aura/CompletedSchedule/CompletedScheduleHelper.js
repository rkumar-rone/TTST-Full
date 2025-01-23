({
	loadCourses : function(component, event) {
            var action = component.get("c.loadPastSchedule");
            action.setParams({ username : component.get("v.username"),
                              key : component.get("v.key")});
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    let respval = response.getReturnValue();
                    if(respval !== null) {
                        if(respval.success) {
                        	component.set("v.courses", respval.scheds);
                        }
                        else {
                        	component.set("v.errormessage", respval.error);    
                        }
                    }
                    else {
                        component.set("v.errormessage", "Error Loading the Schedule.");
                        
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
    viewMoodle : function(component, event) {
         var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
        	"isredirect": true,
            "url": event.getSource().get("v.value")
		});
	    urlEvent.fire();
    }
})