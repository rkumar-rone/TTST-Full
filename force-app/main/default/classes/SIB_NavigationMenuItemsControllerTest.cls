/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_NavigationMenuItemsControllerTest {
    
    @isTest  
    static void getNavigationMenuItemsTestCase1(){
       Test.startTest();
         List<ConnectApi.NavigationMenuItem> resp = SIB_NavigationMenuItemsController.getNavigationMenuItems('Default My Account Menu','Live',false,false);
         List<ConnectApi.NavigationMenuItem> resp2 = SIB_NavigationMenuItemsController.getNavigationMenuItems('Default My Account Menu','Draft',false,false);

        Test.stopTest();
     
  }
  @IsTest
  static void testGetMegaMenuConfiguration(){
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams = SIB_NavigationMenuItemsController.getMegaMenuConfiguration(mapParams);
        Map<String, Object> mapParamsAddAsDefault = SIB_NavigationMenuItemsController.updateSelectedAddAsDefault(mapParams);

  }
  @IsTest
  static void testExceptionsGetMegaMenuConfiguration(){
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams = SIB_NavigationMenuItemsController.getMegaMenuConfiguration(null);
        Map<String, Object> mapParamsAddAsDefault = SIB_NavigationMenuItemsController.updateSelectedAddAsDefault(null);

  }


}