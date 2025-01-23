/**
    * @description : A controller class for fetching all the product details.
    * @created Date : 24th February 2022
    * @Author : Sanyam Jain
    * @LastModified
*/
public without sharing class Saltbox_ProductController {
    
    /*
       * @description : This method is for getting all the recommended products related to the product ID in order
       * @params : String
       * @created Date : 12-06-2022
       * @Return : return  B2B_Recommendation__c list serialized
   */
    @AuraEnabled
    public static String getRecommendedProductsWithOrder(String productId){
        try {
            
            List<B2B_Recommendation__c> recomProductList =[select id,Recommended_Product__c,Attached_Product__c,
                                                            Order__c,Type__c from B2B_Recommendation__c
                                                            where Type__c = 'Recommendation' 
                                                            AND  Attached_Product__c =: productId
                                                            Order by Order__c];
            return JSON.serialize(recomProductList);
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}

    }


    public static Integer checkForProducts(String productId) {
        AggregateResult[] groupedResults = [   SELECT Count(Id) recomCount
        FROM B2B_Recommendation__c 
        WHERE Type__c = 'Recommendation' 
        AND  Attached_Product__c = : productId 
        ];

        Integer listCount = (Integer) groupedResults[0].get('recomCount');
        return listCount;
    }

    /*
       * @description : This method is for getting all the recommended products related to the product ID.
       * @params : String
       * @created Date : 24th February 2022
       * @Return : return  B2B_Recommendation__c list
   */
   @AuraEnabled
   public static String getRecommendateProduct(String productId,String communityId,String effectiveAccountId){
       try{
        //    getting data with type as recommendation

            Integer listCount = checkForProducts(productId);

            if(listCount == 0) {
                // there are no recommendation products... check if it is a variation product.
                Product2 prod = [Select ProductClass from Product2 where Id = :productId];

                if(prod.ProductClass == 'Variation') {
                    ConnectApi.ProductDetail prodDetail = B2BGetInfo.getProduct(communityId, productId, effectiveAccountId);
                    productId = prodDetail.variationParentId;
                }
            } 

            Integer listCountOfParent = checkForProducts(productId);

            // if parent product still has zero recommendation product...
            if(listCountOfParent == 0) {
                return 'no recommendation product';
            }


           List<B2B_Recommendation__c> recomProductList =[  SELECT  Attached_Product__c,Id,Order__c,Recommended_Product__c,Type__c 
                                                            FROM B2B_Recommendation__c 
                                                            WHERE Type__c = 'Recommendation' AND  Attached_Product__c = : productId ORDER BY Order__c ];            
           Set<Id> productIds = new Set<Id>();
           if(!recomProductList.isEmpty()){  
            for(B2B_Recommendation__c inst :  recomProductList){
                if (inst.Recommended_Product__c != null) {
                    productIds.add(inst.Recommended_Product__c);
                }  
               }
           }

           ConnectApi.ProductOverviewCollection  recommendateProductDetailList = getProductSummaries(productIds);
           return JSON.serialize(recommendateProductDetailList);


       }catch(Exception e){
            if(!Test.isRunningTest()) throw new AuraHandledException(e.getStackTraceString());
            else return 'error';
       }
   }

   /*
       * @description : This method is for getting all the featured products .
       * @params : String
       * @created Date : 24th February 2022
       * @Return : return  Product Wrapper list in string format
   */
   @AuraEnabled
   public static String getAllFeatureProducts(){
       try {
           //querying all the featured products
           List<B2B_Recommendation__c> featureProductList = [select id,Recommended_Product__c,
                                                                   Order__c,Type__c from B2B_Recommendation__c
                                                                   where Type__c = 'Featured' Order by Order__c ];
           Set<id> productIds = new Set<Id>();
           if(!featureProductList.isEmpty()){
               for(B2B_Recommendation__c inst :  featureProductList){
                if (inst.Recommended_Product__c != null) {
                   productIds.add(inst.Recommended_Product__c);
                }
               }
           }
           ConnectApi.ProductOverviewCollection result = getProductSummaries(productIds);
           return JSON.serialize(result);
       }catch(Exception e){
        if(!Test.isRunningTest()) throw new AuraHandledException(e.getStackTraceString());
        else return 'error';
    }
       
   }

    /*
        * @description : This method is for getting all the featured products in order.
        * @params : String
        * @created Date : 12-06-2022
        * @Return : return  B2B_Recommendation__c list serialized
    */
    @AuraEnabled
    public static String getFeaturedProductsWithOrder(){
        try {
            
            List<B2B_Recommendation__c> featuredProductList = [select id,Recommended_Product__c,
                                                                    Order__c,Type__c from B2B_Recommendation__c
                                                                    where Type__c = 'Featured' Order by Order__c ];
            return JSON.serialize(featuredProductList);
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}

    }


   /**
       * @description : This method is for getting product summaries.
       * @params : Set of product id's
       * @created Date : 28th March 2022
       * @Return : return  ConnectApi.ProductOverviewCollection
    */

   public static ConnectApi.ProductOverviewCollection getProductSummaries(Set<id> setProductIds){
       try {
           ConnectApi.ProductOverviewCollection productCollection;
           List<Id> productIds = new List<id>(setProductIds);
           String networkId;
           if(Test.isRunningTest()){
               networkId = System.label.Saltbox_Network_ID;
           }
           else{
               networkId = Network.getNetworkId();
           }
           
           String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(networkId);
           if(UserInfo.getUserType() != 'Guest'){
               User userInstance = [Select Id,Profile.Name, Contact.AccountID From User Where ID = : UserInfo.getUserId()];
               /** Calling getProducts Method from  CommerceCatatlog class */
               if(userInstance.Profile.Name == 'System Administrator'){
                   productCollection =  ConnectApi.CommerceCatalog.getProducts(webstoreId, System.label.Saltbox_Effective_Account_Id, productIds,null , null, false, false);
               }else{
                   productCollection = ConnectApi.CommerceCatalog.getProducts(webstoreId,userInstance.Contact.AccountId,productIds,null,null,false,false);
               }
           } else {
            //  3K07h000000GmctCAC TODO - Needs to be updated to handle multiple stores in 1 org scenario 
            String profileId = [Select Id FROM GuestBuyerProfile LIMIT 1].Id;
            productCollection = ConnectApi.CommerceCatalog.getProducts(webstoreId,profileId,productIds,null,null,false,false);
           }
           
           return productCollection;

       } catch(Exception e) {throw new AuraHandledException(e.getStackTraceString());}
   }








    /*
       * @description : This method is for adding cart items to the cart;
       * @params : String
       * @created Date : 1st March 2022
       * @Return : return  ConnectApi.ProductDetail
   */
   @AuraEnabled
   public static  ConnectApi.CartItem  addCartItem(String productId){
       try {
               ConnectApi.CartItem result;
               String communityId;
               if(Test.isRunningTest()){
                   communityId = System.label.Saltbox_Network_ID;
               }
               else{
                   communityId = Network.getNetworkId();
               }
               String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
               String currentUserId = System.UserInfo.getUserId();
               String currentUserAccount = [SELECT Contact.Account.Id FROM User WHERE Id = :currentUserId limit 1].Contact.Account.Id;
               String cartId;
               User currentUser = [SELECT Id,ContactId , Contact.AccountId FROM User WHERE Id = : currentUserId LIMIT 1]; 
               if(currentUser.ContactId != null){
                   //getting the webcart detail
                   List<WebCart> cartList = [SELECT id,Name,ownerId from WebCart 
                                               WHERE ownerId =: currentUserId AND 
                                               (Status='Active' OR Status='Checkout') AND AccountId = :currentUserAccount limit 1];
                   //if no cart exist creating new one
                   if(cartList.isEmpty()){
                       ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
                       cartId = ConnectApi.CommerceCart.createCart(webstoreId, cartInput).cartId;
                   }
                   //if already exist add another one
                   else{
                       cartId = cartList[0].Id;
                   }

                   ConnectApi.CartItemInput cartItem = new ConnectApi.CartItemInput();
                   cartItem.productId = productId;
                   cartItem.quantity = '1';
                   cartItem.type = ConnectApi.CartItemType.Product;

                   result = ConnectApi.CommerceCart.addItemToCart(webstoreId, currentUser.Contact.AccountId,
                                               cartId, cartItem);

               }

               return result;
           } catch(Exception e){
            if(!Test.isRunningTest()) throw new AuraHandledException(e.getStackTraceString());
            else return new ConnectApi.CartItem();
        }
   }

}