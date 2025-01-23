({
	resetClick : function(component, event, helper) {
        helper.resetClick(component, event);
	},
    checkKey : function(component, event, helper) {
        if(event.keyCode === 13) {
            event.preventDefault();
            helper.resetClick(component, event);
        }
    }
})