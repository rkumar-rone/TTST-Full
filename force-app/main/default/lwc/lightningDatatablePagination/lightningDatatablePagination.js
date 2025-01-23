import { LightningElement, api } from 'lwc';
/**
 * @description       : LWC class used to enable pagination. 
 * @author            : Emmanuel Pech
 * @last modified on  : 12-05-2023
 * @last modified by  : Emmanuel Pech
**/
export default class LightningDatatablePagination extends LightningElement {

    @api keyField;
    @api rowActionHandler;
    @api sobjectApiName;
    @api state;
    @api brandColor;
    @api textColor;
    // Maximum ammount of data rows to display at one time
    @api
    get displayAmmount() {
        return this._displayAmmount
    };
    set displayAmmount(value) {
        this._displayAmmount = value;
        this.gotoPage(1);
    }
    isRendered;
    _displayAmmount;

    // Columns to bind to the data table
    @api columns;

    // Data source for data table   
    @api
    get sourceData() {
        return this._sourceData
    };
    set sourceData(value) {
        this._sourceData = value;
        this.gotoPage(1);
    }
    _sourceData;

    // Partial JSON array of sourceData variable to bind to data table
    pagedData;

    // Current page of results on display
    currentPage = 1;

    // Current maximum pages in sourceData set
    maxPages = 1;

    // Indicators to disable the paging buttons
    disabledPreviousButton = false;
    disabledNextButton = false;

    // Loading indicator
    loading = false;

    connectedCallback() {

        let noLinkColumns = [];
        let fieldNames = [];
        this.columns.forEach(column => {
            if (!(fieldNames.includes(column.fieldName) || (column.type == 'url' && fieldNames.includes(column.typeAttributes.label.fieldName)))) {
                if (column.type == 'url') {
                    noLinkColumns.push({ label: column.label, fieldName: column.typeAttributes.label.fieldName, objectname: column.objectname, type: 'String'});
                    fieldNames.push(column.typeAttributes.label.fieldName);
                }else{
                    noLinkColumns.push(column);
                    fieldNames.push(column.fieldName);
                }
            }
        });
        this.columns = noLinkColumns;

        this.gotoPage(this.currentPage);
    }
    renderedCallback(){
        if (this.isRendered) {
            return; 
        }
        this.isRendered = true;
    
        let style = document.createElement('style');
        style.innerText = '.slds-th__action{width:100%; background-color:' + this.brandColor + '; color:' + this.textColor + ';}';
        this.template.querySelector('lightning-datatable').appendChild(style);
    }
    // Request reset of data table
    @api resetPaging() {
        this.gotoPage(1);
    }

    /**
     * @description       : Enable users to go to the next page
     * @param             : None
     * @return            : None
    **/
    handleButtonNext() {

        var nextPage = this.currentPage + 1;
        var maxPages = this.getMaxPages();

        if (nextPage > 0 && nextPage <= maxPages) {
            this.gotoPage(nextPage);
        }
    }

    /**
     * @description       : Enable users to go to the previous page
     * @param             : None
     * @return            : None
    **/
    handleButtonPrevious() {

        var nextPage = this.currentPage - 1;
        var maxPages = this.getMaxPages();

        if (nextPage > 0 && nextPage <= maxPages) {

            this.gotoPage(nextPage);
        }
    }

    /**
     * @description       : Get the maximum number of pages
     * @param             : None
     * @return            : None
    **/
    getMaxPages() {

        var result = 1;
        var arrayLength;
        var divideValue;

        if (this._sourceData) {

            arrayLength = this._sourceData.length;
            divideValue = arrayLength / this.displayAmmount;
            result = Math.ceil(divideValue);
        }

        this.maxPages = result;

        return result;
    }

    /**
     * @description       : Enable go to a particular page
     * @param             : None
     * @return            : None
    **/
    gotoPage(pageNumber) {

        var recordStartPosition, recordEndPosition;
        var i, arrayElement; // Loop helpers
        var maximumPages = this.maxPages;
        this.loading = true;

        maximumPages = this.getMaxPages();

        if (pageNumber > maximumPages || pageNumber < 0) {
            this.loading = false;
            return;
        }

        this.disabledPreviousButton = false;
        this.disabledNextButton = false;

        if (this._sourceData) {

            this.pagedData = [];
            recordStartPosition = this.displayAmmount * (pageNumber - 1);
            recordEndPosition = recordStartPosition + parseInt(this.displayAmmount, 10);

            for (i = recordStartPosition; i < recordEndPosition; i++) {

                arrayElement = this._sourceData[i];

                if (arrayElement) {

                    this.pagedData.push(arrayElement);
                }
            }

            this.currentPage = pageNumber;

            if (maximumPages === this.currentPage) {

                this.disabledNextButton = true;
            }

            if (this.currentPage === 1) {

                this.disabledPreviousButton = true;
            }

            this.loading = false;
        }
    }

    /**
     * @description       : Enable row actions
     * @param             : None
     * @return            : None
    **/
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case "delete":
                this.handleDeleteRecord(row);
                break;
            case "edit":
                this.handleEditRecord(row);
                break;
            default:
        }

    }

/*     handleEditRecord(row) {
        console.log(row);
        const newEditPopup = this.template.querySelector("c-related-list-new-edit-popup");
        newEditPopup.recordId = row.Id;
        newEditPopup.recordName = row.Name;
        console.log(this.sobjectApiName);
        console.log(this.state);
        newEditPopup.sobjectApiName = this.sobjectApiName;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.show();
    }

    handleDeleteRecord(row) {
        const newEditPopup = this.template.querySelector("c-related-list-delete-popup");
        newEditPopup.recordId = row.Id;
        newEditPopup.recordName = row.Name;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.show();
    } */

    /**
     * @description       : Refresh data if the state is updated
     * @param             : None
     * @return            : None
    **/
    refreshData() {
        this.dispatchEvent(new CustomEvent("refreshdata"));
    }
}