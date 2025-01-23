({
    handleClose : function(component, event) {
        if(event.getParam("cancel")) {
            component.find("overlayLib").notifyClose();
        }
        else {
            var check = component.get("v.checked");
            if(check) {
                var closeEvent = $A.get("e.c:RegisterWaitlistConfirm");
                closeEvent.fire();
                component.find("overlayLib").notifyClose();
            }
            else {
                component.set("v.error", "You must acknowledge the waitlist policy before registering.");
            }
        }
    }
})