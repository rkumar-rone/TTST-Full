/**
 * @description       : 
 * @author            : garora@rafter.one
 * @group             : 
 * @last modified on  : 27-09-2024
 * @last modified by  : garora@rafter.one
**/
public with sharing class SIB_CategoryPicklist extends VisualEditor.DynamicPicklist{


    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        String storeName = SIB_Util.fetchConfigByValue(SIB_Constants.STOREFRONT_MODULE);
        WebStore store = [SELECT Id FROM WebStore WHERE Name = :storeName LIMIT 1];
        WebStoreCatalog storeCatalog = [SELECT Id,ProductCatalogId FROM WebStoreCatalog WHERE SalesStoreId=:store.Id LIMIT 1];
        for(ProductCategory category : [SELECT Id,Name FROM ProductCategory WHERE CatalogId=:storeCatalog.ProductCatalogId LIMIT 1000]){
            myValues.addRow(new VisualEditor.DataRow(String.valueOf(category.Name) , String.valueOf(category.Name)));
        }
        return myValues;
    }

    //This method is required to be overriden, for now returning null
    public override VisualEditor.DataRow getDefaultValue() {
        return null;
    }
}