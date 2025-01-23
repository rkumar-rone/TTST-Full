import { LightningElement,api  } from 'lwc';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';
import communityId from "@salesforce/community/Id";
import getOrderDeliveryGroupSummaries from "@salesforce/apex/Saltbox_OrderSummaryProductsService.getOrderDeliveryGroupSummaries";
import getOrderItemSummaries from "@salesforce/apex/Saltbox_OrderSummaryProductsService.getOrderItemSummaries";
import courseCode from '@salesforce/label/c.SIB_CourseCode';
import quantity from '@salesforce/label/c.SIB_Quantity';
import totalWithTax from '@salesforce/label/c.SIB_TotalWithTax';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';

export default class SibOrderSummaryProducts extends LightningElement {
    labels = {
        courseCode,
        quantity,
        totalWithTax
    };

    @api recordId;
    @api accordionTitle;
    effectiveAccountId;
    productImage = SIBTheme + '/images/Course-Default-Image.png';


    physicalOdgs = [];
    digitalOdgs = [];
    physicalOdgsProducts = [];
    digitalOdgsProducts = [];
    orderDeliveryGroupSummmaries = [];
    orderDeliveryGroupSummmariesSelected = ["PhysicalOrder", "DigitalOrder"];
    isLoading = true;

    connectedCallback(){
        this.getAccountId();
    }
    async getAccountId()
    {
        const result = await getSessionContext();
        if(result)
        {
            this.effectiveAccountId = result?.effectiveAccountId;
            this.getOrderDeliveryGroupSummaries();
        }
    }

    async getOrderDeliveryGroupSummaries() {
        try {
            this.isLoading = true;
            let result = await getOrderDeliveryGroupSummaries({
                communityId: communityId,
                effectiveAccountId: this.effectiveAccountId,
                orderSummaryId: this.recordId
            });
            result?.orderDeliveryGroups.forEach((odg) => {
                let odgs = {};
                for (let key in odg?.fields) {
                    let splitKey = key.split(".");
                    let newKey = splitKey[0] + splitKey[1];
                    if (newKey === "OrderDeliveryGroupSummaryId") {
                        newKey = "Id";
                    }
                    odgs[newKey] = odg?.fields[key]?.text;
                }
                odgs.label =
                    "Ship to: " +
                    odgs.OrderDeliveryGroupSummaryDeliverToStreet +
                    ", " +
                    odgs.OrderDeliveryGroupSummaryDeliverToCity +
                    ", " +
                    odgs.OrderDeliveryGroupSummaryDeliverToState +
                    " " +
                    odgs.OrderDeliveryGroupSummaryDeliverToPostalCode +
                    ", " +
                    odgs.OrderDeliveryGroupSummaryDeliverToCountry;
                this.getOrderProducts(odgs?.Id, odgs?.OrderDeliveryMethodCarrier);
                this.orderDeliveryGroupSummmaries.push(odgs);
                this.orderDeliveryGroupSummmariesSelected.push(odgs?.OrderDeliveryMethodCarrier);
                this.isLoading = false;
            });
        } catch (error) {
            this.isLoading = false;
            const errorMessage = error?.body?.message;
            console.log(errorMessage);
        }
        this.digitalOdgs = this.orderDeliveryGroupSummmaries?.filter((odg) => odg?.OrderDeliveryMethodCarrier == "Digital")[0];
        this.physicalOdgs = this.orderDeliveryGroupSummmaries?.filter((odg) => odg?.OrderDeliveryMethodCarrier !== "Digital")[0];
    }

    isSandbox(){
        if (window.location.hostname.includes('sandbox')) {
            return true;
        }else{
            return false;
        }
    }

    async getOrderProducts(orderDeliveryGroupSummaryId, carrier) {
        try {
            let result = await getOrderItemSummaries({
                communityId: communityId,
                effectiveAccountId: this.resolvedEffectiveAccountId,
                orderSummaryId: this.recordId,
                orderDeliveryGroupSummaryId: orderDeliveryGroupSummaryId
            });
            let products = [];
            result?.items?.forEach((item) => {
                let product = {};
                for (let key in item?.fields) {
                    let splitKey = key.split(".");
                    let newKey = splitKey[0] + splitKey[1];
                    if (newKey === "OrderItemSummaryId") {
                        newKey = "Id";
                    }
                    product[newKey] = item?.fields[key]?.text;
                }
                for (let key in item?.product?.fields) {
                    let splitKey = key.split(".");
                    let newKey = splitKey[0] + splitKey[1];
                    product[newKey] = item?.product?.fields[key]?.text;
                }

                product.CurrencyIsoCode = item?.fields['OrderItemSummary.CurrencyIsoCode']?.text;
                product.media = item?.product?.media?.url?.includes('default-product-image') ?this.productImage : item?.product?.media?.url ;
                product.detailLink = '/product/'+product?.OrderItemSummaryProduct2Id;

                if (item?.product?.productAttributes && item?.product?.productAttributes?.attributes?.length > 0 && item?.product?.productAttributes?.attributes) {
                    item?.product?.productAttributes?.attributes?.forEach(attribute => {
                        if (attribute?.apiName == 'Month_Year__c') {
                            product.monthYear = attribute?.value;
                        }
                        if (attribute?.apiName == 'Event_City__c') {
                            product.eventCity = attribute?.value;
                        }
                    });
                }

                if (product?.monthYear && product?.eventCity) {
                    product.dateCity = 'Month / Year: '+product?.monthYear+', Event City: '+product?.eventCity;
                }else{
                    product.dateCity = '';
                    if (product?.monthYear) {
                        product.dateCity = 'Month / Year: '+product?.monthYear;
                    }
                    if (product?.eventCity) {
                        product.dateCity = 'Event City: '+product?.eventCity;
                    }
                }
                

                products.push(product);
            });
            
            if (carrier === "Digital") {
                this.digitalOdgsProducts = products;
            } else {
                this.physicalOdgsProducts = products;

            }

            this.isLoading = false;
        } catch (error) {
            console.log('error', error);
        }
    }

}