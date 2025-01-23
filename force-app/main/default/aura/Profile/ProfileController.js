({
	doInit : function(component, event, helper) {
		helper.loadProfile(component, event);
	},
    editUser : function(component, event, helper) {
        helper.toggleEdit(component, event);
	},
    saveUser : function(component, event, helper) {
        if(helper.validateProfile(component, event)) {
        	helper.saveProfile(component, event);
        }
	},
    cancelUser : function(component, event, helper) {
		helper.loadProfile(component, event);
        //helper.toggleEdit(component, event);
	},
    changePassword : function(component, event, helper) {
        helper.changePassword(component, event);
    },
    checkEmail: function(component, event, helper) {
        helper.checkEmail(component, event);
    },
    checkSecondaryEmail: function(component, event, helper) {
        helper.checkSecondaryEmail(component, event);
    },
    changeitem : function(component, event, helper) {
        component.set("v.changed", true);
    },
    finishUpload : function(component, event, helper) {
        
    }
    
})