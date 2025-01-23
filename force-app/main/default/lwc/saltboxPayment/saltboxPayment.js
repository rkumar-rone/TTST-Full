import { LightningElement, api, track} from 'lwc';
import tokenizeCard from '@salesforce/apex/Saltbox_PaymentController.tokenizeCard';
import getContactPointAddresses from '@salesforce/apex/Saltbox_B2BBillToController.getContactPointAddresses';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import basePath from "@salesforce/community/basePath";
export default class saltboxPayment extends LightningElement {
    @api orderId;
    @api cartId;
    @api hidePurchaseOrder;
    @api isGroupOrder;
    @api waitlistOrder;
    @api paymentSelectedOption;
    @api billingSelectedOption;
    @api outputSelectedAddress;
    @api outputSelectedCity;
    @api outputSelectedCountry;
    @api outputSelectedState;
    @api outputSelectedZipCode;

    paymentOptions = [{ label: 'Credit Card', value: 'cc' }];
    @track showCreditCardForm;
    @track creditCardError;
    billingAddresses;
    @track billingOptions = [];
    @track showNewBillingAddressForm;
    @track isLoading;
    cybersourceIFramePath = basePath.slice(0, -1) + 'CyberSourceIFrame';

    connectedCallback() {

        if (!this.hidePurchaseOrder) {
            this.paymentOptions.push({ label: 'Invoice', value: 'invoice' });
        }
        if(this.paymentSelectedOption != 'cc') {
            this.paymentSelectedOption = 'cc';
        }
        this.showCreditCardForm = true;
        
        getContactPointAddresses()
        .then(data => {
            this.billingAddresses = new Map(data.map(addr => [addr.Id, addr]));
            data.forEach(addr => {
                this.billingOptions.push({ label: addr.Street + ', ' + addr.City + ', ' + addr.State + ', ' + addr.Country + ' ' + addr.PostalCode, value: addr.Id });
            });
            this.billingOptions.push({ label: 'New Billing Address', value: 'new' });
            this.billingSelectedOption = this.billingOptions[0].value;
            if(this.billingSelectedOption == 'new') this.showNewBillingAddressForm = true;
        })
        .catch(error => {
            console.log(error);
        });

        window.addEventListener('message', this.receiveMessage);
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.receiveMessage);
    }

    receiveMessage = (event) => {
        console.log(event);
        if(event.data == 'error') { this.isLoading = false; }
        else {
            console.log('received ' + event.data.token);
            let paymentWrapper = {
                cardHolderFirstName : this.template.querySelector('[data-id="cardHolderFirstName"]').value,
                cardHolderLastName : this.template.querySelector('[data-id="cardHolderLastName"]').value,
                token : event.data.token,
                expiryYear : event.data.expiryYear,
                expiryMonth : event.data.expiryMonth,
                cardType : event.data.cardType,
                address : {
                    street : this.outputSelectedAddress,
                    city : this.outputSelectedCity,
                    state : this.outputSelectedState,
                    postalCode : this.outputSelectedZipCode,
                    country : this.outputSelectedCountry
                }
            };
            console.log('paymentWrapper created: ', paymentWrapper);
            tokenizeCard({orderId: this.orderId, cartId: this.cartId, pw : paymentWrapper, isGroupOrder: this.isGroupOrder, isWaitlist: this.waitlistOrder})
            .then(data=>{
                this.isLoading = false;
                if(data == 'Success') {
                    this.goNextFinalStep();
                }
                else {
                    this.creditCardError = data;
                }
            })
            .catch(error =>{console.log(error);});
        }
    }


    goNext(){
        this.creditCardError = '';
        if((this.paymentSelectedOption == 'invoice') || (this.template.querySelector('[data-id="cardHolderFirstName"]').reportValidity() && this.template.querySelector('[data-id="cardHolderLastName"]').reportValidity())) {
            if(this.billingSelectedOption == 'new') {
                if(this.template.querySelector('lightning-input-address').reportValidity()) {
                    this.validatedNext();
                }
            } else {
                // this.outputSelectedAddress = this.billingAddresses.get(this.billingSelectedOption).Street;
                // this.outputSelectedCity = this.billingAddresses.get(this.billingSelectedOption).City;
                // this.outputSelectedState = this.billingAddresses.get(this.billingSelectedOption).State;
                // this.outputSelectedCountry = this.billingAddresses.get(this.billingSelectedOption).Country;
                // this.outputSelectedZipCode = this.billingAddresses.get(this.billingSelectedOption).PostalCode;
                this.validatedNext();
            }
        }
    }

    validatedNext() {
        if(this.paymentSelectedOption == 'cc') {
            this.isLoading = true;
            this.template.querySelector('iframe').contentWindow.postMessage('tokenize', window.location.origin);
        }
        else {
            this.goNextFinalStep();
        }
    }

    goNextFinalStep() {
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handlePaymentChange(event) {
        this.paymentSelectedOption = event.target.value;
        if(event.target.value == 'cc') this.showCreditCardForm = true;
        else this.showCreditCardForm = false;
    }
}