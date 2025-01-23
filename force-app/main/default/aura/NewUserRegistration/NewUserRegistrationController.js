({
	createUser : function(component, event, helper) {
        helper.createUserWithCheck(component, event);
	},
    checkPassword : function(component, event, helper) {
        helper.checkPassword(component, event);
    },
    checkEmail: function(component, event, helper) {
        helper.checkEmail(component, event);
    },
    stepTwo: function(component, event, helper) { 
        helper.stepTwo(component, event);   
    },
    
    pageOneKeyCheck: function(component, event, helper) {
        if(event.keyCode === 13) {
            event.preventDefault();
            helper.stepTwo(component, event);
        }
	},
    pageTwoKeyCheck: function(component, event, helper) {
        if(event.keyCode === 13) {
            event.preventDefault();
            helper.createUserWithCheck(component, event);
        }
	},
    getParams : function(component, event, helper) {
        helper.getParams(component, event);
    }
})