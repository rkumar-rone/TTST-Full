import { LightningElement, api } from 'lwc';
import isGroupOrder from '@salesforce/apex/RelatedListController.isGroupOrder';

export default class SibListComposer extends LightningElement {
    @api recordId;
    @api fieldList;
    @api childSobjectApiName;
    @api relatedfieldname;
    @api sortedbylist;
    @api sortedDir;
    @api rowLimit;
    @api pageLimit;
    @api searchAvailable = false;
    @api searchFieldList;
    @api detailpage;
    @api isRelatedList
    @api columnListTD = [];
    @api brandColor;
    @api textColor;
    objColumns = [];


    isGroupOrder = false;

    connectedCallback(){
        isGroupOrder({recordId: this.recordId})
        .then(result => {
            this.isGroupOrder = result;
        })
        .catch(error => {
            console.log('error', error);
        })

        this.objColumns = JSON.parse(this.columnListTD);
        this.childSobjectApiName = this.objColumns[0] != null ? this.objColumns[0].objectname : null;
        if (this.objColumns?.length > 0) {
            this.fieldList = this.objColumns[0]?.typeAttributes?.label?.fieldName;
            this.objColumns.forEach((element, index) => {
                if (index > 0) {
                    this.fieldList += ', ' + element?.fieldName;
                }
            });
        }
    }

}