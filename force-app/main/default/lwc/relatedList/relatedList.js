import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import RelatedListHelper from "./relatedListHelper";
import {loadStyle} from 'lightning/platformResourceLoader';
import relatedListResource from '@salesforce/resourceUrl/relatedListResource';

/**
 * @description       : LWC class used to display the table based on the List Composer Configuration
 * @author            : Emmanuel Pech
 * @last modified on  : 12-05-2023
 * @last modified by  : Emmanuel Pech
**/
export default class RelatedList extends NavigationMixin(LightningElement) {
    @track state = {}
    @api sobjectApiName;
    @api relatedFieldApiName;
    @api numberOfRecords = 6;
    @api sortedBy;
    @api sortedDirection = "DESC";
    @api rowActionHandler;
    @api fields;
    @api columns;
    @api customActions = [];
    @api amount = 5;
    @api clonedColumns =[];
    @api columnHelper;
    @track addedFields =[];
    @track validAccess;
    @track searchKey;
    @api searchAvailable;
    @api searchFieldList;
    @api hideActions;
    @api detailPage;
    @api isRelatedList = false;
    @api brandColor;
    @api textColor;
    helper = new RelatedListHelper()

    isLoading = true;

    connectedCallback(){
        this.state.recordId = this.recordId;
        this.hideActions = true;
        this.init();
    }
    renderedCallback() {        
        /*loadStyle(this, relatedListResource + '/relatedList.css')
        const header = this.template.querySelector('[data-id="header"]')
        header.style.backgroundColor = this.brandColor;
        header.style.color = this.textColor;*/
    }

    @api
    get recordId() {
        return this.state.recordId;
    }

    set recordId(value) {
        this.state.recordId = value;
        this.init();
    }
    get hasRecords() {
        return this.state.records != null && this.state.records.length;
    }
    /**
     * @description       : Get the required information to setup the table 
     * @param             : None
     * @return            : None
    **/
    async init(searchKey) {
        this.state.showRelatedList = this.recordId != null;
        if (! (this.sobjectApiName
            && this.fields
            && this.columns && this.sortedBy && this.searchFieldList)) {
            this.state.records = [];
            return;
        }

        this.state.fields = this.fields
        this.state.relatedFieldApiName= this.relatedFieldApiName
        this.state.recordId= this.recordId
        this.state.numberOfRecords= this.numberOfRecords
        this.state.sobjectApiName= this.sobjectApiName
        this.state.sortedBy= this.sortedBy
        this.state.sortedDirection= this.sortedDirection
        this.state.customActions= this.customActions
        this.state.searchKey = this.searchKey;
        this.state.searchFieldList = this.searchFieldList;
        this.state.detailpageurl = this.detailPage;
        this.state.relatedlist = this.isRelatedList;
        const data = await this.helper.fetchData(this.state);
        this.removeFieldsFromView(data.removedFields, data.records);
        this.state.records = data.records;
        this.state.iconName = data.iconName;
        this.state.sobjectLabel = data.sobjectLabel;
        this.state.sobjectLabelPlural = data.sobjectLabelPlural;
        this.state.title = data.title;
        this.state.parentRelationshipApiName = data.parentRelationshipApiName;
        //this.state.columns = this.helper.initColumnsWithActions(this.columns, this.customActions)
        this.columnHelper = this.clonedColumns[0] != null  ? [...this.clonedColumns] : [...this.columns];
        this.state.columns = this.helper.initColumnsWithActions(this.columnHelper, this.customActions, this.hideActions)

        this.isLoading = false;
    }

    /**
     * @description       : Second validation in order to remove the fields based on user field level accessibility
     * @param             : removedFields, records
     * @return            : None
    **/
    removeFieldsFromView(removedFields, records){
        for(var key in removedFields){
            removedFields[key].forEach(item => {
                this.addedFields.push(item);
            });

        }

        if(Object.keys(removedFields).length > 1){
            this.validAccess = false;
        } else {
            this.validAccess = true;
        } 
        for(var key in removedFields){
            this.columns.forEach( (element, index) =>{
                    if((!this.addedFields.includes(element.fieldName) && !this.clonedColumns.includes(element)) ){
                        this.clonedColumns = [...this.clonedColumns, element];
                    }
            })
        }

    }

    /**
     * @description       : reset table if the search bar is empty. It is only used if the Enable Search is true in the LWC config
     * @param             : event
     * @return            : None
    **/
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        if(this.searchKey == null || this.searchKey == ''){
            this.init();
        }
    }

    /**
     * @description       : enable search query for the particular key. It is only used if the Enable Search is true in the LWC config
     * @param             : event
     * @return            : None
    **/
    handleSearchKeyword(){
        this.init(this.searchKey);
    }

    /**
     * @description       : Enable user to go the view all list
     * @param             : None
     * @return            : None
    **/
    handleGotoRelatedList() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: this.recordId,
                relationshipApiName: this.state.parentRelationshipApiName,
                actionName: "view",
                objectApiName: this.sobjectApiName
            }
        });
    }

/*     handleCreateRecord() {
        const newEditPopup = this.template.querySelector("c-related-list-new-edit-popup");
        newEditPopup.recordId = null
        newEditPopup.recordName = null        
        newEditPopup.sobjectApiName = this.sobjectApiName;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.show();
    } */

    /**
     * @description       : Refresh data if the state is updated
     * @param             : None
     * @return            : None
    **/
    handleRefreshData() {
        this.clonedColumns = [];
        this.init();
    }
}