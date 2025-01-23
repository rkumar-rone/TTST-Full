({
    hoverWait : function(component, event, helper) {
        helper.hoverWait(component, event);
    },
    clickWait : function(component, event, helper) {
        helper.clickWait(component, event);
    },
    hoverOutWait : function(component, event, helper) {
        helper.hoverOutWait(component, event);
    },
    changeColor : function(component, event, helper) {
        helper.changeColor(component, event);
    },
    toggleAccordion : function (component, event, helper) {
		helper.toggleAccordion(component, event);
    },
	doInit : function(component, event, helper) {
        helper.loadYears(component, event);
		helper.getCourse(component, event);
        helper.loadCourse(component, event);
        helper.populateInfo(component, event);
	},
    selectFull : function(component, event, helper) {
        var checked = event.getSource().get("v.checked");
        var sessions = component.find("sess");
        if(Array.isArray(sessions)) {
            for(let i = 0; i < sessions.length; i++) {
                sessions[i].set("v.checked", checked);
            }
        }
        else if(sessions !== undefined) {
            sessions.set("v.checked", checked);
        }
        helper.changeTotal(component, event, false);
        component.set("v.confirmwaitlist", false);
    },
    selectSession : function(component, event, helper) {
        component.set("v.confirmwaitlist", false);
        let sid = event.getParam("sessionid");
        let course = component.get("v.course");
        let checked = event.getParam("checked");
        var sessions = component.find("sess");
        if(course.c.Only_Show_Sessions__c && checked) {
            if(Array.isArray(sessions)) {
            	for(let i = 0; i < sessions.length; i++) {
                    if(sessions[i].get("v.id") !== sid)  {
                        sessions[i].set("v.checked", false);
	                }
            	}
            }
        }
        let required = false;
        let requiredchecked = false;
        if(Array.isArray(sessions)) {
          	for(let i = 0; i < sessions.length; i++) {
                if(sessions[i].get("v.id") === sid && sessions[i].get("v.required"))  {
                    required = true;
                    requiredchecked = sessions[i].get("v.checked");
	            }
         	}
        }
        if(required) {
          	for(let i = 0; i < sessions.length; i++) {
                if(sessions[i].get("v.required"))  {
                    sessions[i].set("v.checked", requiredchecked);
	            }
         	}
        }
        var allChecked = true;
        if(Array.isArray(sessions)) {
            for(let i = 0; i < sessions.length; i++) {
                if(!sessions[i].get("v.checked")) {
                    allChecked = false;
                }
            }
        }
        else {
            allChecked = sessions.get("v.checked");
        }
        component.set("v.fullcourse", allChecked);
        helper.changeTotal(component, event, false);
    },
    getTotalCoupon : function(component, event, helper) {
        helper.changeTotal(component, event, true);
    },
    registerClick : function(component, event, helper) {
		helper.register(component, event);
	},
    cancel : function(component, event, helper) {
        helper.cancel(component, event);
    },
    checkKeyPressCoupon : function(component, event, helper) {
        if(event.keyCode === 13) {
            event.preventDefault();
            helper.changeTotal(component, event, true);
        }
    },
    checkKeyPress : function(component, event, helper) {
        if(event.keyCode === 13) {
            event.preventDefault();
            helper.register(component, event);
        }
    },
    changeCheck : function(component, event, helper) {
        if(event.getSource().get("v.checked") === true) {
            helper.populateInfo(component, event);
        }
        else {
            helper.clearInfo(component, event);
        }
    },
    handleWaitlist : function(component, event, helper) {
        component.set("v.confirmwaitlist", true);
        helper.register(component, event);
    },
    changeTerms : function(component, event, helper) {
        if(event.target.checked=== true) {
            component.set("v.affirm", true);
        }
        else {
            component.set("v.affirm", false);
        }
    }
    
})