/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 10-23-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@IsTest
public class SIB_MegaMenuConfigurationTest {

    @IsTest
    static void testManualObjectCreation() {
        
        SIB_MegaMenuConfiguration.Record record1 = new SIB_MegaMenuConfiguration.Record();
        record1.URL = 'https://example.com/record1';
        record1.Label = 'Record 1';

        SIB_MegaMenuConfiguration.SubCategory subCategory1 = new SIB_MegaMenuConfiguration.SubCategory();
        subCategory1.SubCategoryName = 'SubCategory 1';
        subCategory1.records = new List<SIB_MegaMenuConfiguration.Record>{ record1 };

        SIB_MegaMenuConfiguration.Category category = new SIB_MegaMenuConfiguration.Category();
        category.type = 'Menu Type 1';
        category.value = 'Category 1';
        category.URL = 'https://example.com/category1';
        category.subCategories = new List<SIB_MegaMenuConfiguration.SubCategory>{ subCategory1 };

        SIB_MegaMenuConfiguration menuConfig = new SIB_MegaMenuConfiguration();
        menuConfig.Category = new List<SIB_MegaMenuConfiguration.Category>{ category };
        String jsonInput = '{"Category":[{"type":"Menu Type 1"}]}';
        SIB_MegaMenuConfiguration.parse(jsonInput);

        System.assertNotEquals(null, menuConfig, 'The menuConfig object should not be null.');
    }
}