/**
* @description : Test class for Saltbox Wishlist Controller
* @created Date : 20 March 2022
* @Author : Sanyam Jain
* @LastModified

    updated April 2023
    - no System Label use.
*/

@isTest(SeeAllData=true)
public with sharing class Saltbox_B2BWishlistControllerTest {
  @isTest
  public static void testCreateWishList() {
    ConnectApi.WishlistSummary wsSum = new ConnectApi.WishlistSummary();
    wsSum.createdDate = Date.today();
    wsSum.id = '3or8b000000XlyfAAC';
    wsSum.modifiedDate = Date.today();
    wsSum.name = 'Fav Products';
    wsSum.wishlistProductCount = 0;

    ConnectApi.Wishlist wishlist = new ConnectApi.Wishlist();
    wishlist.summary = wsSum;

    Saltbox_B2BWishlistController.wishlist = wishlist;

    // create wishlist
    String result = Saltbox_B2BWishlistController.createWishList(
      'bucket',
      '',
      ''
    );

    // test
    System.assertNotEquals('', result, 'must not be empty');
  }

  @isTest
  public static void testCreateWishListException() {
    // create wishlist - throws error
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      String result = Saltbox_B2BWishlistController.createWishList('', '', '');
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'createWishList did not throw an exception'
    );
  }

  @isTest
  public static void testGetWishlists() {
    // get wishlist
    ConnectApi.WishlistsSummary summaries = Saltbox_B2BWishlistController.getWishLists(
      '',
      ''
    );

    // test
    System.assertNotEquals(null, summaries, 'must not be null');
  }

  @isTest
  public static void testGetWishlistsException() {
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      ConnectApi.WishlistsSummary summaries = Saltbox_B2BWishlistController.getWishLists(
        '',
        ''
      );
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'getWishList did not throw an exception'
    );
  }

  @isTest
  public static void testAddWishListItem() {
    // create test data
    Wrapper testData = createTestData();

    // add product to wishlist
    List<ConnectApi.WishlistItem> wishItemList = Saltbox_B2BWishlistController.addWishListItem(
      testData.product.Id,
      new List<String>(),
      '',
      testData.acc.Id
    );

    // test
    System.assertEquals(0, wishItemList.size(), 'return value not a List');
  }

  @isTest
  public static void testAddWishListItemException() {
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      List<ConnectApi.WishlistItem> wishItemList = Saltbox_B2BWishlistController.addWishListItem(
        'testData.product.Id',
        new List<String>{ '' },
        'testData.store.NetworkId',
        'testData.acc.Id'
      );
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'addWishListItem did not throw an exception'
    );
  }

  @isTest
  public static void testGetWishListItems() {
    // get wishlistItems
    ConnectApi.WishlistItemCollection itemCollection = Saltbox_B2BWishlistController.getWishListItems(
      '',
      '',
      ''
    );

    // test
    System.assertNotEquals(null, itemCollection, 'must not be null');
  }

  @isTest
  public static void testGetWishListItemsException() {
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      // get wishlistItems
      ConnectApi.WishlistItemCollection itemCollection = Saltbox_B2BWishlistController.getWishListItems(
        '',
        '',
        ''
      );
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'getWishListItems did not throw an exception'
    );
  }

  @isTest
  public static void testGetWishListsModal() {
    ConnectApi.WishlistSummary wsSum = new ConnectApi.WishlistSummary();
    wsSum.createdDate = Date.today();
    wsSum.id = '3or8b000000XlyfAAC';
    wsSum.modifiedDate = Date.today();
    wsSum.name = 'Fav Products';
    wsSum.wishlistProductCount = 0;

    ConnectApi.WishlistsSummary wsSumList = new ConnectApi.WishlistsSummary();
    wsSumList.summaries = new List<ConnectApi.WishlistSummary>{ wsSum };

    WebStore store = new WebStore();
    store.DefaultLanguage = 'en_US';
    store.Name = 'Test Store';
    insert store;

    Account acc = new Account();
    acc.Name = 'test acc';
    insert acc;

    Wishlist ws = new Wishlist();
    ws.Name = 'testName';
    ws.WebStoreId = store.Id;
    ws.AccountId = acc.Id;
    insert ws;

    List<wishlist> wsList = [
      SELECT id, Name, (SELECT id, Name, Product2Id FROM WishListItems)
      FROM Wishlist
    ];

    Set<Id> wsIdList = new Set<Id>{ wsList[0].Id };

    Saltbox_B2BWishlistController.wlistIdList = wsIdList;
    Saltbox_B2BWishlistController.wishlistsSummary = wsSumList;

    // get wishlistModal
    String summaries = Saltbox_B2BWishlistController.getWishListsModal('', '');

    // test
    System.assertNotEquals(null, summaries, 'should not be null');
  }

  @isTest
  public static void testGetWishListsModalException() {
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      String summaries = Saltbox_B2BWishlistController.getWishListsModal(
        'fake name',
        'fake name'
      );
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'getWishListsModal did not throw an exception'
    );
  }

  @isTest
  public static void testRemoveWishListItem() {
    // remove product from wishlist
    String removeResult = Saltbox_B2BWishlistController.removeWishListItem(
      '',
      '',
      '',
      ''
    );

    // test
    System.assertNotEquals(null, removeResult, 'must not be null');
  }

  @isTest
  public static void testRemoveWishListItemException() {
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      // remove product from wishlist
      String removeResult = Saltbox_B2BWishlistController.removeWishListItem(
        '',
        '',
        '',
        ''
      );
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'removeWishListItem did not throw an exception'
    );
  }

  @isTest
  public static void testUpdateWishList() {
    ConnectApi.WishlistSummary udpateResult = Saltbox_B2BWishlistController.updateWishlist(
      '',
      '',
      '',
      ''
    );
    // test
    System.assertNotEquals(null, udpateResult, 'must not be null');
  }

  @isTest
  public static void testUpdateWishListException() {
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      ConnectApi.WishlistSummary udpateResult = Saltbox_B2BWishlistController.updateWishlist(
        '',
        '',
        '',
        ''
      );
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'updateWishList did not throw an exception'
    );
  }

  @isTest
  public static void testDeleteWishList() {
    Boolean threwException = false;
    try {
      Saltbox_B2BWishlistController.deleteWishlist('', '', '');
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      false,
      threwException,
      'deleteWishList throw an exception'
    );
  }

  @isTest
  public static void testDeleteWishListException() {
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      Saltbox_B2BWishlistController.deleteWishlist('', '', '');
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'deleteWishList did not throw an exception'
    );
  }

  @isTest
  public static void testAddCartItem() {
    Test.startTest();
    // create test data
    Wrapper testData = createTestData();

    User user1 = [SELECT Id FROM User LIMIT 1];

    testData.cart.OwnerId = user1.Id;
    update testData.cart;

    ConnectApi.CartItem cartItem = Saltbox_B2BWishlistController.addCartItem(
      testData.product.Id,
      user1.Id,
      testData.webStore.Id,
      testData.acc.Id
    );

    Test.stopTest();

    // test
    System.assertNotEquals(null, cartItem, 'must not be null');
  }

  @isTest
  public static void testAddCartItemException() {
    Boolean threwException = false;
    Saltbox_B2BWishlistController.throwException = true;
    try {
      ConnectApi.CartItem cartItem = Saltbox_B2BWishlistController.addCartItem(
        '',
        '',
        '',
        ''
      );
    } catch (Exception e) {
      threwException = true;
    }

    // test
    System.assertEquals(
      true,
      threwException,
      'addCartItem did not throw an exception'
    );
  }

  // @isTest
  // public static void testGetWishlistModalMetadata() {
  //   System.assertNotEquals(
  //     null,
  //     Saltbox_B2BWishlistController.getWishlistModalMetadata()
  //   );
  // }

  // @isTest
  // public static void testGetWishlistModalMetadataException() {
  //   Boolean threwException = false;
  //   Saltbox_B2BWishlistController.throwException = true;
  //   try {
  //     Saltbox_B2BWishlistController.getWishlistModalMetadata();
  //   } catch (Exception e) {
  //     threwException = true;
  //   }

  //   // test
  //   System.assertEquals(
  //     true,
  //     threwException,
  //     'getWishlistModalMetadata did not throw an exception'
  //   );
  // }

  public static Wrapper createTestData() {
    WebStore store = new WebStore();
    store.DefaultLanguage = 'en_US';
    store.Name = 'Test Store';
    insert store;

    Account testAccount = new Account();
    testAccount.Name = 'AcmeTestAcc';
    insert testAccount;

    BuyerAccount buyerAccount = new BuyerAccount();
    buyerAccount.BuyerId = testAccount.Id;
    buyerAccount.Name = 'AcmeTestAcc';
    buyerAccount.IsActive = true;
    insert buyerAccount;

    BuyerGroup buyerGrp = new BuyerGroup();
    buyerGrp.Name = 'AcmeTest';
    insert buyerGrp;

    BuyerGroupMember bgm = new BuyerGroupMember();
    bgm.BuyerGroupId = buyerGrp.Id;
    bgm.BuyerId = testAccount.Id;
    insert bgm;

    WebStoreBuyerGroup wbg = new WebStoreBuyerGroup();
    wbg.BuyerGroupId = buyerGrp.Id;
    wbg.WebStoreId = store.Id;
    insert wbg;

    WebCart wCart = new WebCart();
    wCart.AccountId = testAccount.Id;
    wCart.Name = 'Test Cart';
    wCart.Status = 'Active';
    wCart.Type = 'Cart';
    wCart.WebStoreId = store.Id;
    insert wCart;

    Product2 prod = new Product2();
    prod.Name = 'Test Product';
    prod.IsActive = true;
    prod.Description = 'test description';
    prod.ProductCode = '11111';
    prod.StockKeepingUnit = '11111';
    insert prod;

    Wrapper wrap = new Wrapper();
    wrap.webStore = store;
    wrap.acc = testAccount;
    wrap.product = prod;
    wrap.cart = wCart;
    // wrap.user = userObj;

    return wrap;
  }

  private class Wrapper {
    WebStore webStore;
    Account acc;
    Product2 product;
    WebCart cart;
  }
}