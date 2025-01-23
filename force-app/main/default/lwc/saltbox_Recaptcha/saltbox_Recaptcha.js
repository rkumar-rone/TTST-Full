import { LightningElement, api } from 'lwc';
import verifyRecaptcha from '@salesforce/apex/ReCAPTCHA.verifyRecaptcha';


export default class Saltbox_Recaptcha extends LightningElement {


    @api
    resetCaptcha() {
        document.dispatchEvent(new CustomEvent("grecaptchaReset"));
    }

    connectedCallback() {
        document.addEventListener("grecaptchaVerified", (e) => {
            verifyRecaptcha({recaptchaResponse: e.detail.response})
                .then(result => {
                    if (result == true){
                        this.dispatchVerify();
                    }
                    else {
                        alert('Please verify you are not a robot.');
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        });

        document.addEventListener("grecaptchaExpired", (e) => {
            this.distpatchExpired();
        });
    }

    renderedCallback() {
        var divElement = this.template.querySelector('div.recaptchaCheckbox');
        var payload = {element: divElement};
        document.dispatchEvent(new CustomEvent("grecaptchaRender", {"detail": payload}));
    }

    dispatchVerify() {
        this.dispatchEvent(new CustomEvent("success"));
    }

    distpatchExpired() {
        this.dispatchEvent(new CustomEvent("expired"));
    }
}