({
	doInit : function(component, event, helper) {
		helper.loadCampaign(component, event);
	},
    handleClose: function(component, event, helper) {
        helper.handleClose(component, event);
    }
})