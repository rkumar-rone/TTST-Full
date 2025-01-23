import { LightningElement, track} from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SibHomeAdminConfigScreen extends LightningElement {
    @track config;
    originalConfig;

    @track fields = [];
    
    connectedCallback() {
        this.loadConfig();
    }

    async loadConfig() {
        try {
            const data = await getConfig({configType:'home'});
            if (data) {
                this.config = JSON.parse(data);
                this.originalConfig = JSON.parse(JSON.stringify(data));
                Object.keys(this.config).forEach(key => {
                    if(key!='id'){

                        let type = '';let value = null;let originalType = '';let toolTipText=  '';

                        if (Array.isArray(this.config[key]) && this.config[key].length > 0 && typeof this.config[key][0] !== 'object') {
                            type = 'string';
                            originalType = 'array';
                            value = this.config[key].join(',');
                            toolTipText = 'Please enter the values in a comma-separated format, without spaces between values and commas. For example:"value1,value2,value3".';
                            console.log('value:'+value);
                        }else if (Array.isArray(this.config[key]) && this.config[key].length > 0 && typeof this.config[key][0] === 'object') {
                            type = 'object';
                            originalType = 'object';
                            value = this.config[key];
                        }else{
                            type = typeof this.config[key];
                            value = this.config[key];
                            originalType = typeof this.config[key];
                        }
                        this.fields.push({ name: key, value: value, type: type,originalType:originalType,toolTipText:toolTipText });
                        
                    }
                });
                console.log('this.fields:'+JSON.stringify(this.fields));
            }
        } catch (error) {
            console.error('Error loading config:', error);
        }
    }

    get rowsOfStringAndNumbers() {

        let lstOfFields = [];
    
        let filteredFields = this.fields.filter(field => field.type === "string" || field.type === "number");

        for (let i = 0; i < filteredFields.length; i += 2) {

            let currentObject = filteredFields[i];
            let nextObject = filteredFields[i + 1];
            
            let row = [currentObject];
            if (nextObject) {
                row.push(nextObject);
            }
            lstOfFields.push(row);

        }
    
        return lstOfFields; 
    }
    

    get rowsOfCheckboxes() {

        let lstOfFields = [];

        let filteredFields = this.fields.filter(field => field.type === "boolean");

        for (let i = 0; i < filteredFields.length; i += 2) {

            let currentObject = filteredFields[i];
            let nextObject = filteredFields[i + 1];
            
            let row = [currentObject];
            if (nextObject) {
                row.push(nextObject);
            }
            lstOfFields.push(row);

        }
        return lstOfFields;
    }

    get rowsOfArrayObjects() {
        let lstOfFields = [];

        let filteredFields = this.fields.filter(field => field.type === "object");

        for (let i = 0; i < filteredFields.length; i += 2) {

            let currentObject = filteredFields[i];
            let nextObject = filteredFields[i + 1];
            
            let row = [currentObject];
            if (nextObject) {
                row.push(nextObject);
            }
            lstOfFields.push(row);

        }
        return lstOfFields;
    }

    get stringifiedValue() {
        return JSON.stringify(this.field.value);
    }

    handleChange(event) {
        try{
            const key = event.target.dataset.key;
            const originalType = event.target.dataset.original;
            if(originalType==='array'){
                this.config[key] = event.target.value.split(',').map(item => item.trim()).filter(item => item !== '');
            }else if(originalType==='boolean'){
                this.config[key] = event.target.checked;
            }else{
                this.config[key] = event.target.value;
            }
        }catch(e){
            console.log(e);
        }
    }

    handleSave() {
        console.log('New Config Object to update:'+JSON.stringify(this.config));

        // Extract the keys from this.config to maintain the order
        const keyOrder = Object.keys(this.config);
        console.log('keyOrder:'+JSON.stringify(keyOrder));

        updateConfig({ configStr: JSON.stringify(this.config),keyOrder: JSON.stringify(keyOrder),configId:'home'})
            .then(result => {
                if (result.status === 'success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Configuration updated successfully',
                            variant: 'success'
                        })
                    );
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
        if (this.originalConfig) {
            this.config = JSON.parse(JSON.stringify(this.originalConfig));
        } else {
            console.error('Original config is not defined.');
        }
    }
}