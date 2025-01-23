import initDataMethod from "@salesforce/apex/RelatedListController.initData";
import communityBasePath from '@salesforce/community/basePath';

export default class SibRelatedList {

     /**
     * @description       : Refresh data if the state is updated
     * @param             : state
     * @return            : None
    **/
     fetchData(state) {
        let jsonData = Object.assign({}, state)
        jsonData.numberOfRecords = state.numberOfRecords + 1
        jsonData = JSON.stringify(jsonData)

        let parsedJsonData = JSON.parse(jsonData);

        let fields = parsedJsonData?.fields?.split(", ");
        let uniqueFields = [...new Set(fields)];
        let uniqueFieldsString = uniqueFields.join(", ");

        parsedJsonData.fields = uniqueFieldsString;

        jsonData = JSON.stringify(parsedJsonData);

        return initDataMethod({ jsonData })
            .then(response => {
                const data = JSON.parse(response)
                return this.processData(data, state)
            })
            .catch(error => {
                console.log(error);
            });
    }

    /**
     * @description       : Helper to construct the data table 
     * @param             : records, state.detailpageurl
     * @return            : None
    **/
    processData(data, state){
        const records = data.records;
        this.generateLinks(records, state.detailpageurl)
        if (records.length > state.numberOfRecords) {
            records.pop()
            data.title = `${data.sobjectLabelPlural} (${state.numberOfRecords}+)`
        } else {
            data.title = `${data.sobjectLabelPlural} (${Math.min(state.numberOfRecords, records.length)})`
        }     
        return data
    }

    /**
     * @description       : Helper to construct the column row action if enabled 
     * @param             : columns, customActions, hideActions
     * @return            : None
    **/
    initColumnsWithActions(columns, customActions, hideActions) {
        if (!customActions.length) {
            customActions = [
                { label: 'Edit', name: 'edit' },
                { label: 'Delete', name: 'delete' }
            ]
        }
        if(hideActions){
            return [...columns]
        }
        return [...columns, { type: 'action', typeAttributes: { rowActions: customActions }}]
        //return [...columns, { type: 'action', typeAttributes: { rowActions: customActions }, cellAttributes: { class: 'slds-hide' }}]
    }

    /**
     * @description       : Helper to generate record page links 
     * @param             : records, detailpageurl
     * @return            : None
    **/
    generateLinks(records, detailpageurl) {
        records.forEach(record => {
            record.LinkName =communityBasePath + `/${detailpageurl}/` + record.Id
            for (const propertyName in record) {
                const propertyValue = record[propertyName];
                //console.log(propertyName, ' this is data ' + propertyValue.Id, ' ', propertyValue);
                if (typeof propertyValue === 'object') {
                    //add path to go to detail page
                    const newValue = propertyValue.Id ? ('/' + propertyValue.Id) : null;
                    this.flattenStructure(record, propertyName + '_', propertyValue);
                    if (newValue !== null) {
                        record[propertyName + '_LinkName'] = newValue;
                    }
                }
            }
        });

    }

    /**
     * @description       : Helper to construct the link based on the pattern established
     * @param             : topObject, prefix, toBeFlattened
     * @return            : None
    **/
    flattenStructure(topObject, prefix, toBeFlattened) {
        for (const propertyName in toBeFlattened) {
            const propertyValue = toBeFlattened[propertyName];
            if (typeof propertyValue === 'object') {
                this.flattenStructure(topObject, prefix + propertyName + '_', propertyValue);
            } else {
                topObject[prefix + propertyName] = propertyValue;
            }
        }
    }

}