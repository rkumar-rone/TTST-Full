({
	loginClick : function(component, event, helper) {
		helper.clearLoginClick(component, event);
	},
    checkKey : function(component, event, helper) {
        if(event.keyCode === 13) {
            event.preventDefault();
            helper.clearLoginClick(component, event);
        }
    },
    getParams : function(component, event, helper) {
        helper.getParams(component, event);
    }
})