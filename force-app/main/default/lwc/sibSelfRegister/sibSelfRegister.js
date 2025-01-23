import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';
import initUserRegistration from '@salesforce/apex/SIB_UserRegistrationController.initUserRegistration';
import getRegistrationConfiguration from '@salesforce/apex/SIB_UserRegistrationController.getRegistrationConfiguration';


export default class SibSelfRegister extends LightningElement {

    specialCharsInstructionText = '1 or more special characters ($%@&/()[]{}=?!.,;:`\'"<^>-_*|+~#)';

    @track isCheckboxChecked = false;

    firstName = '';
    lastName = '';
    email = '';
    phone = '';
    company = '';
    password = '';
    confirmPassword = '';
    website = '';
    showSpinner = false;
    userRegistrationSuccess = false;
    emailExistErr=false;
    emailError;
    showPhoneErrorDetails = false;

    countryCode = 'US';
    stateCode;
    notifyInv = false;
    registerConfig;
    showPassword;

    @wire(getRegistrationConfiguration,  {mapParams : {} })
    wiredRegisterConfig({ error, data }) {
        console.log('data--' + JSON.stringify(data));
        if (data) {
            this.registerConfig = data.signUpConfig;
            this.showPassword = this.registerConfig.showPasswordFields;
        } else if (error) {
            console.error(error);
        }
    };

    handleFirstNameChange(event){
        this.firstName = event.target.value;
    }

    validateFirstName() {
        if (this.firstName == null || this.firstName == '' || this.firstName.trim() == '') {
            this.showFirstNameErr = true;
            return false;
        } else {
            this.showFirstNameErr = false;
            return true;
        }
    }

    handleLastNameChange(event){
        this.lastName = event.target.value;
    }

    validateLastName() {
        if (this.lastName == null || this.lastName == '' || this.lastName.trim() == '') {
            this.showLastNameErr = true;
            return false;
        } else {
            this.showLastNameErr = false;
            return true;
        }
    }

    handleEmailChange(event){
        this.email = event.target.value;
    }

    validateEmail() {
        let email = this.email;
        let re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (re.test(String(email).toLowerCase())) {
            this.showEmailErr = false;
            if (this.email == null || this.email == '' || this.email.trim() == '') {
                this.showEmailErr = true;
                return false;
            }
            else {
                this.showEmailErr = false;
                return true;
            }
        }
        else {
            this.showEmailErr = true;
            return false;
        }
    }

    handleCompanyChange(event){
        this.company = event.target.value;
    }

    validateCompany() {
        if (this.company == null || this.company == '' || this.company.trim() == '') {
            this.showCompanyErr = true;
            return false;
        } else {
            this.showCompanyErr = false;
            return true;
        }
    }

    handleCompanyWebsiteChange(event){
        this.website = event.target.value;
    }

    validateCompanyWebsite(){

        if (this.website == null || this.website == '' || this.website.trim() == '') {
            this.showCompanyWebErr = true;
            return false;
        } else {
            this.showCompanyWebErr = false;
            return true;
        }
    }

    handlePhoneChange(event){
        this.phone = event.target.value;
    }

    validatePhone() {

        if (this.phone == null || this.phone == '' || this.phone.trim() == '')  {
            this.showPhoneErr = true;
            return false;
        }
        else if(this.phone.includes('-') || this.phone.includes('(') || this.phone.includes(')'))
        {
            this.showPhoneErrorDetails = true;
            return false;
        }
        else {
            this.showPhoneErr = false;
            this.showPhoneErrorDetails = false;
            return true;
        }
    }

    handlePasswordChange(event){
        this.password = event.target.value;
    }

    handleConfirmPasswordChange(event){
        this.confirmPassword = event.target.value;
    }

    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 3;
        toastContainer.toastPosition = 'top-center';
    }

    handleSignUp() {
        if(this.validate()){
            this.initUserRegistration();
        }
    }


    validate(){
        let isValid = true;
        if(!this.validateFirstName()){
            isValid = false;
        }
        if(!this.validateLastName()){
            isValid = false;
        }
        if(!this.validateEmail()){
            isValid = false;
        }
        if(!this.validatePhone()){
            isValid = false;
        }
        if(!this.validateCompany()){
            isValid = false;
        }
        /*if(!this.validateCountryCode()){
            isValid = false;
        }
        if(!this.validateStateCode()){
            isValid = false;
        }*/
        if(!this.validateCompanyWebsite()){
            isValid = false;
        }
        return isValid;
    }

    initUserRegistration(){

        let params = {
            firstName : this.firstName,
            lastName : this.lastName,
            email : this.email,
            phone : this.phone,
            company : this.company,
            website : this.website,
            //countryCode: this.countryCode,
            //stateCode: this.stateCode,
            password : this.password,
            confirmPassword : this.confirmPassword
        };

        this.showSpinner = true;
        initUserRegistration({
            'dataMap': params
        }).then((result) => {
            this.showSpinner = false;
            if (result && result.isSuccess) {
                if(this.showPassword) {
                    console.log('loginUrl--' + JSON.stringify(result.loginUrl));
                    location.href = result.loginUrl;
                } else {
                    location.href = './CheckPasswordResetEmail';
                }
                
            } else {
                if (result.isUserExist) {
                    this.emailExistErr=true;
                    this.emailError = result.msg;
                    this.showToast('User Already Exists. Please try login.', 'error');
                }
                else
                {
                    this.showToast('Some error occurred , Please try again.', 'error');
                }
            }

        }).catch((e) => {
            this.showToast('Some Error occured while registering this User,Please contact System admin.', 'error');
        });
    }

    showToast(message, variant) {
		let title = variant == 'error' ? 'Error' : 'Success';

		const evt = new ShowToastEvent({
			title: variant,
			message: message,
			variant: variant
		});
		this.dispatchEvent(evt);
	}

}