import { LightningElement,api,wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import getMegaMenuConfiguration from '@salesforce/apex/SIB_NavigationMenuItemsController.getMegaMenuConfiguration';
import MegaMenuId from '@salesforce/label/c.SIB_MegaMenuIdName';

export default class SibProductDetailCategoryPath extends LightningElement {
    
    static renderMode = 'light';
    menuItemConfig;

    mapParams = {
        configType : MegaMenuId
    };

    categoryPath;

    @wire(getMegaMenuConfiguration, {mapParams : '$mapParams' })
    wiredCartConfig({ error, data }) {
        if (data) {
            this.menuItemConfig = data.megaMenuConfig.Category;
            this.categoryPath = this.fetchCategoryPath();
        } else if (error) {
            console.error(error);
        }
    };

    _productDetail;
    @api
    get productDetail(){
        return this._productDetail;
    }
    set productDetail(value){
        this._productDetail = value;
        if(value!=null){
            this.categoryPath = this.fetchCategoryPath();
        }
    }

    get showDetails() {
        return this.productDetail != null && this.menuItemConfig;
    }

    fetchCategoryPath() {
        let pathList = [{ url: basePath + '/', name: 'Home', id: 'home', isLast: false }];
        let count = 0;
        if(this._productDetail && this.menuItemConfig){
        for (let currPath of this._productDetail.primaryProductCategoryPath.path) {
            count++;
            const index = this.menuItemConfig.findIndex((config)=>config.value==currPath.name);
            let catUrl;
            if(index>-1){ //new logic for Self-Study (independent category pages)
                catUrl = '/'+this.menuItemConfig[index].URL ;
                pathList.push({ url: basePath + catUrl, name: currPath.name, id: currPath.id, isLast: count == this.productDetail.primaryProductCategoryPath.path.length });
            }
            else{ //Existing Logic
                let catUrl = currPath.urlName != null ? currPath.urlName : currPath.id ;
                pathList.push({ url: basePath + '/category/' + catUrl, name: currPath.name, id: currPath.id, isLast: count == this.productDetail.primaryProductCategoryPath.path.length });
            }
        }
        return pathList;
    }
    }
}