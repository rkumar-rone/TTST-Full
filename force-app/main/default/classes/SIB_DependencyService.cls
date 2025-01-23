/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_DependencyService {

    private static final String CLASSNAME = 'SIB_DependencyService';

    private static final String CONFIG_TYPE = 'STOREFRONT';
    
    Map<String,String> dependencyMap ; 
    static SIB_DependencyService instance;

    public static SIB_DependencyService getInstance(){
            if(instance == null){
                instance = new SIB_DependencyService();
            }
        return instance;
    }

    SIB_DependencyService(){
        dependencyMap = getAllServices();
        dependencyMap = new Map<String,String> {
            'productService' => 'SIB_B2BProductService' ,
            'productSearchService' => 'SIB_B2BProductSearchService' ,
            'pricingService' => 'SIB_B2BPricingService' ,
            'inventoryService' => '',
            'cartService' => 'SIB_B2BCartService',
            'subscriptionService' => 'SIB_CustomSubscription',
            'relatedProductService' => 'SIB_B2BRelatedProductService',
            'quoteService' => ''
        };
    }

    public Map<String, String> getAllServices() {
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('configurationType', CONFIG_TYPE);
        mapParams = SIB_ConfigurationService.getConfigurationJSON(mapParams);
        Map<String, String> serviceMap = new Map<String, String>();
        if(mapParams.containsKey('configJSON') && mapParams.get('configJSON') != null) {
            String j = String.valueOf(mapParams.get('configJSON'));      
            serviceMap = (Map<String,String>) JSON.deserialize(j, Map<String,String>.class);
        }
        return serviceMap;
    }

    public ISIB_ProductService getProductService(){
        system.debug('getProductService : ');
        String serviceName = dependencyMap.containsKey('productService') ? dependencyMap.get('productService') : null;
        system.debug('serviceName : '+serviceName);
        if(String.isNotBlank(serviceName)){
            return (ISIB_ProductService)getService(serviceName);
        }else{
            return null;
        }
    }

    public ISIB_ProductSearchService getProductSearchService(){
        system.debug('getProductSearchService : ');
        String serviceName = dependencyMap.containsKey('productSearchService') ? dependencyMap.get('productSearchService') : null;
        system.debug('serviceName : '+serviceName);
        if(String.isNotBlank(serviceName)){
            return (ISIB_ProductSearchService)getService(serviceName);
        }else{
            return null;
        }
    }

    public ISIB_RelatedProductService getRelatedProductService(){
        system.debug('getRelatedProductService : ');
        String serviceName = dependencyMap.containsKey('relatedProductService') ? dependencyMap.get('relatedProductService') : null;
        system.debug('serviceName : '+serviceName);
        if(String.isNotBlank(serviceName)){
            return (ISIB_RelatedProductService)getService(serviceName);
        }else{
            return null;
        }
    }

    public ISIB_PricingService getPricingService(){
        system.debug('getPricingService : ');
        String serviceName = dependencyMap.containsKey('pricingService') ? dependencyMap.get('pricingService') : null;
        system.debug('serviceName : '+serviceName);
        if(String.isNotBlank(serviceName)){
            return (ISIB_PricingService)getService(serviceName);
        }else{
            return null;
        }
    }

    public ISIB_InventoryService getInventoryService(){
        String serviceName = dependencyMap.containsKey('inventoryService') ? dependencyMap.get('inventoryService') : null;
        if(String.isNotBlank(serviceName)){
            return (ISIB_InventoryService)getService(serviceName);
        }else{
            return null;
        }
    }

    public ISIB_CartService getCartService(){
        system.debug('getCartService : ');
        String serviceName = dependencyMap.containsKey('cartService') ? dependencyMap.get('cartService') : null;
        system.debug('serviceName : '+serviceName);
        if(String.isNotBlank(serviceName)){
            return (ISIB_CartService)getService(serviceName);
        }else{
            return null;
        }
    }

    public Object getService(String serviceName){
        system.debug('getService serviceName : '+serviceName);
        Type t = Type.forName(serviceName);
        system.debug('getService Type : '+t);
        return t.newInstance();
    }

}