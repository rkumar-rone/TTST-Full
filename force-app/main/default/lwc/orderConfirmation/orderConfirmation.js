import { LightningElement, wire, api } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import ORDER_NUMBER_FIELD from "@salesforce/schema/OrderSummary.OriginalOrderId";
import BILLING_STREET_FIELD from "@salesforce/schema/OrderSummary.BillingStreet";
import BILLING_CITY_FIELD from "@salesforce/schema/OrderSummary.BillingCity";
import BILLING_STATE_FIELD from "@salesforce/schema/OrderSummary.BillingState";
import BILLING_POSTAL_CODE_FIELD from "@salesforce/schema/OrderSummary.BillingPostalCode";
import BILLING_COUNTRY_FIELD from "@salesforce/schema/OrderSummary.BillingCountry";
import PAYMENT_METHOD_FIELD from "@salesforce/schema/OrderSummary.Payment_Method__c";

import getGTMEventData from '@salesforce/apex/UpdateGTMdataLayerController.getGTMEventData';

const fields = [
  ORDER_NUMBER_FIELD,
  BILLING_STREET_FIELD,
  BILLING_CITY_FIELD,
  BILLING_STATE_FIELD,
  BILLING_POSTAL_CODE_FIELD,
  BILLING_COUNTRY_FIELD,
  PAYMENT_METHOD_FIELD
];

export default class OrderConfirmation extends LightningElement {
  @api recordId;
  @api invoiceLabel;
  orderNumber;
  billingStreet;
  billingCity;
  billingState;
  billingPostalCode;
  billingCountry;
  paymentMethod;
  billingAddress;
  invoiceMessage;
  hasGtmPurchaseDispatched;

  @wire(getRecord, { recordId: "$recordId", fields: fields })
  orderSummary({ error, data }) {
    if (data) {
      this.orderNumber = getFieldValue(data, ORDER_NUMBER_FIELD);
      this.billingStreet = getFieldValue(data, BILLING_STREET_FIELD);
      this.billingCity = getFieldValue(data, BILLING_CITY_FIELD);
      this.billingState = getFieldValue(data, BILLING_STATE_FIELD);
      this.billingPostalCode = getFieldValue(data, BILLING_POSTAL_CODE_FIELD);
      this.billingCountry = getFieldValue(data, BILLING_COUNTRY_FIELD);
      this.paymentMethod = getFieldValue(data, PAYMENT_METHOD_FIELD);
      this.invoiceMessage = this.paymentMethod === "Invoice";
      this.billingAddress = (this.billingStreet + this.billingCity +  this.billingState + this.billingPostalCode +  this.billingCountry) !== 0 ;
      
    } else if (error) {
      console.log("Error retrieving order data");
      console.log(JSON.stringify(error));
    }
    if(this.isInSitePreview()) {
      this.invoiceMessage = true;
    }
  }

  connectedCallback(){    

    this.hasGtmPurchaseDispatched = false;

    console.log('In connectedCallback');

    const getCookieValues = new CustomEvent("getCookies", {
      bubbles: true,
      composed: true,
      detail: { value: "" },
    });
    this.dispatchEvent(getCookieValues);
    console.log('cookies: '+ JSON.stringify(getCookieValues));

    if (getCookieValues != undefined) {

      setTimeout(() => {
        
        let referrer = getCookieValues.detail.value.split("; ").find((row) => row.startsWith("calltrk_referrer="))?.split("=")[1];

        console.log('referrer: '+ referrer);
        //console.log('gtmFlag: '+ this.hasGtmPurchaseDispatched);
        if (!this.hasGtmPurchaseDispatched) {
          
          if (referrer == undefined) {
            referrer = '';
          }

          getGTMEventData({recordId: this.recordId })
          .then((result) => {

            let gtmEventData = JSON.parse(result);

            //console.log('gtmEventData',gtmEventData);

            const pushToDataLayer = new CustomEvent('updateGTMdataLayer', { 
              'detail' : { 
                'event' : 'purchase', 
                'ecommerce' : {
                  'referrer':referrer,
                  'oId' : gtmEventData.oId ,
                  'value': gtmEventData.cost,
                  'currency': gtmEventData.currencyCode,
                  'transaction_id': gtmEventData.osId,
                  'coupon': gtmEventData.coupon,
                  'shipping': 0,	
                  'tax': gtmEventData.tax,
                  'firstName' : gtmEventData.firstName, 
                  'lastName' : gtmEventData.lastName, 
                  'email' : gtmEventData.email, 
                  'cost' : gtmEventData.cost, 
                  'status' : gtmEventData.status, 
                  'subTotal' : gtmEventData.subTotal,
                  'items' : gtmEventData.gtmItems
                } 
              }
            });

            console.log('pushToDataLayer');
            console.log(JSON.stringify(pushToDataLayer.detail));

            document.dispatchEvent(pushToDataLayer);

            this.hasGtmPurchaseDispatched = true;
            
          })
          .catch((e) => {
            console.error(e);
          });
        }
        
      }, "1000");

    }
    
  }


  isInSitePreview() {
    let url = document.URL;

    return (
      url.indexOf("sitepreview") > 0 ||
      url.indexOf("livepreview") > 0 ||
      url.indexOf("live-preview") > 0 ||
      url.indexOf("live.") > 0 ||
      url.indexOf(".builder.") > 0
    );
  }
}