import { LightningElement,wire,track} from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import getProductFields from '@salesforce/apex/SIB_ConfigController.getProductFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SibPlpAdminConfigScreen extends LightningElement {
    @track config;

    activeSections = ['individualConfigs', 'cardContentMappingsConfig'];

    @track cardContentMappingFields = [];

    @track isShowModal = false;
    @track inputName = '';
    @track inputShowLabel = false;
    @track inputLabel = '';

    @track viewOptionsButtonText = '';
    @track showProductImage = false;
    @track showOriginalPrice = false;
    @track showNegotiatedPrice = false;
    @track showLayoutButtons = false;
    @track showCallToActionButton = false;
    @track gridMaxColumnsDisplayed;
    @track searchResultsPageSize; //Gaurang Arora - 12 Sep 2024
    @track selfStudyPageSize; //Gaurang Arora - 12 Sep 2024
    @track addToCartButtonText = '';
    @track unavailablePriceText = '';
    @track addToCartButtonStyle = '';
    @track addToCartButtonProcessingText = '';
    @track availableLayouts = [];

    layoutOptions = [
        { label: 'list', value: 'list', checked: false },
        { label: 'grid', value: 'grid', checked: false }
    ];

    @track selectedLayoutOptions = [];

    @track defaultViewOptions = [];

    @track fieldOptions = [];
    @track fieldOptionsForNewMapping = [];

    @track selectedFieldOptions = [];

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

            const data = await getConfig({configType:'PLP'});
            
            if (data) {

                this.config = JSON.parse(data);

                this.viewOptionsButtonText = this.config.viewOptionsButtonText?this.config.viewOptionsButtonText:'';
                this.showProductImage = this.config.showProductImage?this.config.showProductImage:false;
                this.showOriginalPrice = this.config.showOriginalPrice?this.config.showOriginalPrice:false;
                this.showNegotiatedPrice = this.config.showNegotiatedPrice?this.config.showNegotiatedPrice:false;
                this.showLayoutButtons = this.config.showLayoutButtons?this.config.showLayoutButtons:false;
                this.showCallToActionButton = this.config.showCallToActionButton?this.config.showCallToActionButton:false;
                this.gridMaxColumnsDisplayed = this.config.gridMaxColumnsDisplayed?this.config.gridMaxColumnsDisplayed:3;
                this.searchResultsPageSize = this.config.searchResultsPageSize?this.config.searchResultsPageSize:1;
                this.selfStudyPageSize = this.config.selfStudyPageSize?this.config.selfStudyPageSize:1;
                this.addToCartButtonText = this.config.addToCartButtonText?this.config.addToCartButtonText:'';
                this.unavailablePriceText = this.config.unavailablePriceText?this.config.unavailablePriceText:'';
                this.addToCartButtonStyle = this.config.addToCartButtonStyle?this.config.addToCartButtonStyle:'';
                this.addToCartButtonProcessingText = this.config.addToCartButtonProcessingText?this.config.addToCartButtonProcessingText:'';
                this.selectedLayoutOptions = this.config.availableLayouts?this.config.availableLayouts:[];
                this.defaultViewOptions = [];
                if (this.selectedLayoutOptions) {
                    this.selectedLayoutOptions.forEach(layout => {
                        this.defaultViewOptions.push({ label: layout, value: layout });
                    });
                }
                this.selectedFieldOptions = this.config.searchResultsFields;

                this.defaultViewOptions.forEach(option => {
                    option.checked = option.value === this.config.defaultView;
                });
                
                Object.keys(this.config.cardContentMapping).forEach(key => {

                    let innerObjectKeyValuePairs = this.config.cardContentMapping[key];
                    
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
                        this.cardContentMappingFields.push({ label:label,name: innerKey,parent:'cardContentMapping', value: innerObjectKeyValuePairs[innerKey], type: typeof innerObjectKeyValuePairs[innerKey],originalType:typeof innerObjectKeyValuePairs[innerKey],isCheckbox:isCheckbox,isReadOnly:isReadOnly});
                    
                    });
                    
                });
                //console.log('this.cardContentMappingFields:'+JSON.stringify(this.cardContentMappingFields));
            }
            this.options = this.layoutOptions.map(option => {

                option.checked = this.config.availableLayouts.includes(option.value);
                return option;
            });
            //console.log('this.options:'+this.options);
        } catch (error) {
            console.error('Error loading config:', error);
        }
    }

    get rowsOfArrayObjects() {
        let lstOfProperties = [];

        for (let i = 0; i < this.cardContentMappingFields.length; i += 3) {

            let row = [];

            let showLabelProperty = this.cardContentMappingFields[i];
            if (showLabelProperty) {
                row.push(showLabelProperty);
            }

            let nameProperty = this.cardContentMappingFields[i + 1];
            if (nameProperty) {
                row.key = nameProperty.value;
                row.push(nameProperty);
            }

            let labelProperty = this.cardContentMappingFields[i + 2];
            if (labelProperty) {
                row.push(labelProperty);
            }

            lstOfProperties.push(row);
        }
        //console.log('rowsOfArrayObjects-lstOfProperties:'+JSON.stringify(lstOfProperties));

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
            this.config.cardContentMapping.push(newRowObject);
            this.handleSave();
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
        this.config.cardContentMapping = this.config.cardContentMapping.filter(field => fieldsToAdd.has(field.name));
        this.handleSave();
    }

    handleChange(event) {
        const key = event.target.dataset.id;
        this.config[key] = event.target.value;    
        console.log('this.config[key]:'+this.config[key]);
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

    handleContentMappingChange(event){
        try{
            const key = event.target.dataset.key;
            const parent = event.target.dataset.parent;
            const index = event.target.dataset.index;
            const originalType = event.target.dataset.original;
            //let jsonObject = this.config;
            if (this.config[parent] && this.config[parent][index]) {
                if (originalType === 'boolean') {
                    this.config[parent][index][key] = event.target.checked;
                } else {
                    this.config[parent][index][key] = event.target.value;
                }
            }  
        }catch(e){
            console.log('error is:'+e);
        }
    }

    handleCheckboxChange(event) { 
        const key = event.target.dataset.id;   
        let checkedVal = event.target.checked;
        if(key==='showLayoutButtons'){
            this.showLayoutButtons = checkedVal;
        }
        this.config[key] = checkedVal;
    }
    
    handleDualListboxChange(event) {
        const key = event.target.dataset.key;
        this.config[key] = event.detail.value;
    }

    handleLayoutOptionsChange(event){
        const key = event.target.dataset.id;
        const checkedValue = event.target.value;
        const isChecked = event.target.checked;
        if (isChecked) {
            this.config[key].push(checkedValue);
        } else {
            this.config[key] = this.config[key].filter(value => value !== checkedValue);
        }
    }

    handleDefaultViewChange(event){
        const selectedTargetValue = event.target.value;
        const key = event.target.dataset.id;
        this.config[key] = selectedTargetValue;
    }

    handleSave() {
        console.log('New Config Object to update:'+JSON.stringify(this.config));

        // Extract the keys from this.config to maintain the order
        const keyOrder = Object.keys(this.config);
        console.log('keyOrder:'+JSON.stringify(keyOrder));

        updateConfig({ configStr: JSON.stringify(this.config),keyOrder: JSON.stringify(keyOrder),configId:'PLP'})
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
                    this.cardContentMappingFields = [];
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
        this.config = {};
        this.cardContentMappingFields = [];
        this.loadConfig();
    }
}