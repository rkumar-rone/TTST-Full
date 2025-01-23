({
	doInit : function(component, event, helper) {
		helper.showConfirm(component, event);
	},
	goToMyCourses : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
		  "url": "/mycourses"
		});
		urlEvent.fire();
	}
})