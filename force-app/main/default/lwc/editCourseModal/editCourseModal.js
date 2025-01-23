import { LightningElement, api, track, wire } from 'lwc';
import getSessions from '@salesforce/apex/B2BGetInfo.getSessions';
import saveOneSelection from '@salesforce/apex/B2BGetInfo.saveOneSelection';

export default class EditCourseModal extends LightningElement {
    @api isOneCourse;
    @api recordId;
    @api registration;
    registrationId;
    @track showModal = false;
    @api openedOneTime =false;
    eventSessions = [];
    currentSession
    
    @api
    openModal() {
        if(this.openedOneTime == false) {
        this.showModal = true;
        this.openedOneTime = true;
        this.loadSelections();
        }
    }

    closeModal() {
        this.showModal = false;
        setInterval(() => {
            this.openedOneTime = false;
        }, 2000);
    }
    
        /**
     * Gets the normalized, displayable product information for use by the display components.
     *
     * @readonly
     */
        get displayableProduct() {
            return {
        sessions: this.eventSessions,

    };
}
/**
     * The Event session records returned
     *
     * @type Sessions__c
     * @private
     */
@wire(getSessions, {
    productId: '$recordId'
})
wiredEventSessions({ error, data }){
    if (data) {
        let sessions = [];

        let allRequired = true;
        for (let index = 0; index < data.length; index++) {
            let currentSession = {...data[index]};
            if(currentSession.Required__c == false) {
                allRequired = false;
            }
        }

        for (let index = 0; index < data.length; index++) {
            let currentSession = {...data[index]};
            let previousSession = {...sessions[index-1]};

            let startTime = `${currentSession.sessionStartDate} ${currentSession.Start_Hours__c}:${currentSession.Start_Minutes__c} ${currentSession.Start_AM_PM__c}`;
            let endTime = `${currentSession.sessionStartDate} ${currentSession.End_Hours__c}:${currentSession.End_Minutes__c} ${currentSession.End_AM_PM__c}`;

            currentSession.label = `${currentSession.Name} ${ currentSession.sessionStart ? ' -- ' + startTime : '' } ${ endTime ? ' to ' + endTime : ''}`;
            
            // if(index == 0) {
                // currentSession.isChecked = true;
            //     sessions.push(currentSession);
            //     continue;
            // }
            
            // if(currentSession.Required__c == true && previousSession.isChecked == true){
            //     currentSession.isChecked = true;
            // }

            if(allRequired) {
                currentSession.isChecked = true;
            }
            sessions.push(currentSession);
        }

        this.eventSessions = sessions;
    } else if (error) {
        console.error(error);
    }
}

handleSessionChange(event){
    let selectedSessions = {};

    let sessions = Array.from(
        this.template.querySelectorAll('.sessions lightning-input')
    ).forEach((currentSession) => {
        if (event == undefined || event.currentTarget == undefined) return;

        let previousElement = currentSession.previousElementSibling;

        //deselection logic
        if(event.currentTarget.checked == false && event.currentTarget.dataset.required == "true") {
            if(currentSession.dataset.required == "true") {
                currentSession.checked = false;
            }
        }

        //selection logic
        if(event.currentTarget.checked == true && event.currentTarget.dataset.required == "true") {
            if(currentSession.dataset.required == "true") {
                currentSession.checked = true;
            }
        }

        //one selection logic 
        if(this.isOneCourse) {
            // If the current checkbox is not the one that triggered the event, uncheck it
            if (currentSession !== event.currentTarget) {
                currentSession.checked = false;
            }
        }
        // if (event.currentTarget.checked == false && currentSession.dataset.required == "true" && previousElement == null) {
        //     currentSession.nextElementSibling.checked = false;
        // }
        
        // if (currentSession.checked == true && previousElement != null && previousElement.previousElementSibling == null && previousElement.dataset.required == "true" && previousElement.checked == false) {
        //     previousElement.checked = true;
        // }

        // if(currentSession.dataset.required == "true" && previousElement != null && previousElement.checked == true){
        //     currentSession.checked = true;
        // }
    });

    const checked = Array.from(
        this.template.querySelectorAll('.sessions lightning-input')
    )
    .filter((element) => element.checked)
    .forEach((element) => {
        selectedSessions[`${element.dataset.key}`] = element.label;
    });
    this.registrationId = Object.keys(selectedSessions)[0];
    
}

handleSave(){
    saveOneSelection({regs: this.registration, registrationId: this.registrationId}).then(result => {
        this.currentSession = this.registrationId;
        this.closeModal();
    }).catch(error => {
        console.error(error);
    });

}

loadSelections(){
    this.registration.forEach((currentSession) => {
        if(currentSession.Status__c == 'Registered') {
            this.currentSession = currentSession.Session__c;
        }

    });

    // Assuming eventSessions is an array of objects
this.eventSessions = this.eventSessions.map(session => {
    // Add isChecked property to each session
    session.isChecked = session.Id == this.currentSession;
    return session;
});
}

}