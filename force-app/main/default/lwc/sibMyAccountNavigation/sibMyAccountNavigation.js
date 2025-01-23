import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class SibMyAccountNavigation extends NavigationMixin(LightningElement) {
    profileActivated = false;
    orderHistoryActivated = false;
    wishlistActivated = false;
    subscriptionsActivated = false;
    addressesActivated = false;
    cartsActivated = false;
    quotesActivated = false;
    activeNav = '';
    activeLabel = '';

    pageName_Profile = 'myprofile';
    pageName_OrderHistory = 'OrderSummary/OrderSummary/Default';
    pageName_Wishlist = 'mylists';
    pageName_Addresses = 'addresses';
    pageName_subscriptions = 'subscriptions';
    pageName_Carts = 'mycarts';
    pageName_Quotes = 'myquotes';


    navigateToItem(event) {
        let pageKey = '/' + event.target.dataset.id;
        console.log('navigate to--' + pageKey);

        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": pageKey
            }
        });
    }

    goToMobileNav(event) {
        let pageKey = '/' + event.target.value;
        console.log('navigate to--' + pageKey);

        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": pageKey
            }
        });
    }
    
    @wire(CurrentPageReference) urlUpdated(pageReference) {
        this.setCurrentNav();
    }

    setCurrentNav() {
        let currPath = window.location.pathname;
        let activeNavKey = '';
        if(currPath.includes(this.pageName_Profile)) {
            activeNavKey = this.pageName_Profile;
            this.activeLabel = 'My Profile';
            this.profileActivated = true;
            this.orderHistoryActivated = false;
            this.wishlistActivated = false;
            this.addressesActivated = false;
            this.subscriptionsActivated = false;
            this.cartsActivated = false;
            this.quotesActivated = false;
        }else if(currPath.includes(this.pageName_OrderHistory)) {
            activeNavKey = this.pageName_OrderHistory;
            this.activeLabel = 'Order History';
            this.profileActivated = false;
            this.orderHistoryActivated = true;
            this.wishlistActivated = false;
            this.addressesActivated = false;
            this.subscriptionsActivated = false;
            this.cartsActivated = false;
            this.quotesActivated = false;
        }else if(currPath.includes(this.pageName_subscriptions)) {
            activeNavKey = this.pageName_subscriptions;
            this.activeLabel = 'Subscriptions';
            this.profileActivated = false;
            this.orderHistoryActivated = false;
            this.wishlistActivated = false;
            this.addressesActivated = false;
            this.subscriptionsActivated = true;
            this.cartsActivated = false;
            this.quotesActivated = false;
        }else if(currPath.includes(this.pageName_Wishlist)) {
            activeNavKey = this.pageName_Wishlist;
            this.activeLabel = 'My List';
            this.profileActivated = false;
            this.orderHistoryActivated = false;
            this.wishlistActivated = true;
            this.addressesActivated = false;
            this.subscriptionsActivated = false;
            this.cartsActivated = false;
            this.quotesActivated = false;
        }else if(currPath.includes(this.pageName_Addresses)) {
            activeNavKey = this.pageName_Addresses;
            this.activeLabel = 'Addresses';
            this.profileActivated = false;
            this.orderHistoryActivated = false;
            this.wishlistActivated = false;
            this.addressesActivated = true;
            this.subscriptionsActivated = false;
            this.cartsActivated = false;
            this.quotesActivated = false;
        }
        else if(currPath.includes(this.pageName_Carts)) {
            activeNavKey = this.pageName_Carts;
            this.activeLabel = 'My Carts';
            this.profileActivated = false;
            this.orderHistoryActivated = false;
            this.wishlistActivated = false;
            this.addressesActivated = false;
            this.subscriptionsActivated = false;
            this.cartsActivated = true;
            this.quotesActivated = false;
        }
        else if(currPath.includes(this.pageName_Quotes)) {
            activeNavKey = this.pageName_Quotes;
            this.activeLabel = 'My Quotes';
            this.profileActivated = false;
            this.orderHistoryActivated = false;
            this.wishlistActivated = false;
            this.addressesActivated = false;
            this.subscriptionsActivated = false;
            this.cartsActivated = false;
            this.quotesActivated = true;
        }

        this.activeNav = activeNavKey;
        const activeDiv = this.template.querySelectorAll('.Account-Tab');
        activeDiv.forEach((node) => {
            if(node.dataset.id === activeNavKey) {
                node.classList.add('active-tab');
            }else {
                node.classList.contains('active-tab') ? node.classList.remove('active-tab') : null;
            }
        });
    }

    renderedCallback(){
        this.setCurrentNav();
    }
}