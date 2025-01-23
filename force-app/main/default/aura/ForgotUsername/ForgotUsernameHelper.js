({
	forgotClick : function(component, event) {
		var action = component.get("c.forgotUsername");
        action.setParams({ email : component.get("v.email")});
        action.setCallback(this, function(response) {
	        var state = response.getState();
            if (state === "SUCCESS") {
				component.set("v.message", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.message", errors[0].message);
                    }
                } else {
                    component.set("v.message", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})