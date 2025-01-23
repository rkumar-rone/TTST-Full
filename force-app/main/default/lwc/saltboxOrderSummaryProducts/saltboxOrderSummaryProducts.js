import { LightningElement, api, track } from "lwc";
import communityId from "@salesforce/community/Id";
import getOrderDeliveryGroupSummaries from "@salesforce/apex/Saltbox_OrderSummaryProductsService.getOrderDeliveryGroupSummaries";
import getOrderItemSummaries from "@salesforce/apex/Saltbox_OrderSummaryProductsService.getOrderItemSummaries";

export default class SaltboxOrderSummaryProducts extends LightningElement {
    @api recordId;
    @api effectiveAccountId;

    @track physicalOdgs = [];
    @track digitalOdgs = [];
    @track physicalOdgsProducts = [];
    @track digitalOdgsProducts = [];
    @track orderDeliveryGroupSummmaries = [];
    orderDeliveryGroupSummmariesSelected = ["PhysicalOrder", "DigitalOrder"];

    isLoading = true;

    @api accordionTitle;

    connectedCallback() {
        this.getOrderDeliveryGroupSummaries();
    }

    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || "";
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== "000000000000000"
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    async getOrderDeliveryGroupSummaries() {
        try {
            this.isLoading = true;
            let result = await getOrderDeliveryGroupSummaries({
                communityId: communityId,
                effectiveAccountId: this.resolvedEffectiveAccountId,
                orderSummaryId: this.recordId
            });
            result.orderDeliveryGroups.forEach((odg) => {
                let odgs = {};
                for (let key in odg.fields) {
                    let splitKey = key.split(".");
                    let newKey = splitKey[0] + splitKey[1];
                    if (newKey === "OrderDeliveryGroupSummaryId") {
                        newKey = "Id";
                    }
                    odgs[newKey] = odg.fields[key].text;
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
                this.getOrderProducts(odgs.Id, odgs.OrderDeliveryMethodCarrier);
                this.orderDeliveryGroupSummmaries.push(odgs);
                this.orderDeliveryGroupSummmariesSelected.push(
                    odgs.OrderDeliveryMethodCarrier
                );
            });
        } catch (error) {
            const errorMessage = error?.body?.message;
            console.error(errorMessage);
        }
        this.digitalOdgs = this.orderDeliveryGroupSummmaries.filter(
            (odg) => odg.OrderDeliveryMethodCarrier === "Digital"
        )[0];
        this.physicalOdgs = this.orderDeliveryGroupSummmaries.filter(
            (odg) => odg.OrderDeliveryMethodCarrier !== "Digital"
        )[0];
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
            //console.log('result', JSON.parse(JSON.stringify(result)));
            let products = [];
            result.items.forEach((item) => {
                let product = {};
                for (let key in item.fields) {
                    let splitKey = key.split(".");
                    let newKey = splitKey[0] + splitKey[1];
                    if (newKey === "OrderItemSummaryId") {
                        newKey = "Id";
                    }
                    product[newKey] = item.fields[key].text;
                }
                for (let key in item.product.fields) {
                    let splitKey = key.split(".");
                    let newKey = splitKey[0] + splitKey[1];
                    product[newKey] = item.product.fields[key].text;
                }
                
                if (this.isSandbox()) {
                    product.media = '/TTSB2B'+item.product.media.url;
                    // product.detailLink = window.location.hostname+'/TTSB2B/s/product/'+product.OrderItemSummaryProduct2Id;
                    product.detailLink = '/TTSB2B/s/product/'+product.OrderItemSummaryProduct2Id;
                }else{
                    product.media = item.product.media.url;
                    // product.detailLink = window.location.hostname+'/s/product/'+product.OrderItemSummaryProduct2Id;
                    product.detailLink = '/s/product/'+product.OrderItemSummaryProduct2Id;
                }

                if (item.product.productAttributes && item.product.productAttributes.attributes.length > 0 && item.product.productAttributes.attributes) {
                    item.product.productAttributes.attributes.forEach(attribute => {
                        if (attribute.apiName == 'Month_Year__c') {
                            product.monthYear = attribute.value;
                        }
                        if (attribute.apiName == 'Event_City__c') {
                            product.eventCity = attribute.value;
                        }
                    });
                }

                if (product.monthYear && product.eventCity) {
                    product.dateCity = 'Month / Year: '+product.monthYear+', Event City: '+product.eventCity;
                }else{
                    product.dateCity = '';
                    if (product.monthYear) {
                        product.dateCity = 'Month / Year: '+product.monthYear;
                    }
                    if (product.eventCity) {
                        product.dateCity = 'Event City: '+product.eventCity;
                    }
                }
                

                products.push(product);
            });
            
            //console.log('products', JSON.parse(JSON.stringify(products)));

            if (carrier === "Digital") {
                this.digitalOdgsProducts = products;
            } else {
                this.physicalOdgsProducts = products;
            }

            this.isLoading = false;
        } catch (error) {
            console.error('error', error);
        }
    }
}