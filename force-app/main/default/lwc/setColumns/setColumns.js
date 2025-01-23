import { LightningElement, track, api } from 'lwc';
import fetchAllFieldList from '@salesforce/apex/ObjectsAndFieldsController.fetchAllFieldList';fetchAllFieldList
import getAllFields from '@salesforce/apex/ObjectsAndFieldsController.fetchAllObjectList';
/**
 * @description       : LWC class used as a custom property for List Composer LWC. Enables object and fields config
 * @author            : Emmanuel Pech
 * @last modified on  : 12-05-2023
 * @last modified by  : Emmanuel Pech
**/
export default class SetColumns extends LightningElement {
    @api tableColumns = []
    @track objectList = [];
    @track allObjectList = [];
    @track customObjectList = [];
    @track standardObjectList = [];
    @track fieldList = [];
    showFields = null;
    objectName = '';
    fieldLinkName = '';
    showChekbox;
    objectTypeList = [
        {label: 'All', value: 'All'},
        {label: 'Custom', value: 'Custom'},
        {label: 'Standard', value: 'Standard'},

    ]
    fieldNames;
    //defaultOptions = ['Last Name-LastName', 'First Name-FirstName', 'Full Name-Name']
    connectedCallback(){
        getAllFields().then(result =>{
            if(result){
                for(let key in result){
                    if(key.endsWith('__c')){
                        this.customObjectList.push({ label: key, value:key });
                    } else if (!key.endsWith('__c')){
                        this.standardObjectList.push({ label: key, value:key });
                    }
                    this.allObjectList.push({ label: key, value:key });
                    this.objectList = this.allObjectList;
                }
            } else {
                console.log('Objects are not found');
            }
        }).catch(error=>{
            console.log('error')
        });

    }

    @api
    set value(savedColumns) {
        this.tableColumns = JSON.parse(savedColumns);
        if(this.tableColumns.length>0){
            this.objectName = this.tableColumns[0].objectname;
            this.fieldLinkName = this.tableColumns[0].label + '-' + this.tableColumns[0]['typeAttributes'].label.fieldName;
            this.showFields = false;
            this.fieldList = [];
            fetchAllFieldList({ strObjectName: this.objectName }).then(
                result=>{
                    var listItem;
                    for (let key in result) {
                        listItem = { label: key, value: key + '-' + result[key] };
                        if(this.tableColumns.length>0){
                            this.tableColumns.forEach(result=>{
                                if(key == result.label){
                                    listItem.checked = result.checked;
                                    if(result.typeAttributes){
                                        listItem.disabled = true;
                                    }
                                }
                            })
                        }
                        this.fieldList.push(listItem);
                    }
                    this.showFields = true;
                    this.showChekbox = true;
                }
            ).catch(error=>{
                console.log(error);
            })
        }
    }

    get value() {
        return this.tableColumns;
    }
    /**
     * @description       : Handles object type change and show up either custom or standard 
     * @param             : event
     * @return            : String
    **/
    onObjectTypeChange(event){
        const typeSelected = event.detail.value;
        if(typeSelected == 'All'){
            this.objectList = this.allObjectList;
        } else if(typeSelected == 'Custom'){
            this.objectList = this.customObjectList;
        } else if(typeSelected == 'Standard'){
            this.objectList = this.standardObjectList;
        }
    }

    /**
     * @description       : Handles sObject name change in order to fetch the related fields
     * @param             : event
     * @return            : String
    **/
    onObjectChange(event){
        this.objectName = event.detail.value;
        this.showFields = false;
        this.showChekbox = false;
        this.fieldList = [];
        this.tableColumns = [];
        fetchAllFieldList({ strObjectName: this.objectName }).then(
            result=>{
                var listItem;
                for (let key in result) {
                    listItem = { label: key, value: key + '-' + result[key] };
                    if(this.tableColumns.length>0){
                        this.tableColumns.forEach(result=>{
                            if(key == result.label){
                                listItem.checked = result.checked;
                                if(result.typeAttributes){
                                    listItem.disabled = true;
                                }
                            }
                        })
                    }
                    this.fieldList.push(listItem);
                }
                this.showFields = true;

            }
        ).catch(error=>{
            console.log(error);
        })
    }

    /**
     * @description       : Handles column behavior. Insert, Update and Remove from the list
     * @param             : event
     * @return            : Array
    **/
    handleColumnList(event){
        const dataSelected = event.target.value
        const addElement = event.detail.checked
        var newElement;
        const splittedData = dataSelected.split('-')
        if(this.tableColumns.length>0){
            this.tableColumns.forEach((element, index) =>{
                if(addElement && element.label != splittedData[0] && element.fieldName != splittedData[1]){  
                    newElement = true;
                } else {
                    newElement = false;
                }

                if(!addElement && element.label == splittedData[0] && element.fieldName == splittedData[1]){
                    this.tableColumns.splice(index, 1);
                }
            })
            if(newElement){
                this.tableColumns.push({ label: splittedData[0], fieldName: splittedData[1], type:"String", checked:true, objectname:this.objectName});

            }

        }
        this.handleSave();
    }

    /**
     * @description       : Handles link behavior. Insert, Update and Remove from the list
     * @param             : event
     * @return            : Array
    **/
    onLabelSelection(event){
        const dataSelected = event.detail.value;
        var mainColumn;
        const splittedData = dataSelected.split('-')
        if(this.tableColumns.length > 1){
            this.tableColumns[0].label = splittedData[0];
            this.tableColumns[0]['typeAttributes'].label.fieldName = splittedData[1];
            this.tableColumns  = [...this.tableColumns]

        } else {
            mainColumn  = { label: splittedData[0], fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: splittedData[1] }, target: '_top'}, checked:true, disabled: true, objectname:this.objectName}

            this.tableColumns.push(mainColumn);
        }
        this.showChekbox = true;
        this.handleSave();

    }

    /**
     * @description       : Fire event in order to update the list Composer and retrieve fresh data and design
     * @param             : none
     * @return            : Custom Event
    **/
    handleSave(){
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: {value:JSON.stringify(this.tableColumns)}
        }))
    }

}