({
	handleConfirm : function(component, event, helper) {
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