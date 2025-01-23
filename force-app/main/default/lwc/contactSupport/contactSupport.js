import { LightningElement, api } from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import submitCase from '@salesforce/apex/contactSupportController.submitCase';
import submitLead from '@salesforce/apex/contactSupportController.submitLead';
import getUserInfo from '@salesforce/apex/contactSupportController.getUserInfo';
import isGuest from '@salesforce/user/isGuest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactSupport extends LightningElement {
    @api lContactButton;
    @api lCourseButton;
    @api toastTitle;
    @api toastMessage;

    currentUserName = '';
    currentUserLastName = '';
    currentUserEmail = '';
    currentUserPhone = '';
    region = '';
    isGuest = isGuest;
    isGuestElements = isGuest;
    showSpinner = false;
    ContactSupport = true;
    CourseSupport = false;

    async connectedCallback() {
        if (!this.isGuest) {
            try {
                let result = await getUserInfo();
                this.currentUserName = result.FirstName;
                this.currentUserLastName = result.LastName;
                this.currentUserEmail = result.Email;
                this.currentUserPhone = result.Phone;
            } catch (error) {
                console.log(error.body.message);
            }
        }
    }

    async handleClickCS(event) {
        this.showSpinner = true;
        let inputs = this.template.querySelectorAll('.csInput');
        let isValidForm = true;
        inputs.forEach((input) => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValidForm = false;
            }
        });
        if (!isValidForm) {
            this.showSpinner = false;
            return;
        }

        CASE_OBJECT.First_Name_Case__c = this.refs.csFirstName.value;
        CASE_OBJECT.Last_Name_Case__c = this.refs.csLastName.value;
        CASE_OBJECT.SuppliedEmail = this.refs.csEmail.value;
        CASE_OBJECT.SuppliedPhone = this.refs.csPhone.value;
        CASE_OBJECT.Subject = this.refs.csSubject.value;
        CASE_OBJECT.How_can_we_help__c = this.refs.csHow.value;
        try {
            let result = await submitCase({ newCase: CASE_OBJECT });
            inputs.forEach((input) => {
                input.value = '';
            });
            this.showSpinner = false;
            this.showNotification();
            if (this.isGuest) {
                this.resetCaptcha();
            }
        } catch (error) {
            this.showNotificationOnError();
            console.log(error.body.message);
        }
        this.showSpinner = false;
    }

    async handleClickCourse(event) {
        this.showSpinner = true;
        let inputs = this.template.querySelectorAll('.courseInput');
        let isValidForm = true;
        inputs.forEach((input) => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValidForm = false;
            }
        });
        if (!isValidForm) {
            this.showSpinner = false;
            return;
        }

        LEAD_OBJECT.FirstName = this.refs.courseFirstName.value;
        LEAD_OBJECT.LastName = this.refs.courseLastName.value;
        LEAD_OBJECT.Email = this.refs.courseEmail.value;
        LEAD_OBJECT.Company = this.refs.courseCompanyOrSchool.value;
        LEAD_OBJECT.Region__c = this.region;
        LEAD_OBJECT.How_can_we_help__c = this.refs.courseHow.value;
        try {
            console.log(JSON.stringify(LEAD_OBJECT));
            let result = await submitLead({ newLead: LEAD_OBJECT });
            inputs.forEach((input) => {
                input.value = '';
            });
            this.showSpinner = false;
            this.showNotification();
            if (this.isGuest) {
                this.resetCaptcha();
            }
        } catch (error) {
            this.showNotificationOnError();
            console.log(error.body.message);
        }
        this.showSpinner = false;
    }

    handleChange(event) {
        this.region = event.detail.value;
    }

    get options() {
        return [
            { label: 'Americas', value: 'Americas' },
            { label: 'Europe', value: 'Europe' },
            { label: 'Africa', value: 'Africa' },
            { label: 'Asia Pac', value: 'Asia Pac' },
            { label: 'Middle East', value: 'Middle East' }
        ];
    }

    validCaptcha() {
        this.isGuestElements = false;
    }

    handleExpired() {
        this.isGuestElements = true;
    }

    resetCaptcha() {
        this.template.querySelector('c-saltbox_-recaptcha').resetCaptcha();
        this.isGuestElements = true;
    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: this.toastTitle,
            message: this.toastMessage,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

    showNotificationOnError() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'An error has occurred. Please try again.',
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    courseTabActive() {
        this.CourseSupport = true;
        this.ContactSupport = false;
    }

    contactTabActive() {
        this.CourseSupport = false;
        this.ContactSupport = true;
    }
}