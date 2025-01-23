({
    setNav : function(component, event, helper) {
		helper.setNav(component, event);
	},
	handleSelect : function(component, event, helper) {
        let value = event.getParam("value");
        if(value != 'sso') {
			//let urlEvent = $A.get("e.force:navigateToURL");
        	window.location.href = '/s/' + value;
        //urlEvent.setParams({ "url" : })
        	//urlEvent.fire();
		}
		else {
        	window.open(value);
        }
                               
	}
})