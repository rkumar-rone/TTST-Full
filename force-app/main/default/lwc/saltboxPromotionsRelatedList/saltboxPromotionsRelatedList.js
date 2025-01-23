import { LightningElement, api, wire } from 'lwc';
import getRelatedPromotions from '@salesforce/apex/SaltboxPromotionsRelatedListController.getRelatedPromotions';

export default class SaltboxPromotionsRelatedList extends LightningElement {

    @api recordId;

    error;
    records;
    tableIsLoaded = false;
    promotions =[];

    @wire(getRelatedPromotions, {
        recordId: '$recordId'
    })orderSummary({ error, data }) {
        if (data) {
            data = JSON.parse(data);
            //console.log('data: ', data);
            if (data.length > 0) {
                let promos = [];
                data.forEach(function (item) {
                    let promo = {
                        "Promotion": item.AdjustmentCause.Name === undefined ? '' : item.AdjustmentCause.Name,
                        "PromotionURL": item.AdjustmentCause.Id === undefined ? '' :  '/' + item.AdjustmentCause.Id
                    }
                    promos.push(promo);
                })
                this.promotions = promos;
                this.tableIsLoaded = true;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
            console.error('error: ', error);
        }
    }

    get columns() {
        return [
            {
                label: 'Promotions',
                fieldName: 'PromotionURL',
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'Promotion' },
                    target: '_self'},
                sortable: false,
                initialWidth: 400
            }
        ];
    }

    handleRefresh(){
        let orderSummaryId = this.recordId;
        this.recordId = orderSummaryId;
    }

}