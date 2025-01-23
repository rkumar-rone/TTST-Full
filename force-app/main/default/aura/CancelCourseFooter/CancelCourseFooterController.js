({
    handleConfirm : function(component, event, helper) {
        component.set("v.isButtonDisabled", true);
        component.set("v.showSpinner", true);
        var closeEvent = $A.get("e.c:CloseModal");
        closeEvent.setParams({"cancel":false});
        closeEvent.fire();
	},
    handleCancel : function(component, event, helper) {
        var closeEvent = $A.get("e.c:CloseModal");
        closeEvent.setParams({"cancel":true});
        closeEvent.fire();
	}
})