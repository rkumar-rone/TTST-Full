({
	loadCampaign : function(component, event) {
		var action = component.get("c.getDeadlineInfo");
            action.setParams({ username : component.get("v.username"),
                              key : component.get("v.key"),
                              campaignMemberId : component.get("v.campaignMemberId")});
                              console.log('campaignMemberId: ', component.get("v.courseName"));
	        action.setCallback(this, function(response) {
		        var state = response.getState();
        	    if (state === "SUCCESS") {
                    let respval = response.getReturnValue();
                    if(respval !== null) {
                        let d = new Date(respval.Campaign.Cancellation_Deadline__c);
                        if(d > new Date()) {
                            component.set("v.beforedeadline", true);
                            component.set("v.waitlist", respval.Attendee_Status__c === 'Waiting List');
                        }
                        else {
                            component.set("v.afterdeadline", true);
                            component.set("v.policy", respval.Campaign.Cancellation_Policy__c);
							component.set("v.deadlinedate", respval.Campaign.Cancellation_Deadline_Date__c);
                            component.set("v.deadlinehour", respval.Campaign.Cancellation_Deadline_Hours__c);
    						component.set("v.deadlineminutes", respval.Campaign.Cancellation_Deadline_Minutes__c);
                            component.set("v.deadlineampm", respval.Campaign.Cancellation_Deadline_AM_PM__c);
                            component.set("v.waitlist", respval.Attendee_Status__c === 'Waiting List');
                        }
                    }
            	}
        	});
        	$A.enqueueAction(action);
	},
    handleClose : function(component, event) {
        let check = component.get("v.checked");
        let deadline = component.get("v.beforedeadline");
        console.log('Component afterdeadline: ', check || deadline);
        if(event.getParam("cancel")) {
            component.find("overlayLib").notifyClose();
        } else {            
            if(check || deadline) {
                // var cmId = component.get("v.campaignMemberId");
        		// var urlEvent = $A.get("e.force:navigateToURL");
    			// urlEvent.setParams({
      			// 	"url": "/cancelcourse?id=" + cmId
    			// });
    			// urlEvent.fire();
                var action = component.get("c.cancelCourseProcess");
                action.setParams({campaignMemberId : component.get("v.campaignMemberId"), courseName : component.get("v.courseName")});
	            action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log(state);
                    console.log('did we hit cancel code?');
                    if (state === "SUCCESS") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The course has been cancelled successfully.",
                            "type": "success"
                        });
                        toastEvent.fire();
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "The course could not be cancelled.",
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                    window.location.reload();
                    // component.find("overlayLib").notifyClose();
                //     let respval = response.getReturnValue();
                //     if(respval !== null) {
                //         if(respval === "Success") {
                //             var urlEvent = $A.get("e.force:navigateToURL");
                //             urlEvent.setParams({
                //                 "url": "/s/mycourses?cancel=true"
                //             });
                //             urlEvent.fire();
                //         }
                //         if(respval === "Success - Refund") {
                //             var urlEvent = $A.get("e.force:navigateToURL");
                //             urlEvent.setParams({
                //                 "url": "/s/mycourses?cancelrefund=true"
                //             });
                //             urlEvent.fire();
                //         }
                //         else {
                //             component.set("v.errormessage", respval);    
                //         }
                //     }
                //     else {
                //         component.set("v.errormessage", "Error Cancelling the Course.");
                        
                //     }
                // }
                // else if (state === "INCOMPLETE") {}
                // else if (state === "ERROR") {
                //     var errors = response.getError();
                //     if (errors) {
                //         if (errors[0] && errors[0].message) {
                //         component.set("v.errormessage", errors[0].message);
                //     }
                //     } else {
                //         component.set("v.errormessage", "Unknown error");
                //     }
                // }
                });

                $A.enqueueAction(action);
                // component.find("overlayLib").notifyClose();
                // window.location.reload();
            }
            else {
                component.set("v.error", "You must acknowledge the cancellation policy before cancelling.");
            }
        }
    }
})