import { LightningElement, wire } from 'lwc';
import { AppContextAdapter } from 'commerce/contextApi';
import { getSessionContext } from 'commerce/contextApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getAllAddressesForAccount from "@salesforce/apex/SIB_AddressController.getAllAddressesForAccount";


export default class SibMyAddresses extends NavigationMixin(LightningElement) {
    isLoading = false;
    effectiveAccountId;
    showShipping = true;
    showBilling = false;
    shippingAddresses;
    billingAddresses;
    currentAddresses;

    async getAccountId()
    {
        const result = await getSessionContext();
        if(result && result.effectiveAccountId)
        {
            this.effectiveAccountId = result.effectiveAccountId;
            this.getAddresses();
        }
    }

    @wire(AppContextAdapter)
    wireAppContext(result) {
        if (result.data) {
            this.getAccountId();
        }
    }

    getAddresses(){
        this.isLoading = true;
        let mapParams = {
            'accountId' : this.effectiveAccountId
        }
        getAllAddressesForAccount({
            'mapParams': mapParams
        }).then(
            (result) => {
                console.log('addresses-' + JSON.stringify(result));
                let t = this;
                setTimeout(() => {
                    t.isLoading = false;
                }, 1000);
                if(result.shippingAddresses && result.shippingAddresses != null && result.shippingAddresses.length > 0){
                    this.shippingAddresses = result.shippingAddresses;
                }else{
                    this.shippingAddresses = false;
                }
                if(result.billingAddresses && result.billingAddresses != null && result.billingAddresses.length > 0){
                    this.billingAddresses = result.billingAddresses;
                }else{
                    this.billingAddresses = false;
                }
            }).catch((e) => {
                console.log(e);
            }).finally(() => {
        });
    }

    displayShippingAddresses() {
        let activeNavKey = 'shipping';
        this.showShipping = true;
        this.showBilling = false;
        const activeDiv = this.template.querySelectorAll('.Layout-Title');
        activeDiv.forEach((node) => {
            if(node.dataset.id === activeNavKey) {
                node.classList.add('Active');
            }else {
                node.classList.contains('Active') ? node.classList.remove('Active') : null;
            }
        });
    }

    displayBillingAddresses() {
        let activeNavKey = 'billing';
        this.showShipping = false;
        this.showBilling = true;
        const activeDiv = this.template.querySelectorAll('.Layout-Title');
        activeDiv.forEach((node) => {
            if(node.dataset.id === activeNavKey) {
                node.classList.add('Active');
            }else {
                node.classList.contains('Active') ? node.classList.remove('Active') : null;
            }
        });
    }

    goToEditAddress(event) {
        let addressId = event.target.dataset.id;
        let addressParam = 'addressForm?addressId=' + addressId;
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": addressParam
            }
        });
    }

    goToAddAddress() {
        let addressForm = 'addressForm';
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": addressForm
            }
        });
    }

    connectedCallback() {
        if(this.isInSitePreview()){
            this.effectiveAccountId = '001DM00002OGpmxYAD';
            this.getAddresses();
        }
    }

    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }
}