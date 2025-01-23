import { LightningElement, api, wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import getNavigationMenuItems from '@salesforce/apex/SIB_NavigationMenuItemsController.getNavigationMenuItems';
export default class SibBreadcrumb extends LightningElement {

    @api navMenu;
    @api navItem;
    currentPath;

    @wire(getNavigationMenuItems, {
            navigationLinkSetMasterLabel:'$navMenu', 
            publishStatus:'Live',
            addHomeMenuItem:true,
            includeImageUrl:false
        })
    wiredConfig({ error, data }) {
        if (data) {
            this.currentPath = data.find(record => record.label == this.navItem);

        } else if (error) {
            console.error('Error in wire: '+error);
        }
    };

    get homeLabel(){
        return 'Home';
    }

    get homePath(){
        return basePath;
    }
}