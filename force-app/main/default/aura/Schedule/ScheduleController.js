({
	doInit : function(component, event, helper) {
        helper.loadCourses(component, event);
	},
    handleShowModal : function(component, event, helper) {
        helper.handleShowModal(component, event);
    },
    addSessions : function(component, event, helper) {
        helper.addSessions(component, event);
    },
    viewMoodle : function(component, event, helper) {
        helper.viewMoodle(component, event);
    },
    toggle : function(component, event, helper) {
        //alert('toggle');
        $A.util.toggleClass(event.target.parentElement.parentElement, "flipped");
        //$A.util.toggleClass(event.target.parentElement.parentElement.parentElement.parentElement, "flipped");
        //alert('togglehidden');
    },
    toggleback : function(component, event, helper) {
        //alert('toggle');
        $A.util.toggleClass(event.target.parentElement.parentElement.parentElement, "flipped");
        //alert('togglehidden');
    },
    handleShowEdit : function(component, event, helper) {
        helper.handleShowEdit(component, event);
        component.find('childlwc').openModal();
    }
})