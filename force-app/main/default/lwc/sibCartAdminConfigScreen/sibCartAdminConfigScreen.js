import { LightningElement,wire, track} from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import getProductFields from '@salesforce/apex/SIB_ConfigController.getProductFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SibCartAdminConfigScreen extends LightningElement {
    @track config;
    
    activeSections = ['individualConfigs', 'ProductFieldMappingConfig'];

    @track showUniqueCount = false;
    @track showSKU = false;
    @track showSavedAmount = false;
    @track showRemoveItemOption = false;
    @track showProductImage = false;
    @track showPricePerUnit = false;
    @track showOriginalPrice = false;
    @track showMoreItemsOption = false;
    @track showLineItemTotal = false;
    @track showActualPrice = false;
    @track hideQuantitySelector = false;
    @track allowPromoCode = false;

    @track productFields = [];

    @track isShowModal = false;
    @track inputName = '';
    @track inputShowLabel = false;
    @track inputLabel = '';

    @track fieldOptions = [];
    @track selectedFieldOptions = [];
    @track fieldOptionsForNewMapping = [];

    @wire(getProductFields)
    wiredProductFields({ error, data }) {
        if (data) {
            this.fieldOptions = Object.keys(data).map(apiName => ({ label: data[apiName], value: apiName }));
            this.fieldOptionsForNewMapping = Object.keys(data).map(apiName => ({ label: apiName, value: apiName,fieldLabel:data[apiName]}));
        } else if (error) {
            console.error('Error fetching Product2 fields:', error);
        }
    }

    connectedCallback() {
        this.loadConfig();
    }

    async loadConfig() {
        try {

            const data = await getConfig({configType:'CART'});
            
            if (data) {

                this.config = JSON.parse(data);
                
                this.showUniqueCount = this.config.showUniqueCount;
                this.showSKU = this.config.showSKU;
                this.showSavedAmount = this.config.showSavedAmount;
                this.showRemoveItemOption = this.config.showRemoveItemOption;
                this.showProductImage = this.config.showProductImage;
                this.showPricePerUnit = this.config.showPricePerUnit;
                this.showOriginalPrice = this.config.showOriginalPrice;
                this.showMoreItemsOption = this.config.showMoreItemsOption;
                this.showLineItemTotal = this.config.showLineItemTotal;
                this.showActualPrice = this.config.showActualPrice;
                this.hideQuantitySelector = this.config.hideQuantitySelector;
                this.allowPromoCode = this.config.allowPromoCode;
                //this.selectedOptions = this.config.productFields;

                Object.keys(this.config.productFields).forEach(key => {

                    let innerObjectKeyValuePairs = this.config.productFields[key];
                    
                    Object.keys(innerObjectKeyValuePairs).forEach(innerKey => {

                        let isCheckbox = false;
                        if(typeof innerObjectKeyValuePairs[innerKey]==='boolean'){
                            isCheckbox = true;
                        }
                        let label = '';let isReadOnly = false;
                        if(innerKey==='showLabel'){
                            label = 'Show Label';
                        }else if(innerKey==='name'){
                            label = 'Name';
                            isReadOnly = true;
                        }else if(innerKey==='label'){
                            label = 'Label';
                        }
                        this.productFields.push({ label:label,name: innerKey,parent:'productFields', value: innerObjectKeyValuePairs[innerKey], type: typeof innerObjectKeyValuePairs[innerKey],originalType:typeof innerObjectKeyValuePairs[innerKey],isCheckbox:isCheckbox,isReadOnly:isReadOnly});
                    
                    });
                    
                });

            }

        } catch (error) {
            console.error('Error loading config:', error);
        }
    }

    get rowsOfArrayObjects() {
        let lstOfProperties = [];

        for (let i = 0; i < this.productFields.length; i += 3) {

            let row = [];

            let showLabelProperty = this.productFields[i];
            if (showLabelProperty) {
                row.push(showLabelProperty);
            }

            let nameProperty = this.productFields[i + 1];
            if (nameProperty) {
                row.key = nameProperty.value;
                row.push(nameProperty);
            }

            let labelProperty = this.productFields[i + 2];
            if (labelProperty) {
                row.push(labelProperty);
            }

            lstOfProperties.push(row);
        }
        console.log('rowsOfArrayObjects-lstOfProperties:'+JSON.stringify(lstOfProperties));

        return lstOfProperties;
    }
    
    showModalBox() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
        this.inputName = '';
        this.inputShowLabel = false;
        this.inputLabel = '';
    }

    addNewRow(event){
        if(this.inputName!='' && this.inputLabel!=''){
            const newRowObject = {
                "name": this.inputName,
                "showLabel": this.inputShowLabel,
                "label": this.inputLabel
            };
            this.config.productFields.push(newRowObject);
            //console.log('New Config Object to update:'+JSON.stringify(this.config));
            this.handleSave();
        }
    }

    handleInputChange(event) {
        const id = event.target.dataset.id;
        const { value,checked } = event.target;
        if (id === 'inputName') {
            this.inputName = event.detail.value;
            const selectedOption = this.fieldOptionsForNewMapping.find(option => option.value === this.inputName);
            if (selectedOption) {
                this.inputLabel = selectedOption.fieldLabel;
            } else {
                this.inputLabel = '';
            }
        } else if (id === 'inputShowLabel') {
            this.inputShowLabel = checked;
            
        }else if (id === 'inputLabel') {
            this.inputLabel = value;
            
        }
    }

    handleDelete(event){
        const rowIndex = event.target.dataset.index;
        let rows = this.rowsOfArrayObjects;
        rows.splice(rowIndex, 1);
        let fieldsToAdd = new Set();
        rows.forEach(row => {
            row.forEach(field => {
                fieldsToAdd.add(field.value); 
            });
        });
        // Filter productFields to keep only those elements present in fieldsToAdd
        this.config.productFields = this.config.productFields.filter(field => fieldsToAdd.has(field.name));
        this.handleSave();
    }

    handleCheckboxChange(event) { 
        const key = event.target.dataset.id;
        this.config[key] = event.target.checked;
        console.log('handleCheckboxChange:this.config:'+JSON.stringify(this.config));
    }

    handleDualListboxChange(event) {
        const key = event.target.dataset.key;
        this.config[key] = event.detail.value;
        console.log('handleDualListboxChange:this.config:'+JSON.stringify(this.config));
    }

    handleSave() {
        console.log('New Config Object to update:'+JSON.stringify(this.config));

        // Extract the keys from this.config to maintain the order
        const keyOrder = Object.keys(this.config);
        console.log('keyOrder:'+JSON.stringify(keyOrder));

        updateConfig({ configStr: JSON.stringify(this.config),keyOrder: JSON.stringify(keyOrder),configId:'CART'})
        .then(result => {
            if (result.status === 'success') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Configuration updated successfully',
                        variant: 'success'
                    })
                );
                if(this.isShowModal){
                    this.hideModalBox();
                }
                this.config = {};
                this.productFields = [];
                this.loadConfig();
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result.message,
                        variant: 'error'
                    })
                );
                console.error('Error updating config:', result.message);
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error'
                })
            );
            console.error('Error updating config:', error);
        });
    }

    handleCancel() {
        this.loadConfig();
    }
}