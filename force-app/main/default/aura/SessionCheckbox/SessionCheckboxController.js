({
	check : function(component, event, helper) {
		var cmpEvent = component.getEvent("sessionSelected");
        cmpEvent.setParams({"sessionid":component.get("v.id"), "checked": component.get("v.checked")});
        cmpEvent.fire();
	}
})