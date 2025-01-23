({
	searchClick : function(component, event, helper) {
		helper.searchCourses(component, event);
	},
    changeNumber : function(component, event, helper) {
        var ccode = component.get("v.coursecode");
        if(ccode.length >= 6) {
            ccode = ccode.substring(0, 6);
            component.set("v.coursecode", ccode);
            event.preventDefault();
        }
        if(event.keyCode == 13) {
            event.preventDefault();
            helper.searchCourses(component, event);
        }
    }
})