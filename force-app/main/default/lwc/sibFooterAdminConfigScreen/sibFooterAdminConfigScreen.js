import { LightningElement, track,wire} from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Name from '@salesforce/label/c.SIB_Name';
import URL from '@salesforce/label/c.SIB_URL';
import Active from '@salesforce/label/c.SIB_Active';
import Actions from '@salesforce/label/c.SIB_Actions';
import Save from '@salesforce/label/c.SIB_Save';
import Cancel from '@salesforce/label/c.SIB_Cancel';
import New_Sub_Section_Record_Mapping from '@salesforce/label/c.SIB_New_Sub_Section_Record_Mapping';
import Add_New from '@salesforce/label/c.SIB_Add_New';
import Links from '@salesforce/label/c.SIB_Links';
import Sub_Section_Links from '@salesforce/label/c.SIB_Sub_Section_Links';
import Sub_Section_Name from '@salesforce/label/c.SIB_Sub_Section_Name';
import Success_Code from '@salesforce/label/c.SIB_success_code';
import Success from '@salesforce/label/c.SIB_Success';
import Configuration_updated_successfully from '@salesforce/label/c.SIB_Configuration_updated_successfully';
import Configuration_Type_Footer from '@salesforce/label/c.SIB_Configuration_Type_Footer';
import Error_Code from '@salesforce/label/c.SIB_Error_Code';
import Error from '@salesforce/label/c.SIB_Error';
import Sort_Order from '@salesforce/label/c.SIB_Sort_Order';

export default class SibFooterAdminConfigScreen extends LightningElement {
    
    @track config = {};

    @track configObjectsList = [];

    activeSections = ['topSection'];

    @track topSectionFieldMappings = [];

    @track middleSectionFieldMappings = [];

    @track bottomSectionFieldMappings = [];

    @track isShowModal = false;
    
    @track inputLabel = '';
    @track inputURL = '';
    @track inputStatus = false;

    @track addToWhichSectionName = '';
    @track addToWhichSubSectionName = '';
    @track subSectionIndex = '';
    @track totalRecordsIndex = 0;

    label = {
        Name: Name,
        URL: URL,
        Active: Active,
        Actions: Actions,
        Save: Save,
        Cancel: Cancel,
        New_Sub_Section_Record_Mapping: New_Sub_Section_Record_Mapping,
        Add_New: Add_New,
        Links: Links,
        Sub_Section_Links: Sub_Section_Links,
        Sub_Section_Name: Sub_Section_Name,
        Success_Code: Success_Code,
        Success: Success,
        Configuration_updated_successfully: Configuration_updated_successfully,
        Configuration_Type_Footer: Configuration_Type_Footer,
        Error_Code: Error_Code,
        Error: Error,
        Sort_Order: Sort_Order
    };

    connectedCallback() {

        this.loadConfig();
    
    }

    async loadConfig() {

        try {
            
            const data = await getConfig({ configType: this.label.Configuration_Type_Footer });
            
            if (data) {

                this.config = JSON.parse(data);

                let sections = ['topSection', 'middleSection', 'bottomSection'];

                sections.forEach(sectionName => {

                    let sectionConfig = this.config[sectionName];

                    if (sectionConfig) {
                        
                        let sectionObj = {
                            sectionName: sectionName,
                            sectionLabel: this.generateLabel(sectionName),
                            individuals:this.extractIndividualFields(sectionConfig,true),
                            subsections: [],
                            records: []
                        };

                        if (sectionName === 'topSection' && sectionConfig.subsections) {

                            sectionConfig.subsections.sort((a, b) => a.sortOrder - b.sortOrder);

                            sectionConfig.subsections.forEach((subsection, index) => {
                                
                                let increaseCounter = index + 1;
                                let subsectionObj = {
                                    subsectionName: subsection.SubsectionName,
                                    label: 'Sub Section Column: '+ increaseCounter,
                                    individuals:this.extractIndividualFields(subsection,false),
                                    records: []
                                };

                                let recordsArray = [];

                                // Sort records by sortOrder
                                recordsArray = subsection.records.sort((a, b) => a.sortOrder - b.sortOrder)
                                    .map(record => this.generateTableRow(record));

                                subsectionObj.records = recordsArray.map(record => {
                                    return {
                                        label: record.find(r => r.label === 'Label')?.value || '',
                                        url: record.find(r => r.label === 'URL')?.value || '',
                                        sortOrder: record.find(r => r.label === 'sortOrder')?.value || 0,
                                        isActive: record.find(r => r.label === 'Active')?.value || false
                                    };
                                });

                                sectionObj.subsections.push(subsectionObj);
                            
                            });

                        } else if (sectionName === 'middleSection' || sectionName === 'bottomSection') {

                            // Sort records by sortOrder
                            sectionConfig.records.sort((a, b) => a.sortOrder - b.sortOrder).forEach(record => {

                                sectionObj.records.push({
                                    label: record.Label || '',
                                    url: record.URL || '',
                                    sortOrder: record.sortOrder || 0,
                                    isActive: record.Active || false,
                                });
                            });
                            
                        }

                        this.configObjectsList.push(sectionObj);
                    }
                });
            }

        } catch (error) {
            console.error('Error loading config:', error);
        }

    }

