import { LightningElement, wire } from 'lwc';
import communityPath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';
import initUserLogin from '@salesforce/apex/SIB_UserRegistrationController.initUserLogin';


export default class SibUserLogin extends LightningElement {
    email = '';
    password = '';
    isLoading;

    currentPageReference = null;
    urlStateParameters = null;
    startURL = communityPath ;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            if(this.urlStateParameters.startURL){
                this.startURL = this.urlStateParameters.startURL
            }
        }
    }


    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    handleLogin(event) {
        if (this.validateData()) {
            this.initUserLogin();
        }else {
            this.showToast('Please enter valid details', 'error');
        }
    }

    validateData() {
        if(this.email != '' && this.password != '') {
            return true;
        }
        return false;
    }

    initUserLogin() {
        this.isLoading = true;
        this.showSpinner(true);
        let dataMap = {
            email: this.email,
            password: this.password,
            communityPath : this.startURL
        }
        initUserLogin({
            'dataMap': dataMap
        }).then((result) => {
            if (result && result.isSuccess) {
                location.href = result.loginUrl;
            }else if(result && result.msg){
                this.isLoading = false;
                this.showSpinner(false);
                this.showToast(result.msg, 'error');
            }
        }).catch((e) => {
            this.isLoading = false;
            this.showSpinner(false);
            console.log('error--' + JSON.stringify(e));
            this.showToast('Some Error occured,Please contact System admin.', 'error');
        });
    }

    showToast(message, type) {
        this.template.querySelector('c-sib-show-toast-message').showToast(message, type, 5000);
    }

    showSpinner(e) {
        let targetId = 'signing-in-progress';
        let target = this.template.querySelector(`[data-id="${targetId}"]`);
        if(e) {
            target.classList.add('signingin-page');
        }else {
            target.classList.contains('signingin-page') ? target.classList.remove('signingin-page') : null;
        }
    }
}