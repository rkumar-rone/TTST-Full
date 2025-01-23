({
	searchCourses : function(component, event) {
		 var action = component.get("c.searchCourses");
        action.setParams({ username : component.get("v.username"),
                          key : component.get("v.key"),
                          coursecode : component.get("v.coursecode")});
        action.setCallback(this, function(response) {
	        var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue().startsWith('Success')) {
                	var parts = response.getReturnValue().split(' - ');
                     var urlEvent = $A.get("e.force:navigateToURL");
					 urlEvent.setParams({
                         "isredirect": true,
                         "url": "/view-event?id=" + parts[1]
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
	}
})