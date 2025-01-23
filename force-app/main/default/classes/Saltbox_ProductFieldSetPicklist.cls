global class Saltbox_ProductFieldSetPicklist extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
            'Width',
            'Width__c'
        );
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
     
                Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Product2').getDescribe().fields.getMap();
                for(Schema.SObjectField sfield : fieldMap.Values())
                {
                    schema.describefieldresult dfield = sfield.getDescribe();
                    VisualEditor.DataRow value = new VisualEditor.DataRow(
                        dfield.getLabel(),
                        dfield.getname()
                    );
                    picklistValues.addRow(value);
                }
      
          
    
        return picklistValues;
    }
}