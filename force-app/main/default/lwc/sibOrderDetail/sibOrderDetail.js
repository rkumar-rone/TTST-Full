import { LightningElement, api, wire } from 'lwc';
import orderNumberText from '@salesforce/label/c.SIB_OrderNumberName';
import orderDateText from '@salesforce/label/c.SIB_OrderDateName';
import clientText from '@salesforce/label/c.SIB_ClientName';
import billingAddressText from '@salesforce/label/c.B2B_Billing_Address';
import receiptText from '@salesforce/label/c.SIB_ReceiptName';
import paymentText from '@salesforce/label/c.SIB_Payment';
import noChargeText from '@salesforce/label/c.SIB_NoChargePaymentOption';
export default class SibOrderDetail extends LightningElement {

    @api orderConfig;
    @api orderDetails;
    @api orderData;

    labels = {
        orderNumberText,
        orderDateText,
        clientText,
        billingAddressText,
        receiptText,
        paymentText,
        noChargeText
    }

    get orderDetailsHeader() {
        return this.labels.receiptText;
    }

    get orderNumber() {
        return this.orderData?.OrderNumber;
    }

    get getOrderDate() {
         let date = new Date(this.orderData?.OrderedDate);

        let formattedDate = date.toLocaleDateString("en-US", {
        month: "short",
        day: "numeric", 
        year: "numeric" 
        });
        
        return formattedDate;
    }

    get billingName() {
        return this.orderData?.BillingName;
    }

    get billingStreet() {
        return this.orderData?.BillingStreet;
    }

    get billingCity() {
        return this.orderData?.BillingCity;
    }

    get billingState() {
        return this.orderData?.BillingStateCode;
    }

    get billingCountry() {
        return this.orderData?.BillingCountryCode;
    }

    get billingPincode() {
        return this.orderData?.BillingPostalCode;
    }

    get currencyCode() {
        return this.orderData?.CurrencyIsoCode;
    }

    get clientName() {
        return this.orderData?.clientName;
    }

    get showCCPayment() {
        if(this.orderData?.PoNumber == undefined) {
            return true;
        }
        return false;
    }

    get poNumber() {
        return this.orderData?.PoNumber;
    }

    get paymentMethod() {
        return this.orderData?.paymentMethod;
    }

    get paymentSummaryMethodName() {
        return this.orderData?.paymentSummaryMethodName;
    }

    get isNoChargePayment() {
        return !(this.paymentMethod === this.labels.noChargeText);
    }

}