import { LightningElement, track,wire} from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import getProductFields from '@salesforce/apex/SIB_ConfigController.getProductFields';
import getSIBRelatedProductTypePicklistValues from '@salesforce/apex/SIB_ConfigController.getSIBRelatedProductPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SibPdpAdminConfigScreen extends LightningElement {
    @track config = {};
    
    activeSections = ['individualConfigs', 'MappingConfigs'];
    
    @track tierPricingConfigFields = [];

    @track configObjectsList = [];

    @track customPDP = false;

    originalKeyOrder = [];

    @track productfieldAPINameOptions = [];
    @track relatedfieldAPINameOptions = [];
    pageSectionStyleOptions = [
        { label: 'accordion', value: 'accordion'},
        { label: 'tab',value: 'tab'}
    ];

    @track isShowTierPricingModal = false;
    @track isShowRelatedTypeProductConfigModal = false;
    @track isShowPageSectionConfigModal = false;

    @track inputTierPricingConfigName = '';
    @track inputTierPricingConfigValue = '';

    @track inputDisplayName = '';
    @track inputApiName = '';

    @track rowIndexForRelatedType;
    @track rowIndexForPageSection;

    @track inputTitle = '';
    @track inputApiNameForPageSection = '';
    @track inputFieldApiNameForPageSection = '';
    @track inputShowOnlyIfApplicable = false;

    @wire(getProductFields)
    wiredProductFields({ error, data }) {
        if (data) {
            this.productfieldAPINameOptions = Object.keys(data).map(apiName => ({ label: apiName+' ('+data[apiName]+')', value: apiName,fieldLabel:data[apiName]}));
        } else if (error) {
            console.error('Error fetching Product2 fields:', error);
        }
    }

    @wire(getSIBRelatedProductTypePicklistValues)
    wiredRelatedProductTypePicklistValues({ error, data }) {
        if (data) {
            this.relatedfieldAPINameOptions = data;
        } else if (error) {
            console.error('Error fetching SIB related Product fields:', error);
        }
    }

    connectedCallback() {
        this.loadConfig();
    }

    async loadConfig() {
        try {
            const data = await getConfig({configType:'PDP'});
            if (data) {

                this.config = JSON.parse(data);

                // Store original order of keys when component initializes
                this.originalKeyOrder = Object.keys(this.config);

                this.customPDP = this.config.customPDP;
                
                this.config.productTypeList.forEach((product, index) => {

                    let rowObj = {};
                    
                    let labelValuePairs = [];

                    const productKeys = Object.keys(product).filter(key => key != 'relatedProductTypes' && key != 'pageSections');
                    
                    productKeys.forEach(key => {
                        let layoutLevelOne = false;
                        let layoutLevelTwo = false;
                        let layoutLevelThree = false;

                        let isCheckbox = false;
                        let isCombobox = false;

                        if(key!='productType'){  // The Product Type config will be hidden to the user but will remain in the config so later to differentiate between simple, variation products etc
                            if(key==='productType' || key==='shortDescriptionField'){
                                layoutLevelOne = true;
                            }else if(key==='displayPromotionalPrice' || key==='displayRelatedProduct'){
                                layoutLevelTwo = true;
                            }else if(key==='displayPageSections' || key==='pageSectionStyle'){
                                layoutLevelThree = true;
                            }
                            const name = key;
                            const words = key.split(/(?=[A-Z])/);
                            const capitalizedWords = words.map(word => word.charAt(0).toUpperCase() + word.slice(1));
                            const label = capitalizedWords.join(' ');
                            const value = product[key];
                            let type = 'text';
                            if(typeof value==='boolean'){
                                type = 'checkbox';
                                isCheckbox = true;
                                isCombobox = false;
                            }
                            if(key==='pageSectionStyle'){
                                type = 'combobox';
                                isCombobox = true;
                                isCheckbox = false;
                            }
                            const pair = { label, value,name,layoutLevelOne,layoutLevelTwo,layoutLevelThree,type,isCheckbox,isCombobox };
                            labelValuePairs.push(pair);
                        }
                        
                    });
                    console.log('labelValuePairs:'+JSON.stringify(labelValuePairs));
                    rowObj.indvidualConfigs = labelValuePairs;
                    
                    rowObj.accordianName = 'Product Type Config : '+product.productType;

                    let labelValuePairsForTierPricingConfig = {};
                    if(product.tierPricingConfig) {
                      
                      Object.entries(product.tierPricingConfig).forEach(([key, value]) => {
                        
                        const name = key;
                        const words = key.split(/(?=[A-Z])/);
                        const capitalizedWords = words.map(word => word.charAt(0).toUpperCase() + word.slice(1));
                        const label = capitalizedWords.join(' ');
                        let isCheckbox = false;
                        let type = 'text';
                        if(typeof value==='boolean'){
                            isCheckbox = true;
                            type = 'checkbox';
                        }
                        if (!labelValuePairsForTierPricingConfig[label]) {
                            labelValuePairsForTierPricingConfig[label] = {
                            label,
                            name,
                            value,
                            isCheckbox,
                            type
                          };
                        }
                      });
                    }

                    if(!this.isObjectEmpty(labelValuePairsForTierPricingConfig)){
                        rowObj.tierPricingConfigFields = Object.values(labelValuePairsForTierPricingConfig);
                    }else{
                        rowObj.tierPricingConfigFields = [];
                    }
                    //console.log('rowObj.tierPricingConfigFields:'+JSON.stringify(rowObj.tierPricingConfigFields));

                    rowObj.displayPromotionalPrice = product.displayPromotionalPrice;
                    rowObj.displayRelatedProduct = product.displayRelatedProduct;

                    let relatedProductTypesArray = [];

                    if (product.relatedProductTypes) {
                        product.relatedProductTypes.forEach(relatedProductType => {
                            let labelValuePairsForRelatedTypeConfig = {};
                            Object.entries(relatedProductType).forEach(([key, value]) => {
                        
                                const name = key;
                                const words = key.split(/(?=[A-Z])/);
                                const capitalizedWords = words.map(word => word.charAt(0).toUpperCase() + word.slice(1));
                                const label = capitalizedWords.join(' ');
                                let isCheckbox = false;
                                let isCombobox = false;
                                let type = 'text';
                                if(typeof value==='boolean'){
                                    isCheckbox = true;
                                    type='checkbox';
                                }
                                if(name==='apiName'){
                                    isCombobox = true;
                                    type = 'combobox';
                                }
                                if (!labelValuePairsForRelatedTypeConfig[label]) {
                                    labelValuePairsForRelatedTypeConfig[label] = {
                                    label,
                                    name,
                                    value,
                                    isCheckbox,
                                    isCombobox,
                                    type
                                  };
                                }
                            });
                     
                            let objWithoutKey = Object.values(labelValuePairsForRelatedTypeConfig);
                            if(!this.isObjectEmpty(objWithoutKey)){
                                relatedProductTypesArray.push(objWithoutKey);
                            }
                        });
                        
                    }

                    if(relatedProductTypesArray!=null){
                        rowObj.relatedProductTypes = relatedProductTypesArray;
                    }else{
                        rowObj.relatedProductTypes = [];
                    }
                    //console.log('rowObj.relatedProductTypes:'+JSON.stringify(rowObj.relatedProductTypes));

                    rowObj.displayPageSections = product.displayPageSections;
                    rowObj.pageSectionStyle = product.pageSectionStyle;

                    let pageSectionsArray = [];
                    
                    if (product.pageSections) {
                    

                        product.pageSections.forEach(pageSection => {

                            console.log('pageSection:'+JSON.stringify(pageSection));

                            let labelValuePairsForPageSectionConfig = {};
                            
                            let pageSectionName = pageSection.apiName;

                            Object.entries(pageSection).forEach(([key, value]) => {
                        
                                const name = key;
                                const words = key.split(/(?=[A-Z])/);
                                const capitalizedWords = words.map(word => word.charAt(0).toUpperCase() + word.slice(1));
                                
                                let label = '';
                                let isCheckbox = false;
                                let isCombobox = false;
                                let type = 'text';
                                let apiNameDisabled = false;
                                let hideFieldAPINameInput = false;

                                if(pageSectionName==='quantity-discount'){
                                    if(key==='fieldAPIName'){
                                        hideFieldAPINameInput = true;
                                    }else if(key==='apiName'){
                                        apiNameDisabled = true;
                                    }
                                }
                                
                                console.log('key:'+key+'<-->'+'value:'+value);
                                
                                if(name!='fieldAPIName'){
                                    label = capitalizedWords.join(' ');
                                }else{
                                    label = 'Field API Name';
                                    isCombobox = true;
                                    isCheckbox = false;
                                    type = 'combobox';
                                }

                                if(typeof value==='boolean'){
                                    type = 'checkbox';
                                    isCheckbox = true;
                                }
                                
                                if (!labelValuePairsForPageSectionConfig[label]) {
                                    labelValuePairsForPageSectionConfig[label] = {
                                    label,
                                    name,
                                    value,
                                    isCheckbox,
                                    isCombobox,
                                    type,
                                    apiNameDisabled,
                                    hideFieldAPINameInput
                                  };
                                }
                                console.log('labelValuePairsForPageSectionConfig[label]:'+JSON.stringify(labelValuePairsForPageSectionConfig[label]));
                            });
                            let objWithoutKey = Object.values(labelValuePairsForPageSectionConfig);
                            if(!this.isObjectEmpty(objWithoutKey)){
                                pageSectionsArray.push(objWithoutKey);
                            }
                            
                        });
                    }

                    if(pageSectionsArray!=null){
                        rowObj.pageSections = pageSectionsArray;
                    }else{
                        rowObj.pageSections = [];
                    }
                    //console.log('rowObj.pageSections:'+JSON.stringify(rowObj.pageSections));

                    //console.log('rowObj:'+JSON.stringify(rowObj));
                    this.configObjectsList.push(rowObj);
                });

                //console.log('this.configObjectsList:'+JSON.stringify(this.configObjectsList));

            }
        } catch (error) {
            console.error('Error loading config:', error);
        }
    }

    isObjectEmpty(obj) {
        return Object.keys(obj).length === 0;
    }
    handleIndividualConfigChange(event){
        const key = event.target.dataset.id;
        this.config[key] = event.target.checked;
    }
    handleProductTypeConfigChange(event) {
        const key = event.target.dataset.id;
        const type  = event.target.dataset.type;
        const rowIndex = event.target.dataset.rowIndex;

        const individualConfig = this.config.productTypeList[rowIndex];

        if (individualConfig) {
            // Iterate over each key-value pair in tierPricingConfig
            Object.entries(individualConfig).forEach(([fieldName, fieldValue]) => {
                // Check if the current field name matches the desired key
                if (fieldName === key) {
                    // Handle the field based on its type (checkbox or input)
                    if (type === 'checkbox') {
                        individualConfig[fieldName] = event.target.checked;
                    } else {
                        individualConfig[fieldName] = event.target.value;
                    }
                }
            });
        }
        
    }

    handleTierPricingConfigChange(event) {

        const key = event.target.dataset.id;
        const type = event.target.dataset.type;
        const rowIndex = event.target.dataset.rowIndex;
        const tierPricingConfig = this.config.productTypeList[rowIndex].tierPricingConfig;
        if (tierPricingConfig) {
            // Iterate over each key-value pair in tierPricingConfig
            Object.entries(tierPricingConfig).forEach(([fieldName, fieldValue]) => {
                // Check if the current field name matches the desired key
                if (fieldName === key) {
                    // Handle the field based on its type (checkbox or input)
                    if (type === 'checkbox') {
                        tierPricingConfig[fieldName] = event.target.checked;
                    } else {
                        tierPricingConfig[fieldName] = event.target.value;
                    }
                }
            });
        }
    }
    
    handlePageSectionStyleConfigChange(event) {

        const key = event.target.dataset.id;
        const rowIndex = event.target.dataset.rowIndex;

        const individualConfig = this.config.productTypeList[rowIndex];

        if (individualConfig) {
            
            Object.entries(individualConfig).forEach(([fieldName, fieldValue]) => {
                // Check if the current field name matches the desired key
                if (fieldName === key) {

                    let selectedValue = event.detail.value;

                    const selectedOption = this.pageSectionStyleOptions.find(option => option.value === selectedValue);
                    if (selectedOption) {
                        individualConfig[fieldName] = selectedOption.value;
                    }
                }
            });
        }
    }

    handleRelatedTypesConfigChange(event) {

        const key = event.target.dataset.id;
        
        const type = event.target.dataset.type;

        const rowIndex = event.target.dataset.rowIndex;

        const innerRowIndex = event.target.dataset.innerRowIndex;
        
        const relatedProductTypes = this.config.productTypeList[rowIndex].relatedProductTypes;

        if (relatedProductTypes) {

            let currentObj = this.config.productTypeList[rowIndex].relatedProductTypes[innerRowIndex];

            // Iterate over each key-value pair in tierPricingConfig
            Object.entries(currentObj).forEach(([fieldName, fieldValue]) => {
                // Check if the current field name matches the desired key
                if (fieldName === key) {
                    // Handle the field based on its type (checkbox or input)
                    if (type === 'checkbox') {
                        currentObj[fieldName] = event.target.checked;
                    } else if(type==='combobox'){
                        let selectedValue = event.detail.value;
                        const selectedOption = this.relatedfieldAPINameOptions.find(option => option.value === selectedValue);
                        if (selectedOption) {
                            currentObj[fieldName] = selectedOption.value;
                        }
                        
                    } else {
                        currentObj[fieldName] = event.target.value;
                    }
                }
            });
        }
    }

    handlePageSectionsConfigChange(event) {

        const key = event.target.dataset.id;

        const type = event.target.dataset.type;

        const rowIndex = event.target.dataset.rowIndex;

        const innerRowIndex = event.target.dataset.innerRowIndex;
        
        const pageSections = this.config.productTypeList[rowIndex].pageSections;

        if (pageSections) {

            let currentObj = this.config.productTypeList[rowIndex].pageSections[innerRowIndex];

            // Iterate over each key-value pair in tierPricingConfig
            Object.entries(currentObj).forEach(([fieldName, fieldValue]) => {
                // Check if the current field name matches the desired key
                if (fieldName === key) {
                    // Handle the field based on its type (checkbox or input)
                    if (type === 'checkbox') {
                        currentObj[fieldName] = event.target.checked;
                    } else if(type==='combobox'){
                        let selectedValue = event.detail.value;
                        const selectedOption = this.productfieldAPINameOptions.find(option => option.value === selectedValue);
                        if (selectedOption) {
                            currentObj[fieldName] = selectedOption.value;
                        }
                        
                    } else {
                        currentObj[fieldName] = event.target.value;
                    }
                }
            });

        }        
    }

    showRelatedTypeConfigModalBox(event){

        this.isShowRelatedTypeProductConfigModal = true;
        this.rowIndexForRelatedType = event.target.dataset.rowIndex;

    }

    showPageSectionConfigModalBox(event){
        this.isShowPageSectionConfigModal = true;
        this.rowIndexForPageSection = event.target.dataset.rowIndex;
    }

    hideRelatedTypeConfigModalBox(event){
        this.isShowRelatedTypeProductConfigModal = false;
        this.inputDisplayName = '';
        this.inputApiName = '';
    }

    hidePageSectionConfigModalBox(event){
        this.isShowPageSectionConfigModal = false;
        this.inputTitle = '';
        this.inputApiNameForPageSection = '';
        this.inputFieldApiNameForPageSection = '';
        this.inputShowOnlyIfApplicable = false;
    }
    
    handleNewRelatedTypeProductConfigChange(event){
        const key = event.target.dataset.id;
        if(key==='inputApiName'){
            this.inputApiName = event.detail.value;
        }else if(key==='inputDisplayName'){
            this.inputDisplayName = event.detail.value;
        }
    }

    handleNewPageSectionConfigChange(event){
        const key = event.target.dataset.id;
        if(key==='inputFieldApiNameForPageSection'){
            this.inputFieldApiNameForPageSection = event.detail.value;
        }else if(key==='inputApiNameForPageSection'){
            this.inputApiNameForPageSection = event.detail.value;
        }else if(key==='inputTitle'){
            this.inputTitle = event.detail.value;
        }else if(key==='inputShowOnlyIfApplicable'){
            this.inputShowOnlyIfApplicable = event.target.checked;
        }
    }

    addNewRelatedTypeConfig(event){
        if(this.inputApiName!='' && this.inputDisplayName!=''){
            const newRowObject = {
                "apiName": this.inputApiName,
                "displayName": this.inputDisplayName
            };
            this.config.productTypeList[this.rowIndexForRelatedType].relatedProductTypes.push(newRowObject);
            this.hideRelatedTypeConfigModalBox();
            this.handleSave();
        }
    }

    addNewPageSectionConfig(event){
        if(this.inputFieldApiNameForPageSection!='' && this.inputApiNameForPageSection!='' && this.inputTitle!=''){
            const newRowObject = {
                "title": this.inputTitle,
                "apiName": this.inputApiNameForPageSection,
                "fieldAPIName": this.inputFieldApiNameForPageSection,
                "showOnlyWhenApplicable": this.inputShowOnlyIfApplicable
            };
            this.config.productTypeList[this.rowIndexForPageSection].pageSections.push(newRowObject);
            this.hidePageSectionConfigModalBox();
            this.handleSave();
        }
    }

    deleteTierPricingConfig(event){

        const rowIndex = event.target.dataset.rowIndex;

        const fieldIndex = event.target.dataset.fieldIndex;

        if (this.configObjectsList[rowIndex] && this.configObjectsList[rowIndex].tierPricingConfigFields) {
            this.configObjectsList[rowIndex].tierPricingConfigFields.splice(fieldIndex, 1);
        }

        const tierPricingConfigFields = this.configObjectsList[rowIndex].tierPricingConfigFields;

        let transformedObject = {};
        if(tierPricingConfigFields!=null){
            transformedObject = tierPricingConfigFields.reduce((acc, field) => {
                acc[field.name] = field.value;
                return acc;
            }, {});   
        }
        this.config.productTypeList[rowIndex].tierPricingConfig = transformedObject;
        
        console.log('transformedObject:'+JSON.stringify(transformedObject));
        this.handleSave();
    }

    deleteRelatedTypeConfig(event){
        const rowIndex = event.target.dataset.rowIndex;

        const fieldIndex = event.target.dataset.fieldIndex;

        if (this.configObjectsList[rowIndex] && this.configObjectsList[rowIndex].relatedProductTypes) {
            this.configObjectsList[rowIndex].relatedProductTypes.splice(fieldIndex, 1);
        }

        const relatedProductTypes = this.configObjectsList[rowIndex].relatedProductTypes;

        // Transform the array
        const transformedArray = relatedProductTypes.map(innerArray => {
            const transformedObject = {};
            innerArray.forEach(field => {
                transformedObject[field.name] = field.value;
            });
            return transformedObject;
        });
    
        this.config.productTypeList[rowIndex].relatedProductTypes = transformedArray;
    
        this.handleSave();
    }

    deletePageSectionConfig(event){
        const rowIndex = event.target.dataset.rowIndex;

        const fieldIndex = event.target.dataset.fieldIndex;

        if (this.configObjectsList[rowIndex] && this.configObjectsList[rowIndex].pageSections) {
            this.configObjectsList[rowIndex].pageSections.splice(fieldIndex, 1);
        }

        const pageSections = this.configObjectsList[rowIndex].pageSections;

        // Transform the array
        const transformedArray = pageSections.map(innerArray => {
            const transformedObject = {};
            innerArray.forEach(field => {
                transformedObject[field.name] = field.value;
            });
            return transformedObject;
        });
        
        this.config.productTypeList[rowIndex].pageSections = transformedArray;
        
        this.handleSave();
    }

    handleSave() {
        console.log('New Config Object to update:'+JSON.stringify(this.config));

        // Recreate JSON object with original order of keys
        const updatedConfigData = {};

        this.originalKeyOrder.forEach(key => {
            
            updatedConfigData[key] = this.config[key];
        
        });

        // Extract the keys from this.config to maintain the order
        const keyOrder = Object.keys(this.config);
        console.log('keyOrder:'+JSON.stringify(keyOrder));

        updateConfig({ configStr: JSON.stringify(updatedConfigData),keyOrder: JSON.stringify(keyOrder),configId:'PDP'})
            .then(result => {
                if (result.status === 'success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Configuration updated successfully',
                            variant: 'success'
                        })
                    );

                    this.config = {};
                    this.configObjectsList = [];
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
        this.configObjectsList = [];
        this.loadConfig();
    }
}