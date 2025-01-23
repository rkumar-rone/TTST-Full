import { LightningElement, api, track} from 'lwc';
import getContactPointAddresses from '@salesforce/apex/Saltbox_B2BBillToController.getContactPointAddresses';
import getCountriesAndStates from '@salesforce/apex/Saltbox_B2BBillToController.getCountriesAndStates';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class SaltboxBilling extends LightningElement {
    @api orderId;
    @api cartId;
    @api hidePurchaseOrder;
    @api isGroupOrder;
    @api waitlistOrder;
    @api paymentSelectedOption;
    @api billingSelectedOption;
    @api outputSelectedAddress;
    @api outputSelectedCity;
    @api outputSelectedCountry = 'US';
    @api outputSelectedState;
    @api outputSelectedZipCode;

    billingAddresses;
    @track billingOptions = [];
    @track showNewBillingAddressForm;
    @track isLoading;

    countries;
    statesByCountries;
    states;

    //Countries where Postal Code is mandatory.
    countriesRequiringPostalCode = [
        'US', // United States
        'CA', // Canada
        'GB', // United Kingdom
        'AU', // Australia
        'IN', // India
        'MX', // Mexico
        'BR', // Brazil
        'AR', // Argentina
        'DE', // Germany
        'FR', // France
        'IT', // Italy
        'ES', // Spain
        'JP', // Japan
        'CN', // China
        'RU', // Russia
        'NL', // Netherlands
        'CH', // Switzerland
        'BE', // Belgium
        'AT', // Austria
        'SE', // Sweden
        'FI', // Finland
        'NO', // Norway
        'DK', // Denmark
        'NZ', // New Zealand
        'SG', // Singapore
        'ZA', // South Africa
    ];

    //Countries where State is mandatory.
    countriesRequiringState = [
        'US', // United States
        'CA', // Canada
        'AU', // Australia
        'IN', // India
        'MX', // Mexico
        'BR', // Brazil
        'AR', // Argentina
        'CN', // China
        'JP', // Japan
        'RU', // Russia
    ];

    connectedCallback() {

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

        getCountriesAndStates()
        .then(countriesAndStates => {
            this.countries = JSON.parse(JSON.stringify(countriesAndStates.countries));

            this.statesByCountries = JSON.parse(JSON.stringify(countriesAndStates.statesByCountries));
            
            if(this.outputSelectedCountry) this.findStates(this.outputSelectedCountry);
        })
        .catch(error => {
            console.log(error);
        });

    }

    goNext(){
            if(this.billingSelectedOption == 'new') {
                const address = this.template.querySelector('lightning-input-address');
                //Country Field Validation OOB is a bug in lightning-input-address
                var street = address.street;
                var city = address.city;
                var state = address.province;
                var country = address.country;
                var postalCode = address.postalCode;

                if (!street) {
                    address.setCustomValidityForField('Complete this field.', 'street');
                } else {
                    address.setCustomValidityForField('', 'street');
                }

                if (!city) {
                    address.setCustomValidityForField('Complete this field.', 'city');
                } else {
                    address.setCustomValidityForField('', 'city');
                }

                if (!country) {
                    address.setCustomValidityForField('Complete this field.', 'country');
                } else {
                    address.setCustomValidityForField('', 'country');
                }

                if(this.countriesRequiringState.includes(country) && !state) {
                    address.setCustomValidityForField('Complete this field.', 'province');
                } else {
                    address.setCustomValidityForField('', 'province');
                }

                if(this.countriesRequiringPostalCode.includes(country) && !postalCode) {
                    address.setCustomValidityForField('Complete this field.', 'postalCode');
                } else {
                    address.setCustomValidityForField('', 'postalCode');
                }

                address.reportValidity();
                if(address.checkValidity()) {
                    this.validatedNext();
                }
            } else {
                this.outputSelectedAddress = this.billingAddresses.get(this.billingSelectedOption).Street;
                this.outputSelectedCity = this.billingAddresses.get(this.billingSelectedOption).City;
                this.outputSelectedState = this.billingAddresses.get(this.billingSelectedOption).StateCode;
                this.outputSelectedCountry = this.billingAddresses.get(this.billingSelectedOption).CountryCode;
                this.outputSelectedZipCode = this.billingAddresses.get(this.billingSelectedOption).PostalCode;
                this.validatedNext();
            }
    }

    validatedNext() {
        this.goNextFinalStep();
    }

    goNextFinalStep() {
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handleBillingChange(event) {
        this.billingSelectedOption = event.target.value;
        if(event.target.value == 'new') this.showNewBillingAddressForm = true;
        else this.showNewBillingAddressForm = false;
    }

    handleAddressChange(event) {
        // Capture the previous country to compare with the new country
        const previousCountry = this.outputSelectedCountry;

        // Update address fields
        this.outputSelectedAddress = event.target.street;
        this.outputSelectedCity = event.target.city;
        this.outputSelectedState =event.target.province;
        this.outputSelectedCountry = event.target.country;
        this.outputSelectedZipCode = event.target.postalCode;

        // Only run findStates if the country has changed
        if (previousCountry !== this.outputSelectedCountry) {
            this.findStates(this.outputSelectedCountry);
        }
    }

    findStates(country) {
        this.states = this.statesByCountries[country];
    }
}