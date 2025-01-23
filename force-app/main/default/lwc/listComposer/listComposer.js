import { LightningElement, track, api } from 'lwc';

import isGroupOrder from '@salesforce/apex/RelatedListController.isGroupOrder';

/**
 * @description       : LWC class used to construct the data dolumns and records
 * @author            : Emmanuel Pech
 * @last modified on  : 12-05-2023
 * @last modified by  : Emmanuel Pech
**/
export default class ListComposer extends LightningElement {
    @api
    recordId;
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
    @track objColumns = [];
    @api brandColor;
    @api textColor;

    isGroupOrder = false;

    connectedCallback(){

        isGroupOrder({recordId: this.recordId})
        .then(result => {
            this.isGroupOrder = result;
            console.log('this.isGroupOrder', this.isGroupOrder);
        })

        this.objColumns = JSON.parse(this.columnListTD);
        this.childSobjectApiName = this.objColumns[0] != null ? this.objColumns[0].objectname : null;
        if(this.objColumns.length>0){
            if(this.objColumns[0]['typeAttributes'].label.fieldName){
                this.fieldList = this.objColumns[0]['typeAttributes'].label.fieldName;
            }
            this.objColumns.forEach((element, index) => {
                if(index > 0){
                    this.fieldList += ', ' + element.fieldName;
                }
            })

        }

    }
}