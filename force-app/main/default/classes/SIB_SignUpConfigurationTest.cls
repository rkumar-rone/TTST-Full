/**
 * @description       : Test class for SIB_SignUpConfiguration
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_SignUpConfigurationTest {

    @isTest
    static void testSetValuesManually() {
        SIB_SignUpConfiguration config = new SIB_SignUpConfiguration();
        config.id = '12345';
        config.cssTheme = 'dark';
        config.showPasswordFields = true;
        
        System.assertEquals(config.id, '12345', 'Passed');
    }

    @isTest
    static void testParseMethod() {
        String jsonString = '{"id": "67890", "cssTheme": "light", "showPasswordFields": false}';       
        SIB_SignUpConfiguration config = SIB_SignUpConfiguration.parse(jsonString);        
        System.assertNotEquals(config, null, 'Passed');
    }
}