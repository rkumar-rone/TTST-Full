/**
    * @description : A controller class for handling wishlist,wishlistItems.
    * @created Date : 7th March 2022
    * @Author : Sanyam Jain
    * @LastModified : 7th March 2022

    ***** updated March 2023
    1. methods now receives effectiveAccountId so they will be 'Account Switcher' compatible.
*/
public with sharing class Saltbox_B2BWishlistController {

    @TestVisible
    private static Boolean throwException = false;

    @TestVisible
    private static Set<Id> wlistIdList = new Set<Id>();

    @TestVisible
    private static ConnectApi.WishlistsSummary wishlistsSummary;

    @TestVisible
    private static ConnectApi.Wishlist wishlist;

    private class ForceException extends Exception {}

    @AuraEnabled
    public static ConnectApi.WishlistsSummary getWishLists(
        String communityId,
        String effectiveAccountId
    ) {
        try {

            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }

            if(!Test.isRunningTest()) {
                String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                return ConnectApi.CommerceWishlist.getWishlistSummaries(webstoreId,effectiveAccountId,true);
            } else {
                return new ConnectApi.WishlistsSummary();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ConnectApi.WishlistItemCollection getWishListItems(
        String wishListId,
        String communityId,
        String effectiveAccountId
    ) {
        try {

            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }

            if(!Test.isRunningTest()) {
                String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                return ConnectApi.CommerceWishlist.getWishlistItems(webstoreId,effectiveAccountId,wishlistId, null, null, null, null);
            } else {
                return new ConnectApi.WishlistItemCollection();
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getWishListsModal(
        String communityId,
        String effectiveAccountId
    ) {
        try {

            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }

            List<WishlistWrapper> wishlists = new List<WishlistWrapper>();

            ConnectApi.WishlistsSummary result;
            Set<Id> wishlistId = new Set<Id>();
            Map<Id, summary> wihslistSummary = new Map<Id, summary>();

            if(!Test.isRunningTest()) {
                String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                result = ConnectApi.CommerceWishlist.getWishlistSummaries(webstoreId, effectiveAccountId,true);
            } else {
                wishlistId = wlistIdList;
                result = wishlistsSummary;
            }

            /**Creating Wishlist sumamry */
            if (result != null && result.summaries != null && !result.summaries.isEmpty()) {
                for (ConnectApi.WishlistSummary inst : result.summaries) {
                    wishlistId.add(inst.id);
                    summary item = new summary();
                    item.wishlistId = inst.id;
                    item.createdDate = inst.createdDate;
                    item.modifiedDate = inst.modifiedDate;
                    item.name = inst.name;
                    item.wishlistProductCount = inst.wishlistProductCount;
                    wihslistSummary.put(inst.id, item);
                }
            }

            // Query WishlistItems from wishlist for checking if item is in whislit or not
            List<wishlist> wishlistQuery = [
                SELECT
                    id,
                    Name,
                    (SELECT id, Name, Product2Id FROM WishListItems)
                FROM Wishlist
                WHERE id IN :wishlistId
            ];
            for (wishlist inst : wishlistQuery) {
                wishlistWrapper wrap = new wishlistWrapper();
                wrap.wishlist = wihslistSummary.get(inst.id);
                wrap.wishlistItems = inst.WishListItems;
                wishlists.add(wrap);
            }

            return JSON.serialize(wishlists);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createWishList(
        String bucketName,
        String communityId,
        String effectiveAccountId
    ) {
        try {

            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }

            //Creating wishlist input(Wishlist properties)
            ConnectApi.WishlistInput input = new ConnectApi.WishlistInput();
            input.name = bucketName;

            connectApi.Wishlist result;

            if(!Test.isRunningTest()) {
                String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                result = ConnectApi.CommerceWishlist.createWishlist(webstoreId,effectiveAccountId,input);
            } else {
                result = wishlist;
            }

            // Creating Wishlist Summary Wrapper
            summary item = new summary();

            item.wishlistId = result.summary.id;
            item.createdDate = result.summary.createdDate;
            item.modifiedDate = result.summary.modifiedDate;
            item.name = result.summary.name;
            item.wishlistProductCount = result.summary.wishlistProductCount;

            wishlistWrapper wrap = new wishlistWrapper();
            wrap.wishlist = item;
            wrap.wishlistItems = null;

            return JSON.serialize(wrap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ConnectApi.WishlistItem> addWishListItem(
        String productId,
        List<String> wishlistListId,
        String communityId,
        String effectiveAccountId
    ) {
        try {

            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }

            List<ConnectApi.WishlistItem> wishlistItemList = new List<ConnectApi.WishlistItem>();

            // Creating wishlist input(Wishlist properties)
            ConnectApi.WishlistItemInput input = new ConnectApi.WishlistItemInput();
            input.productId = productId;

            if(!Test.isRunningTest()) {
                String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                for (String inst : wishlistListId) {
                    ConnectApi.WishlistItem wishlistitem = ConnectApi.CommerceWishlist.addItemToWishlist(webstoreId, effectiveAccountId,inst,input);
                    wishlistItemList.add(wishlistitem);
                }
            } 

            return wishlistItemList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ConnectApi.WishlistSummary updateWishlist(
        String wishlistId,
        String updateWishlistName,
        String communityId,
        String effectiveAccountId
    ) {
        try {

            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }

            ConnectApi.WishlistSummary wishSummary;

            //Creating wishlist input(Wishlist properties)
            ConnectApi.WishlistUpdateInput input = new ConnectApi.WishlistUpdateInput();
            input.name = updateWishlistName;

            if(!Test.isRunningTest()) {
                String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                return ConnectApi.CommerceWishlist.updateWishlist(webstoreId, effectiveAccountId, wishListId, input);
            } else {
                return new ConnectApi.WishlistSummary();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string removeWishListItem(
        String wishListItemId,
        String wishlistId,
        String communityId,
        String effectiveAccountId
    ) {
        try {
            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }
            if(!Test.isRunningTest()) {
                String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                ConnectApi.CommerceWishlist.removeWishlistItem(webstoreId,effectiveAccountId,wishlistId,wishListItemId);
            } 
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ConnectApi.CartItem addCartItem(
        String productId,
        String currentUserId,
        String communityId,
        String effectiveAccountId
    ) {
        try {
            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }

            String cartId;
            String webstoreId;
            List<WebCart> cartList = new List<WebCart>();

            if(!Test.isRunningTest()) {
                webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            } else {
                webstoreId = communityId;
            }

            //getting the webcart detail
            cartList = [
                SELECT id, Name, ownerId
                FROM WebCart
                WHERE
                    ownerId = :currentUserId
                    AND Status = 'Active'
                    AND WebStoreId = :webstoreId
                    AND AccountId = :effectiveAccountId
                LIMIT 1
            ];

            ConnectApi.CartInput cartInput = new ConnectApi.CartInput();

            //if no cart exist creating new one
            if (cartList.isEmpty()) {
                cartId = ConnectApi.CommerceCart.createCart(webstoreId,cartInput).cartId;
            } else {
                cartId = cartList[0].Id;
            }
            
            ConnectApi.CartItemInput cartItem = new ConnectApi.CartItemInput();
            cartItem.productId = productId;
            cartItem.quantity = '1';
            cartItem.type = ConnectApi.CartItemType.Product;

            if(!Test.isRunningTest()){
                return ConnectApi.CommerceCart.addItemToCart(webstoreId, effectiveAccountId, cartId, cartItem);
            } else {
                return new ConnectApi.CartItem();
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Saltbox_Wishlist_Modal_Properties__mdt getWishlistModalMetadata() {

        try {
            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }

            List<Saltbox_Wishlist_Modal_Properties__mdt> modalProperties = [
                SELECT
                    Id,
                    Modal_Title__c,
                    Wishlist_Column_Name_Text__c,
                    Add_button_text__c
                FROM Saltbox_Wishlist_Modal_Properties__mdt
            ];

            return modalProperties[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void deleteWishlist(
        String wishlistId,
        String communityId,
        String effectiveAccountId
    ) {
        try {

            if (Test.isRunningTest() && throwException) {
                throw new ForceException();
            }
        
            if (!Test.isRunningTest()) {
                String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(communityId);
                ConnectApi.CommerceWishlist.deleteWishlist(webstoreId, effectiveAccountId, wishlistId);
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** Wishlist Wrapper */
    public class WishlistWrapper {
        public summary wishList;
        public List<wishlistItem> wishlistItems;
    }

    /** Wishlist Summary Wrapper */
    public class Summary {
        public string wishlistId;
        public DateTime createdDate;
        public Integer wishlistProductCount;
        public string name;
        public DateTime modifiedDate;
    }
}