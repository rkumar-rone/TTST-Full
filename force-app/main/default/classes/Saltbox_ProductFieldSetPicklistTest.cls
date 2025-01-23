@isTest
private class Saltbox_ProductFieldSetPicklistTest {
    @isTest
    static void shouldReturnProductFieldSetValues() {
        Saltbox_ProductFieldSetPicklist saltboxProductFieldSetPickList = new Saltbox_ProductFieldSetPicklist();
        VisualEditor.DynamicPickListRows rows = saltboxProductFieldSetPickList.getValues();
        System.assertEquals(true, rows != null, 'Return fields');
    }
    @isTest
    static void shouldReturnDefaultValue() {
        Saltbox_ProductFieldSetPicklist saltboxProductFieldSetPickList = new Saltbox_ProductFieldSetPicklist();
        VisualEditor.DataRow row = saltboxProductFieldSetPickList.getDefaultValue();
        System.assertEquals(true, row != null, 'Default value returned');
    }
}