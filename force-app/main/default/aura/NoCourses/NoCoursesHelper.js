({
    loadCourses : function(component, event) {
        var action = component.get("c.loadSchedule");
        action.setParams({ username : component.get("v.username"),
                          key : component.get("v.key"),
                          courseType : 'Active and Inactive',
                          courseStudyType : 'All Course Types'});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let respval = response.getReturnValue();
                if(respval !== null) {
                    if(respval.success) {
                        if(respval.scheds == null || respval.scheds.length === 0) {
                            component.set("v.noCourses", true);
                        }
                    }
                    else {
                    }
                }
                else {
                    
                }
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                }
                } else {
                }
            }
        });
        $A.enqueueAction(action);
    }
})