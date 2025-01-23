({
	handleLoggedInEvent : function(component, event, helper) {
		component.set("v.username", event.getParam("username"));
        component.set("v.key", event.getParam("key"));
        component.set("v.loggedIn", true);
	}
})