    generateLabel(key){
        const words = key.split(/(?=[A-Z])/);
        const capitalizedWords = words.map(word => word.charAt(0).toUpperCase() + word.slice(1));
        const label = capitalizedWords.join(' ');
        
        return label;
    }
    
    extractIndividualFields(sectionConfig, isParentConfig) {
        return Object.entries(sectionConfig)
            .filter(([key, value]) => {
                if (isParentConfig) {
                    
                    return !Array.isArray(value) && typeof value !== 'object' && key !== 'sortOrder';
                } else {
                    
                    return !Array.isArray(value) && typeof value !== 'object' && (key !== 'isSocialMediaSubSection' && key !== 'SubsectionName');
                }
            })
            .map(([key, value]) => {
                let type = typeof value;
                return {
                    label: this.generateLabel(key),
                    name: key,
                    value: value,
                    type: type,
                    isCheckbox: type === 'boolean',
                    isNumber: type === 'number',
                    isText: type === 'string',
                    isCombobox: false // Adjust if needed
                };
            });
    }
    
    generateTableRow(record) {
        const orderedKeys = ['Label', 'URL','sortOrder', 'Active'];
        return orderedKeys.map(key => {
            let value = record[key];
            let type = typeof value;
            let isCheckbox = type === 'boolean';
            let isCombobox = false;
    
            return {
                label: key,
                value: value,
                type: type,
                isCheckbox: isCheckbox,
                isCombobox: isCombobox
            };
        });
    }

    handleSubSectionNameConfigChange(event){
        const parentSection = event.target.dataset.parentSection;
        const index = event.target.dataset.index;
        if(parentSection === 'topSection'){
            this.config.topSection.subsections[index].SubsectionName = event.target.value;
        }
    }

    handleInvidualSectionConfigChange(event){
        const key = event.target.dataset.id;
        const parentSection = event.target.dataset.section;
        const childSection = event.target.dataset.subSection;
        const type = event.target.dataset.type;
        let value = type === 'boolean' ? event.target.checked : event.target.value;
        console.log('key:'+key);
        console.log('parentSection:'+parentSection);
        console.log('childSection:'+childSection);
        console.log('type:'+type);
        console.log('value:'+value);
        if (value === null || value === undefined) {
            // Skip processing if value is null or undefined
            return;
        }
        
        if (childSection) {
            this.config[parentSection].subsections = this.config[parentSection].subsections.map(subsection => {
                if (subsection.SubsectionName === childSection && key==='sortOrder') {
                    return { ...subsection, [key]: parseInt(value) };
                }
                return subsection;
            });
        }else{
            this.config[parentSection][key] = value;
        }
        console.log('handleInvidualSectionConfigChange: this.config:'+JSON.stringify(this.config));
    }

    handleSubsectionRecordChange(event) {
        const parentSection = event.target.dataset.parentSection;
        const parentIndex = event.target.dataset.parentIndex;
        const recordIndex = event.target.dataset.recordIndex;
        const nameOfProperty = event.target.dataset.name;
        const value = nameOfProperty === 'Active' ? event.target.checked : nameOfProperty === 'sortOrder' ? parseInt(event.target.value) : event.target.value;
    
        if (value === null || value === undefined) {
            return; // Skip processing if value is null or undefined
        }

        if(parentSection === 'topSection'){
            this.config.topSection.subsections[parentIndex].records[recordIndex][nameOfProperty] = value;
        }else if(parentSection === 'middleSection'){
            this.config.middleSection.records[recordIndex][nameOfProperty] = value;
        }else if(parentSection === 'bottomSection'){
            this.config.bottomSection.records[recordIndex][nameOfProperty] = value;
        }

        console.log('handleSubsectionRecordChange: this.config:'+JSON.stringify(this.config));
    }
    
