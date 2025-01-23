({
	doInit : function(component, event, helper) {
		helper.checkURL(component, event);
	},
    checkPassword : function(component, event, helper) {
        helper.checkPassword(component, event);
    },
    resetClick : function(component, event, helper) {
        helper.checkAndSetPassword(component, event);
    },
    keyCheck : function(component, event, helper) {
        if(event.keyCode === 13) {
            event.preventDefault();
            helper.checkAndSetPassword(component, event);
        }
    }
})