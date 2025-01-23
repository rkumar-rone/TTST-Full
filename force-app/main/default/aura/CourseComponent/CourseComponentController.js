({
    loggedIn : function(component, event, helper) {
        component.set("v.username", event.getParam("username"));
        component.set("v.key", event.getParam("key"));
    	component.set("v.loggedin", true);
        helper.loadCourse(component, event);
    },
	doInit : function(component, event, helper) {
        helper.getCourse(component, event);
		helper.loadCourse(component, event);
	},
    register: function(component, event, helper) {
    	helper.register(component, event);
    },
    logIn: function(component, event, helper) {
        helper.logIn(component, event);
    }
})