    handleDelete(event) {
    
        const parentIndex = event.target.dataset.parentIndex;
        const recordIndex = event.target.dataset.recordIndex;
        const parentSection = event.target.dataset.parentSection;
        
        if(parentSection === 'topSection'){
            
            // Retrieve and update the correct subsection's records in configObjectsList
            let rowsList = this.configObjectsList.find(section => section.sectionName === 'topSection')
                    .subsections[parentIndex].records;
            rowsList.splice(recordIndex, 1);  // Remove the record from configObjectsList

            // Reflect the change back to the configObjectsList
            this.configObjectsList.find(section => section.sectionName === 'topSection')
            .subsections[parentIndex].records = rowsList;

            // Now update the this.config object
            let rowsConfig = this.config.topSection.subsections[parentIndex].records;
            rowsConfig.splice(recordIndex, 1);  // Remove the record from config

            // Reflect the change back to the config
            this.config.topSection.subsections[parentIndex].records = rowsConfig;


        }else if (parentSection === 'middleSection') {
            // Handle deletion for middleSection
            let rowsList = this.configObjectsList.find(section => section.sectionName === 'middleSection').records;
    
            rowsList.splice(recordIndex, 1);  // Remove the record from configObjectsList
    
            this.configObjectsList.find(section => section.sectionName === 'middleSection').records = rowsList;
    
            // Update config for middleSection
            this.config.middleSection.records.splice(recordIndex, 1);
    
        } else if (parentSection === 'bottomSection') {
            // Handle deletion for bottomSection
            let rowsList = this.configObjectsList.find(section => section.sectionName === 'bottomSection').records;
    
            rowsList.splice(recordIndex, 1);  // Remove the record from configObjectsList
    
            this.configObjectsList.find(section => section.sectionName === 'bottomSection').records = rowsList;
    
            // Update config for bottomSection
            this.config.bottomSection.records.splice(recordIndex, 1);
        }
        // Call the handleSave method
        this.handleSave();
    }

    showModalBox(event) {

        this.addToWhichSectionName = event.target.dataset.section; //topSection
        this.addToWhichSubSectionName = event.target.dataset.subSection; //About Us
        this.subSectionIndex = event.target.dataset.subSectionIndex;
        this.totalRecordsIndex = event.target.dataset.totalRecords;
        this.isShowModal = true;
    }

    hideModalBox() {
        
        this.isShowModal = false;

        this.addToWhichSectionName = '';
        this.addToWhichSubSectionName = '';
        this.subSectionIndex = '';
        this.totalRecordsIndex = 0;
    }

    handleInputChange(event) {
        const id = event.target.dataset.id;
        const { value,checked } = event.target;
        if (id === 'inputLabel') {
            this.inputLabel = value;    
        }else if (id === 'inputURL') {
            this.inputURL = value;
        } else if (id === 'inputStatus') {
            this.inputStatus = checked;
        }
    }

    addNewRow(event){
        if(this.inputLabel!=''){
            const newRowObject = {
                "Label": this.inputLabel,
                "URL": this.inputURL,
                "sortOrder": this.totalRecordsIndex+1,
                "Active": this.inputStatus               
            };

            if(this.addToWhichSectionName === 'topSection'){
                this.config.topSection.subsections[this.subSectionIndex].records.push(newRowObject);
            }else if(this.addToWhichSectionName === 'middleSection'){
                this.config.middleSection.records.push(newRowObject);
            }else if(this.addToWhichSectionName === 'bottomSection'){
                this.config.bottomSection.records.push(newRowObject);
            }

            this.handleSave();
        }
    }

    handleSave(event) {

        const keyOrder = Object.keys(this.config);

        console.log('Update config: '+JSON.stringify(this.config));

        updateConfig({ configStr: JSON.stringify(this.config),keyOrder: JSON.stringify(keyOrder),configId:this.label.Configuration_Type_Footer})
            .then(result => {
                if (result.status === this.label.Success_Code) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.Success,
                            message: this.label.Configuration_updated_successfully,
                            variant: this.label.Success
                        })
                    );
                    if(this.isShowModal){
                        this.hideModalBox();
                    }
                    this.config = {};
                    this.configObjectsList = [];
                    this.loadConfig();
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.Error,
                            message: result.message,
                            variant: this.label.Error_Code
                        })
                    );
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Error,
                        message: error,
                        variant: this.label.Error_Code
                    })
                );
            });
    }

    handleCancel() {
        this.config = {};
        this.configObjectsList = [];
        this.loadConfig();
    }
}