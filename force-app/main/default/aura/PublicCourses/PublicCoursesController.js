({
	loggedIn : function(component, event, helper) {
		component.set("v.loggedin", true);
	},
    doInit : function(component, event, helper) {
        helper.loadIsSandbox(component, event);
        helper.loadChoices(component, event);  
        helper.loadDefaults(component, event);
        helper.loadCourses(component, event);
    },
    loadCourses : function(component, event, helper) {
        helper.loadCourses(component, event);
        helper.loadIsSandbox(component, event);
    }
})