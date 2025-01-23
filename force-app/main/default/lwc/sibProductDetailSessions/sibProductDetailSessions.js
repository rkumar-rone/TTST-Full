import { LightningElement,api } from 'lwc';

export default class SibProductDetailSessions extends LightningElement {

    static renderMode = 'light';
    
    @api
    eventSessions;

    @api
    sessionFlag;

    handleSessionChange(event) {
        let selectedSessions = {};

        let sessions = Array.from(
            this.querySelectorAll('.sessions lightning-input')
        )
        .forEach((currentSession) => {
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
            if(this.sessionFlag) {
                // If the current checkbox is not the one that triggered the event, uncheck it
                if (currentSession !== event.currentTarget) {
                    currentSession.checked = false;
                }
            }
        });

        const checked = Array.from(
            this.querySelectorAll('.sessions lightning-input')
        )
        .filter((element) => element.checked)
        .forEach((element) => {
            selectedSessions[`${element.dataset.key}`] = element.label;
        });
        
        if(Object.keys(selectedSessions)==0) {
            this.fireSelectionEvent(true, JSON.stringify(selectedSessions));
        } else {
            this.fireSelectionEvent(false, JSON.stringify(selectedSessions));
        } 
    }

    fireSelectionEvent(disableAddToCart, selectedSessionsJson) {
        this.dispatchEvent(
            new CustomEvent('selectionevent', {
                detail: {
                    disableAddToCart: disableAddToCart,
                    selectedSessionsJson: selectedSessionsJson
                },
                bubbles: true,
                composed: true
            })
        );
    }
}