import { LightningElement, api, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.FirstName';
import { getRecord } from 'lightning/uiRecordApi';
import basePath from "@salesforce/community/basePath";
import { CurrentPageReference } from 'lightning/navigation';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getNavigationMenuItems from '@salesforce/apex/SIB_NavigationMenuItemsController.getNavigationMenuItems';
import getMegaMenuConfiguration from '@salesforce/apex/SIB_NavigationMenuItemsController.getMegaMenuConfiguration';
import { navigate, NavigationContext, NavigationMixin } from 'lightning/navigation';
import { CartSummaryAdapter } from 'commerce/cartApi';
import isguest from '@salesforce/user/isGuest';
import { Labels } from './labels';
import getLogoutUrl from '@salesforce/apex/applauncher.IdentityHeaderController.getLogoutUrl';
import getStrivacityLoginUrl from '@salesforce/apex/SIB_UserRegistrationController.getStrivacityLoginUrl';

/**
 * @slot HeaderPromoBanner ({ locked: true, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "HeaderPromoBanner", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot HeaderSearchContainer ({ locked: true, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "HeaderSearchContainer", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot HeaderCartContainer ({ locked: true, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "HeaderCartContainer", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot HeaderMyProfile ({ locked: true, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "HeaderMyProfile", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot HeaderSiteLogo ({ locked: true, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "HeaderSiteLogo", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 */
export default class SibNavigationMenuCustom extends NavigationMixin(LightningElement) {
    searchPlaceHolderText = Labels.SIB_SearchPlaceHolderText
    mostPopularName = Labels.SIB_MostPopularName
    homePageUrl = Labels.SIB_HomePageUrl
    MegaMenuId = Labels.MegaMenuId;
    publicCourseCalendar_Info = Labels.SIB_PublicCourseCalendar_Info;
    publicCourseCalendar = Labels.SIB_PublicCourseCalendar;
    courseCalendarLabel = Labels.SIB_CourseCalendar;
    userMenu_Profile = Labels.SIB_UserMenu_Profile ;
    userMenu_Orders = Labels.SIB_UserMenu_Orders;
    userMenu_MyCourses = Labels.SIB_UserMenu_MyCourses;
    userMenu_ContactSupport = Labels.SIB_UserMenu_ContactSupport;
    userMenu_Logout = Labels.SIB_UserMenu_Logout;
    learnMore = Labels.SIB_LearnMore;
    backLabel= Labels.SIB_Back;
    headerPromoBanner = Labels.SIB_HeaderPromoBanner;
    SignInLabel = Labels.SIB_SignIn;
    selfStudyLabel = Labels.SIB_SelfStudy;
    publicCoursesLabel = Labels.SIB_PublicCourses;
    corporateTrainingLabel = Labels.SIB_CorporateTraining;
    academicLabel = Labels.SIB_Academic;
    aboutUsLabel = Labels.SIB_AboutUs;
    blogLabel = Labels.SIB_Blog;
    freeResourcesLabel = Labels.SIB_FreeResources;
    otherResourceLabel = Labels.SIB_OtherResource;
    fundamentalsLabel = Labels.SIB_Fundamentals;
    fundamentalsInfoLabel = Labels.SIB_Fundamentals_Info;
    foundationsLabel = Labels.SIB_Foundations;
    foundationsInfoLabel = Labels.SIB_Foundations_Info;
    advancedLabel = Labels.SIB_Advanced;
    advancedInfoLabel = Labels.SIB_Advanced_Info;
    foundationsPlusAdvancedLabel = Labels.SIB_FoundationsPlusAdvanced;
    foundationsPlusAdvancedInfoLabel = Labels.SIB_FoundationsPlusAdvanced_Info;
    interviewPrepLabel = Labels.SIB_InterviewPrep;
    interviewPrepInfoLabel = Labels.SIB_InterviewPrep_Info;
    interviewFundamentalsLabel = Labels.SIB_InterviewFundamentals;
    interviewprepAiLabel = Labels.SIB_InterviewprepAi;
    interviewprepAiProLabel = Labels.SIB_InterviewSmartprepAi_Pro;
    additionalMinutesLabel = Labels.SIB_AdditionalMinutes;
    upgradeToAIPlusLabel = Labels.SIB_UpgradeToAIPlus;
    ibInterviewPrepLabel = Labels.SIB_IBInterviewPrep;
    peInterviewPrepLabel = Labels.SIB_PEInterviePrep;
    hedgeFundInterviewPrepLabel = Labels.SIB_HedgeFundInterviewPrep;
    rolePrepLabel = Labels.SIB_RolePrep;
    rolePrepInfoLabel = Labels.SIB_RolePrep_Info;
    investmentBankingLabel = Labels.SIB_InvestmentBanking;
    privateEquityLabel = Labels.SIB_Private_Equity;
    equityResearchLabel = Labels.SIB_EquityResearch;
    bondMarketLabel = Labels.SIB_BondMarket;
    assetManagementLabel = Labels.SIB_Assetmanagement;
    globalMarketAndHedgeFundLabel = Labels.SIB_GlobalMarketandHedgeFund;
    restructuringLabel = Labels.SIB_Restructuring;
    industrySpecificLabel = Labels.SIB_IndustrySpecific;
    industrySpecific_Info = Labels.SIB_IndustrySpecific_Info;
    realEstateLabel = Labels.SIB_RealEstate;
    softwareTechLabel = Labels.SIB_SoftwareTech;
    oilGasLabel = Labels.SIB_OilGas;
    bankingFIGLabel = Labels.SIB_BankingFIG;
    insuranceLabel = Labels.SIB_Insurance;
    pharmaBiotechLabel = Labels.SIB_PharmaBiotech;
    productivityLabel = Labels.SIB_Productivity;
    productivityInfoLabel = Labels.SIB_Productivity_Info;
    masteringExcelLabel = Labels.SIB_Mastering_Excel;
    becomeProficientInPowerPointLabel = Labels.SIB_BecomeProficientInPowerPoint;
    gettingStartedWithCopilotLabel = Labels.SIB_GettingStartedwithCopilot;
    excelModellingChallengesLabel = Labels.SIB_ExcelModellingChallenges;
    pythonCoreDataAnalysisLabel = Labels.SIB_PythonCoreDataAnalysis;
    oneOnOneMentoringLabel = Labels.SIB_OneOnOneMentoring;
    selfStudyFreeResourcesLabel = Labels.SIB_SelfStudyFreeResources;
    viewAllSelfStudyBtnLabel = Labels.SIB_ViewAllSelfStudy_Btn;
    publicCoursesMenuItemLabel = Labels.SIB_PublicCourses_MenuItem;
    publicCoursesMenuItemInfoLabel = Labels.SIB_PublicCourses_MenuItem_Info;
    essentialComprehensiveLabel = Labels.SIB_EssentialComprehensive;
    appliedExcelLabel = Labels.SIB_AppliedExcel;
    financialStatementAnalysisAndAccountingLabel = Labels.SIB_FinancialStatementAnalysisAndAccounting;
    privateEquityTransitionLabel = Labels.SIB_PrivateEquityTransition;
    financialModelingLabel = Labels.SIB_FinancialModeling;
    enhancedEssentialLabel = Labels.SIB_EnhancedEssential;
    wallStreetBootcampLabel = Labels.SIB_WallStreetBootcamp;
    principlesOfCapitalMarketsLabel = Labels.SIB_PrinciplesOfCapitalMarkets;
    eveningEssentialsLabel = Labels.SIB_EveningEssentials;
    pythonTrainingLabel = Labels.SIB_PythonTraining;
    copilotFoundationsLabel = Labels.SIB_CopilotFoundations;
    advancedTopicsLabel = Labels.SIB_AdvancedTopics;
    softwareIndustryAnalysisFinancialModelingLabel = Labels.SIB_SoftwareIndustryAnalysisFinancialModeling;
    realEstateFundamentalsLabel = Labels.SIB_RealEstateFundamentals;
    viewAllPublicCoursesBtnLabel = Labels.SIB_ViewAllPublicCourses_Btn;
    corporateSolutionsLabel = Labels.SIB_CorporateSolutions;
    corporateSolutionsInfoLabel = Labels.SIB_CorporateSolutions_Info;
    corporateOverviewLabel = Labels.SIB_CorporateOverview;
    corporateExcelTrainingLabel = Labels.SIB_CorporateExcelTraining;
    continuingDevelopmentLabel = Labels.SIB_ContinuingDevelopment;
    programAdvisoryServicesLabel = Labels.SIB_ProgramAdvisoryServices;
    privateEquityLabel = Labels.SIB_PrivateEquity;
    globalMarketsLabel = Labels.SIB_GlobalMarkets;
    financialStatementLabel = Labels.SIB_FinancialStatementAnalysis;
    copilotForFinanceLabel = Labels.SIB_CopilotForFinance;
    dataScienceAndAnalyticsLabel = Labels.SIB_DataScienceAndAnalytics;
    modelingSolutionsLabel = Labels.SIB_ModelingSolutions;
    professionalSkillsTrainingLabel = Labels.SIB_ProfessionalSkillsTraining;
    viewAllCorporateSolutionsBtnLabel = Labels.SIB_ViewAllCorporateSolutions_Btn;


    static renderMode = 'light';
    _customerName = '';
    scriptLoaded = false;
    webStoreId;
    effectiveAccountId;
    @track shippingAddresses = [];
    shippingAddressesTemp =[];
    selectedShippingAddress;
    headerLogo;
    searchImg;
    totalProductCount = 0;
    isGuestUser = isguest;
    menuItemConfig;
    logoutUrl;
    cartId;
    isShowSpinner = false;
    spinnerMsg = 'Processing ';

    mapParams = {
        configType : this.MegaMenuId
    };
    @wire(getMegaMenuConfiguration, {mapParams : '$mapParams' })
    wiredCartConfig({ error, data }) {
        if (data) {
            this.menuItemConfig = data?.resultMap;
        } else if (error) {
            console.error(error);
        }
    };

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
        } else if (data) {
            this._customerName = data?.fields?.FirstName?.value;
        }
    }

    @wire(CartSummaryAdapter, {})
    CartAdapterFunc({error, data}){
        if (!this.isInSitePreview()){
            this.isLoading = true;
            if (data) {
                this.totalProductCount = parseInt(data?.totalProductCount); 
                this.cartId = data?.cartId;
            } else if (error) {
                this.totalProductCount = 0;
                console.log('CartAdapter Error: ' + error);
            }
        }
    }

    get courseCalendar() {
        return this.appendBasePath(this.menuItemConfig.SIB_CourseCalendar);
    }
    get selfStudyUrl() {
        return basePath + '/' + this.menuItemConfig?.SIB_SelfStudy;
    }
    
    get foundationsUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_Foundations);
    }
    
    get advancedUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_Advanced);
    }
    
    get foundationsPlusAdvancedUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_FoundationsPlusAdvanced);
    }
    
    get interviewFundamentals() {
        return this.appendBasePath(this.menuItemConfig?.SIB_InterviewFundamentals);
    }
    
    get ibInterviewPrepUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_IBInterviewPrep);
    }
    
    get peInterviewPrepUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_PEInterviePrep);
    }
    
    get hedgeFundInterviewPrepUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_HedgeFundInterviewPrep);
    }
    
    get investmentBankingUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_InvestmentBanking);
    }
    
    get privateEquityUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_Private_Equity);
    }
    
    get equityResearchUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_EquityResearch);
    }
    
    get bondMarketUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_BondMarket);
    }
    
    get assetManagementUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_Assetmanagement);
    }
    
    get globalMarketAndHedgeFundUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_GlobalMarketandHedgeFund);
    }
    
    get restructuringUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_Restructuring);
    }
    
    get realEstateUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_RealEstate);
    }
    
    get softwareTechUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_SoftwareTech);
    }
    
    get oilGasUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_OilGas);
    }
    
    get bankingFigUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_BankingFIG);
    }
    
    get insuranceUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_Insurance);
    }
    
    get pharmaBiotechUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_PharmaBiotech);
    }
    
    get masteringExcelUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_Mastering_Excel);
    }
    
    get proficientPowerPointUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_BecomeProficientInPowerPoint);
    }
    
    get gettingStartedWithCopilotUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_GettingStartedwithCopilot);
    }

    get excelModellingChallengesUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_ExcelModellingChallenges);
    }

    get pythonCoreDataAnalysisUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_PythonCoreDataAnalysis);
    }

    get interviewprepAiUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_InterviewprepAi);
    }

    get interviewprepAiProUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_InterviewSmartprepAi_Pro);
    }

    get upgradedToAiPlusUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_UpgradeToAIPlus);
    }

    get additionalMinutesUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_AdditionalMinutes);
    }
    
    get oneOnOneMentoringUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_OneOnOneMentoring);
    }
    
    get selfStudyFreeResourcesUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_SelfStudyFreeResources);
    }
    
    get publicCoursesUrl() {
        return basePath + '/' + this.menuItemConfig?.SIB_PublicCourses;
    }
    
    get essentialComprehensiveUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_EssentialComprehensive);
    }
    
    get appliedExcelUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_AppliedExcel);
    }
    
    get financialStatementAnalysisAndAccountingUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_FinancialStatementAnalysisAndAccounting);
    }
    
    get privateEquityTransitionUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_PrivateEquityTransition);
    }
    
    get financialModelingUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_FinancialModeling);
    }
    
    get enhancedEssentialUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_EnhancedEssential);
    }
    
    get wallStreetBootcampUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_WallStreetBootcamp);
    }
    
    get principlesOfCapitalMarketsUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_PrinciplesOfCapitalMarkets);
    }
    
    get eveningEssentialsUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_EveningEssentials);
    }
    
    get pythonTrainingUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_PythonTraining);
    }
    
    get copilotFoundationsUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_CopilotFoundations);
    }
    
    get advancedTopicsUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_AdvancedTopics);
    }
    
    get softwareIndustryAnalysisFinancialModelingUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_SoftwareIndustryAnalysisFinancialModeling);
    }
    
    get realEstateFundamentalsUrl() {
        return this.appendBasePath(this.menuItemConfig?.SIB_RealEstateFundamentals);
    }
    
    get corporateTrainingUrl() {
        return this.menuItemConfig?.SIB_CorporateTraining;
    }
    
    get corporateOverviewUrl() {
        return this.menuItemConfig?.SIB_CorporateOverview;
    }
    
    get corporateExcelTrainingUrl() {
        return this.menuItemConfig?.SIB_CorporateExcelTraining;
    }
    
    get continuingDevelopmentUrl() {
        return this.menuItemConfig?.SIB_ContinuingDevelopment;
    }
    
    get programAdvisoryServicesUrl() {
        return this.menuItemConfig?.SIB_ProgramAdvisoryServices;
    }
    
    get globalMarketsUrl() {
        return this.menuItemConfig?.SIB_GlobalMarkets;
    }
    
    get dataScienceAndAnalyticsUrl() {
        return this.menuItemConfig?.SIB_DataScienceAndAnalytics;
    }
    
    get financialStatementAnalysisUrl() {
        return this.menuItemConfig?.SIB_FinancialStatementAnalysis;
    }
    
    get copilotForFinanceUrl() {
        return this.menuItemConfig?.SIB_CopilotForFinance;
    }
    
    get modelingSolutionsUrl() {
        return this.menuItemConfig?.SIB_ModelingSolutions;
    }
    
    get professionalSkillsTrainingUrl() {
        return this.menuItemConfig?.SIB_ProfessionalSkillsTraining;
    }

    get corporatePrivateEquityUrl(){
        return this.menuItemConfig?.SIB_PrivateEquity;
    }
    
    get academicUrl() {
        return this.menuItemConfig?.SIB_Academic;
    }
    
    get blogUrl() {
        return this.menuItemConfig?.SIB_Blog;
    }
    
    get aboutUsUrl() {
        return this.menuItemConfig?.SIB_AboutUs;
    }
    
    get freeResourcesUrl() {
        return this.menuItemConfig?.SIB_FreeResources;
    }

    get myCourseUrl() {
        return  basePath + '/' + this.menuItemConfig?.SIB_UserMenu_MyCourses;
    }
    

    get customerName() {
        return this._customerName;
    }

    get showHeaderMenu() {
        // if( this.scriptLoaded && this.isLoaded ){
        if( this.isLoaded ){
            return true;
        }
        return false;
    }

    appendBasePath(url) {
        if(url) {
            if(url == "NA") {
                return false;
            }
            return url?.includes('https') ? url : basePath + url;
        }
    }

    fetchLogoutUrl() {
        getLogoutUrl()
            .then((result) => {            
                this.logoutUrl = result;
            })
            .catch((error) => {
                console.log('Error fetching logout URL:', error);
            });
    }

    connectedCallback() {
        if(!this.isGuestUser && !this.isInSitePreview()) {
            let url = window?.location?.href;
            if(url.includes('en-GB')) {
                let newUrl = url.split('/en-GB/');
                window.location.href = newUrl[0] + '/en-US/' + newUrl[1];
            }
        }
        window.addEventListener('bubbledtoastmessage', this.handleBubbledToastMessage.bind(this));
        this.fetchLogoutUrl();
    }
    disconnectedCallback() {
        window.removeEventListener('bubbledtoastmessage', this.handleBubbledToastMessage.bind(this));
    }
    
    handleBubbledToastMessage(message) {
        if(message && message.detail) {
            this.querySelector('c-sib-show-toast-message').showToast(message.detail.message,message.detail.type,5000);
        }
    }


    navigateToItem(event) {
        this.handleDesktopMenuBackBtn();
        const selectedOption = event.target.selectedOptions[0];
        const actionValue = selectedOption.dataset.id;
        const openInNewWindow = selectedOption.dataset.windowtype == 'NewWindow' ? true : false ;
        if(event.target.value == 'userLogout') {
            
            document.cookie =  Labels.SIB_StrivacityIdCookieName + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT; domain=."+Labels.SIB_SiteDomainName+"; path=/";
            window.location.href = this.logoutUrl
            return;
        }
        this.handleNavigation(actionValue, openInNewWindow);
        event.target.value = "";
    }

    async handleMobileNavigateToItem(event){
        this.handleDesktopMenuBackBtn();
        let siteUrl = event.target.dataset.id;
        const openInNewWindow =  event.target.dataset.windowtype == 'NewWindow' ? true : false ;
        
        if(siteUrl == 'userLogout'){
            //delete cookie
            document.cookie =  Labels.SIB_StrivacityIdCookieName + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT; domain=."+Labels.SIB_SiteDomainName+"; path=/";
            this.closeUserMenu();
            window.location.href = this.logoutUrl
            return;            
        }
        this.closeUserMenu();
        this.handleNavigation(siteUrl,openInNewWindow);
    }

    /**
     * the label or name of the nav menu linkset (NavigationMenuLinkSet.MasterLabel) exposed by the .js-meta.xml,
     * used to look up the NavigationMenuLinkSet.DeveloperName
     */
    @api linkSetMasterLabel = 'Default Navigation';

    /**
     * include the Home menu item, if true
     */
    @api addHomeMenuItem = false;

    get addHomeMenuItem(){
        return false;
    }

    /**
     * include image URLs in the response, if true
     * useful for building a tile menu with images
     */
    @api includeImageUrls = false;

    /**
        * the menu items when fetched by the NavigationItemsController
        */
    @track menuItems = [];

    /**
        * if the items have been loaded
        */
    @track isLoaded = false;

    /**
        * the error if it occurs
        */
    @track error;

    /**
        * the published state of the site, used to determine from which schema to 
        * fetch the NavigationMenuItems
        */
    publishStatus;

    /**
     * Using a custom Apex controller, query for the NavigationMenuItems using the
     * menu name and published state.
     * 
     * The custom Apex controller is wired to provide reactive results. 
     */
    @wire(getNavigationMenuItems, {
        navigationLinkSetMasterLabel: '$linkSetMasterLabel',
        publishStatus: '$publishStatus',
        addHomeMenuItem: '$addHomeMenuItem',
        includeImageUrl: '$includeImageUrls'
    })
    wiredMenuItems({error, data}) {
        if (data && !this.isLoaded) {
            var tempData = JSON.parse(JSON.stringify(data));
            this.menuItems = tempData.map((item, index) => {
                var showSubMenu = false;
                if(item.subMenu.length >= 1){
                    showSubMenu = true;
                    //1st inner child
                    item.subMenu = item.subMenu.map((item, index) => {
                        var showSubMenu = false;
                        var showAllButton = false;
                        if(item.subMenu.length >= 1){
                            showSubMenu = true;
                            showAllButton = true;
                            //2nd inner child
                            item.subMenu = item.subMenu.map((item, index) => {
                                var showSubMenu = false;
                                var showAllButton = false;
                                if(item.subMenu.length >= 1){
                                    showSubMenu = true;
                                    showAllButton = true;
                                    //3rd inner child
                                    item.subMenu = item.subMenu.map((item, index) => {
                                        var showSubMenu = false;
                                        var showAllButton = false;
                                        if(item.subMenu.length >= 1){
                                            showSubMenu = true;
                                            showAllButton = true;
                                            //4th inner child
                                            item.subMenu = item.subMenu.map((item, index) => {
                                                var showSubMenu = false;
                                                var showAllButton = false;
                                                if(item.subMenu.length >= 1){
                                                    showSubMenu = true;
                                                    showAllButton = true;
                                                    //5th inner child
                                                    item.subMenu = item.subMenu.map((item, index) => {
                                                        var showSubMenu = false;
                                                        var showAllButton = false;
                                                        if(item.subMenu.length >= 1){
                                                            showSubMenu = true;
                                                            showAllButton = true;
                                                            //6th inner child
                                                            item.subMenu = item.subMenu.map((item, index) => {
                                                                var showSubMenu = false;
                                                                var showAllButton = false;
                                                                if(item.subMenu.length >= 1){
                                                                    showSubMenu = true;
                                                                    showAllButton = true;
                                                                }
                                                                return {
                                                                    target: item.actionValue,
                                                                    id: index,
                                                                    label: item.label,
                                                                    type: item.actionType,
                                                                    subMenu: item.subMenu,
                                                                    imageUrl: item.imageUrl,
                                                                    windowName: item.target,
                                                                    displaySubMenu : showSubMenu,
                                                                    displayAllButton : showAllButton
                                                                }
                                                            });
                                                        }
                                                        return {
                                                            target: item.actionValue,
                                                            id: index,
                                                            label: item.label,
                                                            type: item.actionType,
                                                            subMenu: item.subMenu,
                                                            imageUrl: item.imageUrl,
                                                            windowName: item.target,
                                                            displaySubMenu : showSubMenu,
                                                            displayAllButton : showAllButton
                                                        }
                                                    });
                                                }
                                                return {
                                                    target: item.actionValue,
                                                    id: index,
                                                    label: item.label,
                                                    type: item.actionType,
                                                    subMenu: item.subMenu,
                                                    imageUrl: item.imageUrl,
                                                    windowName: item.target,
                                                    displaySubMenu : showSubMenu,
                                                    displayAllButton : showAllButton
                                                }
                                            });
                                        }
                                        return {
                                            target: item.actionValue,
                                            id: index,
                                            label: item.label,
                                            type: item.actionType,
                                            subMenu: item.subMenu,
                                            imageUrl: item.imageUrl,
                                            windowName: item.target,
                                            displaySubMenu : showSubMenu,
                                            displayAllButton : showAllButton
                                        }
                                    });
                                }
                                return {
                                    target: item.actionValue,
                                    id: index,
                                    label: item.label,
                                    type: item.actionType,
                                    subMenu: item.subMenu,
                                    imageUrl: item.imageUrl,
                                    windowName: item.target,
                                    displaySubMenu : showSubMenu,
                                    displayAllButton : showAllButton
                                }
                            });
                        }
                        return {
                            target: item.actionValue,
                            id: index,
                            label: item.label,
                            type: item.actionType,
                            subMenu: item.subMenu,
                            imageUrl: item.imageUrl,
                            windowName: item.target,
                            displaySubMenu : showSubMenu
                        }
                    });
                }
                return {
                    target: item.actionValue,
                    id: index,
                    label: item.label,
                    type: item.actionType,
                    subMenu: item.subMenu,
                    imageUrl: item.imageUrl,
                    windowName: item.target,
                    displaySubMenu : showSubMenu
                }
            });
            this.error = undefined;
            let e = this;
            setTimeout(() => {
                e.loadJSFile();
            }, 500);
            this.isLoaded = true;
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.isLoaded = true;
            console.error(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }

    @wire(AppContextAdapter)
    wireAppContext(result) {
        if (result.data) {
            this.webStoreId = result?.data?.webstoreId;
            this.getAccountId();
        }
    }

    @wire(NavigationContext)
    navContext;

    userMenuData;

    @wire(getNavigationMenuItems, {
        navigationLinkSetMasterLabel: 'Default My Account Menu',
        publishStatus: '$publishStatus',
        addHomeMenuItem: '$addHomeMenuItem',
        includeImageUrl: '$includeImageUrls'
    })
    handleUserMenuOPtions({error, data}){
        if(data){
            this.userMenuData = data;
        }
        else if(error){
            console.log(error);
        }


    }
    async getAccountId()
    {
        const result = await getSessionContext();
        if(result)
        {
            this.effectiveAccountId = result.effectiveAccountId;
        }
    }

    loadJSFile(){
        let headerScriptpath = SIBTheme + '/js/sib-header.js';
        Promise.all([
            loadScript(this, headerScriptpath)
        ]).then(() => {
            this.loadScrollFuction();
        })
        .catch(error => {
            console.error('SibNavigationMenuCustom initialLoadCSSAndJS---- '+error);
        });
    }

    /**
     * Using the CurrentPageReference, check if the app is 'commeditor'.
     * 
     * If the app is 'commeditor', then the page will use 'Draft' NavigationMenuItems. 
     * Otherwise, it will use the 'Live' schema.
    */
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app = currentPageReference && currentPageReference.state && currentPageReference.state.app;
        if (app === 'commeditor') {
            this.publishStatus = 'Draft';
        } else {
            this.publishStatus = 'Live';
        }
    }

    handleGoToHomePage(event){
        const siteUrl = event.currentTarget.dataset.url;
        this.handleNavigation(siteUrl,false);

    }

    constructor() {
        super();
        this.initialLoadCSSAndJS();
    }

    renderedCallback() {
        this.loadScrollFuction();
    }

    loadScrollFuction(){
        (async () => {
            let addWindowScrollEvent = false;
            function headerScroll() {
                var isHome = isHomePage();
                let header = document?.querySelector("header.header");
                let headerWrappertemp = document?.querySelector("div.headerWrapper");
                if(isHome){
                    //remove classes for home page
                    addWindowScrollEvent = true;
                    header?.classList?.contains("fixed-colors") ? header?.classList?.remove("fixed-colors") : null;
                    headerWrappertemp?.classList?.contains("fixed-width-custom") ? headerWrappertemp?.classList?.remove("fixed-width-custom") : null;
                }else{
                    //add classes for other pages
                    !header?.classList.contains("fixed-colors") ? header?.classList?.add("fixed-colors") : null;
                    !headerWrappertemp?.classList?.contains("fixed-width-custom") ? headerWrappertemp?.classList?.add("fixed-width-custom") : null;
                }
                if (header) {
                    let headerShow = header?.hasAttribute("data-scroll-show");
                    let headerShowTimer = header?.dataset?.scrollShow
                        ? header?.dataset?.scrollShow
                        : 500;
                    let startPoint = header?.dataset?.scroll ? header?.dataset?.scroll : 1;
                    let scrollDirection = 0;
                    let timer;
                    document.addEventListener("windowScroll", function (e) {
                        let scrollTop = window.scrollY;
                        clearTimeout(timer);
                        if (scrollTop >= startPoint) {
                            !header?.classList?.contains("_header-scroll")
                                ? header?.classList?.add("_header-scroll")
                                : null;
                            if (headerShow) {
                                if (scrollTop > scrollDirection)
                                    header?.classList?.contains("_header-show")
                                        ? header?.classList?.remove("_header-show")
                                        : null;
                                else
                                    !header?.classList?.contains("_header-show")
                                        ? header?.classList?.add("_header-show")
                                        : null;
                                timer = setTimeout(() => {
                                    !header?.classList?.contains("_header-show")
                                        ? header?.classList?.add("_header-show")
                                        : null;
                                }, headerShowTimer);
                            }
                        } else {
                            header?.classList?.contains("_header-scroll")
                                ? header?.classList?.remove("_header-scroll")
                                : null;
                            if (headerShow)
                                header?.classList?.contains("_header-show")
                                    ? header?.classList?.remove("_header-show")
                                    : null;
                        }
                        scrollDirection = scrollTop <= 0 ? 0 : scrollTop;
                    });
                }
            }

            function isHomePage(){
                var pathlength = window.location.href.split('?')[0].split('\/').length;
                var pageName = window.location.href.split('?')[0].split('\/')[pathlength - 1];
                var showHero = false;
                if (pageName == '') {
                    showHero = true;
                }
                return showHero;
            }

            setTimeout(() => {
                if (addWindowScrollEvent) {
                    let windowScroll = new Event("windowScroll");
                    window.addEventListener("scroll", function (e) {
                        document.dispatchEvent(windowScroll);
                    });
                }
            }, 0);
            headerScroll();
        })();
    }

    initialLoadCSSAndJS() {
        this.plusIcon = SIBTheme + '/images/Plus.png';
        this.minusIcon = SIBTheme + '/images/Minus.png';
        this.headerLogo = SIBTheme  + "/images/TrainingTheStreet.png";
        this.searchImg = SIBTheme  + "/images/search.png";
        let headerCSSPath = SIBTheme + '/css/header.css';
        let mainCSSPath = SIBTheme + '/css/sib-main.css';
        Promise.all([
            loadStyle(this, headerCSSPath)
        ]).then(() => {
            this.scriptLoaded = true;
        })
            .catch(error => {
                console.error('SibNavigationMenuCustom initialLoadCSSAndJS error---- '+error);
            });
    }

    handleMenuSelection(e){
        let key = e.currentTarget.dataset.keyurl;
        this.menuItems.map((item, index) => {
            if(item.target === key){
                // Create a new submenu item for "All"
                const grandChildItemSubMenu = {
                    target: item.actionValue,
                    id: index,
                    label: 'ALL',
                    type: item.actionType,
                    subMenu: item.subMenu,
                    imageUrl: item.imageUrl,
                    windowName: item.target,
                    displaySubMenu : showSubMenu,
                    displayAllAndBack : true
                };
                // Create a new submenu item for "Back"
                const grandChildItemSubMenuBack = {
                    target: item.actionValue,
                    id: index,
                    label: 'Back',
                    type: item.actionType,
                    subMenu: item.subMenu,
                    imageUrl: item.imageUrl,
                    windowName: key,
                    displaySubMenu : showSubMenu,
                    displayAllAndBack : true
                };
                item.subMenu.unshift(grandChildItemSubMenu);
                item.subMenu.unshift(grandChildItemSubMenuBack);
            }
            else{
                item.subMenu.map((item, index) => {
                    if(item.target === key){
                        // Create a new submenu item for "All"
                        const grandChildItemSubMenu = {
                            target: item.actionValue,
                            id: index,
                            label: 'ALL',
                            type: item.actionType,
                            subMenu: item.subMenu,
                            imageUrl: item.imageUrl,
                            windowName: item.target,
                            displaySubMenu : showSubMenu,
                            displayAllAndBack : true
                        };
                        // Create a new submenu item for "Back"
                        const grandChildItemSubMenuBack = {
                            target: item.actionValue,
                            id: index,
                            label: 'Back',
                            type: item.actionType,
                            subMenu: item.subMenu,
                            imageUrl: item.imageUrl,
                            windowName: key,
                            displaySubMenu : showSubMenu,
                            displayAllAndBack : true
                        };
                        item.subMenu.unshift(grandChildItemSubMenu);
                        item.subMenu.unshift(grandChildItemSubMenuBack);
                    }
                    else{
                        item.subMenu.map((item, index) => {
                            if(item.target === key){
                                // Create a new submenu item for "All"
                                const grandChildItemSubMenu = {
                                    target: item.actionValue,
                                    id: index,
                                    label: 'ALL',
                                    type: item.actionType,
                                    subMenu: item.subMenu,
                                    imageUrl: item.imageUrl,
                                    windowName: item.target,
                                    displaySubMenu : showSubMenu,
                                    displayAllAndBack : true
                                };
                                // Create a new submenu item for "Back"
                                const grandChildItemSubMenuBack = {
                                    target: item.actionValue,
                                    id: index,
                                    label: 'Back',
                                    type: item.actionType,
                                    subMenu: item.subMenu,
                                    imageUrl: item.imageUrl,
                                    windowName: key,
                                    displaySubMenu : showSubMenu,
                                    displayAllAndBack : true
                                };
                                item.subMenu.unshift(grandChildItemSubMenu);
                                item.subMenu.unshift(grandChildItemSubMenuBack);
                            }
                            else{
                                item.subMenu.map((item, index) => {
                                    if(item.target === key){
                                        // Create a new submenu item for "All"
                                        const grandChildItemSubMenu = {
                                            target: item.actionValue,
                                            id: index,
                                            label: 'ALL',
                                            type: item.actionType,
                                            subMenu: item.subMenu,
                                            imageUrl: item.imageUrl,
                                            windowName: item.target,
                                            displaySubMenu : showSubMenu,
                                            displayAllAndBack : true
                                        };
                                        // Create a new submenu item for "Back"
                                        const grandChildItemSubMenuBack = {
                                            target: item.actionValue,
                                            id: index,
                                            label: 'Back',
                                            type: item.actionType,
                                            subMenu: item.subMenu,
                                            imageUrl: item.imageUrl,
                                            windowName: key,
                                            displaySubMenu : showSubMenu,
                                            displayAllAndBack : true
                                        };
                                        item.subMenu.unshift(grandChildItemSubMenu);
                                        item.subMenu.unshift(grandChildItemSubMenuBack);
                                    }
                                    else{
                                        item.subMenu.map((item, index) => {
                                            if(item.target === key){
                                                // Create a new submenu item for "All"
                                                const grandChildItemSubMenu = {
                                                    target: item.actionValue,
                                                    id: index,
                                                    label: 'ALL',
                                                    type: item.actionType,
                                                    subMenu: item.subMenu,
                                                    imageUrl: item.imageUrl,
                                                    windowName: item.target,
                                                    displaySubMenu : showSubMenu,
                                                    displayAllAndBack : true
                                                };
                                                // Create a new submenu item for "Back"
                                                const grandChildItemSubMenuBack = {
                                                    target: item.actionValue,
                                                    id: index,
                                                    label: 'Back',
                                                    type: item.actionType,
                                                    subMenu: item.subMenu,
                                                    imageUrl: item.imageUrl,
                                                    windowName: key,
                                                    displaySubMenu : showSubMenu,
                                                    displayAllAndBack : true
                                                };
                                                item.subMenu.unshift(grandChildItemSubMenu);
                                                item.subMenu.unshift(grandChildItemSubMenuBack);
                                            }
                                            else{
                                                item.subMenu.map((item, index) => {
                                                    if(item.target === key){
                                                        // Create a new submenu item for "All"
                                                        const grandChildItemSubMenu = {
                                                            target: item.actionValue,
                                                            id: index,
                                                            label: 'ALL',
                                                            type: item.actionType,
                                                            subMenu: item.subMenu,
                                                            imageUrl: item.imageUrl,
                                                            windowName: item.target,
                                                            displaySubMenu : showSubMenu,
                                                            displayAllAndBack : true
                                                        };
                                                        // Create a new submenu item for "Back"
                                                        const grandChildItemSubMenuBack = {
                                                            target: item.actionValue,
                                                            id: index,
                                                            label: 'Back',
                                                            type: item.actionType,
                                                            subMenu: item.subMenu,
                                                            imageUrl: item.imageUrl,
                                                            windowName: key,
                                                            displaySubMenu : showSubMenu,
                                                            displayAllAndBack : true
                                                        };
                                                        item.subMenu.unshift(grandChildItemSubMenu);
                                                        item.subMenu.unshift(grandChildItemSubMenuBack);
                                                    }
                                                    else{
                                                        item.subMenu.map((item, index) => {
                                                            if(item.target === key){
                                                                // Create a new submenu item for "All"
                                                                const grandChildItemSubMenu = {
                                                                    target: item.actionValue,
                                                                    id: index,
                                                                    label: 'ALL',
                                                                    type: item.actionType,
                                                                    subMenu: item.subMenu,
                                                                    imageUrl: item.imageUrl,
                                                                    windowName: item.target,
                                                                    displaySubMenu : showSubMenu,
                                                                    displayAllAndBack : true
                                                                };
                                                                // Create a new submenu item for "Back"
                                                                const grandChildItemSubMenuBack = {
                                                                    target: item.actionValue,
                                                                    id: index,
                                                                    label: 'Back',
                                                                    type: item.actionType,
                                                                    subMenu: item.subMenu,
                                                                    imageUrl: item.imageUrl,
                                                                    windowName: key,
                                                                    displaySubMenu : showSubMenu,
                                                                    displayAllAndBack : true
                                                                };
                                                                item.subMenu.unshift(grandChildItemSubMenu);
                                                                item.subMenu.unshift(grandChildItemSubMenuBack);
                                                            }
                                                            else{
                                                                console.log('no more child menus');
                                                            }
                                                            return{
                                                                target: item.actionValue,
                                                                id: index,
                                                                label: item.label,
                                                                type: item.actionType,
                                                                subMenu: item.subMenu,
                                                                imageUrl: item.imageUrl,
                                                                windowName: item.target,
                                                                displaySubMenu : showSubMenu
                                                            }
                                                        });
                                                    }
                                                    return{
                                                        target: item.actionValue,
                                                        id: index,
                                                        label: item.label,
                                                        type: item.actionType,
                                                        subMenu: item.subMenu,
                                                        imageUrl: item.imageUrl,
                                                        windowName: item.target,
                                                        displaySubMenu : showSubMenu
                                                    }
                                                });
                                            }
                                            return{
                                                target: item.actionValue,
                                                id: index,
                                                label: item.label,
                                                type: item.actionType,
                                                subMenu: item.subMenu,
                                                imageUrl: item.imageUrl,
                                                windowName: item.target,
                                                displaySubMenu : showSubMenu
                                            }
                                        });
                                    }
                                    return{
                                        target: item.actionValue,
                                        id: index,
                                        label: item.label,
                                        type: item.actionType,
                                        subMenu: item.subMenu,
                                        imageUrl: item.imageUrl,
                                        windowName: item.target,
                                        displaySubMenu : showSubMenu
                                    }
                                });
                            }
                            return{
                                target: item.actionValue,
                                id: index,
                                label: item.label,
                                type: item.actionType,
                                subMenu: item.subMenu,
                                imageUrl: item.imageUrl,
                                windowName: item.target,
                                displaySubMenu : showSubMenu
                            }
                        });
                    }
                    return{
                        target: item.actionValue,
                        id: index,
                        label: item.label,
                        type: item.actionType,
                        subMenu: item.subMenu,
                        imageUrl: item.imageUrl,
                        windowName: item.target,
                        displaySubMenu : showSubMenu
                    }
                });
            }
            return{
                target: item.actionValue,
                id: index,
                label: item.label,
                type: item.actionType,
                subMenu: item.subMenu,
                imageUrl: item.imageUrl,
                windowName: item.target,
                displaySubMenu : showSubMenu
            }
        });

    }

    get showCountBadge(){
        return this.totalProductCount > 0 ? true : false;
    }

    handleGoToCart(e){
        this.handleDesktopMenuBackBtn();
        this.closeNavMenu();
        let siteUrl = basePath + '/cart';
        this.handleNavigation(siteUrl,false);
    }

    searchInp = '';
    handleSearchInput(evt){
        if(evt.keyCode === 13){
            this.handleSearch();
        }
        this.searchInp = evt.target.value;
    }

    handleSearch(){
        var searchInp = this.searchInp;
        if(searchInp && searchInp != '' && searchInp.length > 0){
            let siteUrl = basePath + '/global-search/'+ searchInp;
            this.handleDesktopMenuBackBtn();
            this.handleNavigation(siteUrl)
        }
    }

    /**
     * Determines if you are in the experience builder currently
     */
    isInSitePreview() {
        let url = document.URL;
        return (
        url.indexOf('sitepreview') > 0 ||
        url.indexOf('livepreview') > 0 ||
        url.indexOf('live-preview') > 0 ||
        url.indexOf('live.') > 0 ||
        url.indexOf('.builder.') > 0
        );
    }
    toggleClass(element, removeClass, addClass) {
        if (element) {
            if (removeClass) {  
                element.classList.remove(removeClass);
            }
            if (addClass) {  
                element.classList.add(addClass);
            }
        } else {
            console.log('Element not found');
        }
    }

    hideElement(element) {
        if (element) {
            element.style.display = "none";
        }
    }

    showElement(element) {
        if (element) {
            element.style.display = "flex";
        }
    }

    handleMobileMenu() {
        this.hideElement(this.refs.backBtn);
        const menuElement = this.querySelector('[data-id="menu"]');
        this.toggleClass(menuElement, "hideMenu", "showMenu");
    }

    closeNavMenu() {
        const menuElement = this.querySelector('[data-id="menu"]');
        this.toggleClass(menuElement, "showMenu", "hideMenu");

        const menuItemElement = this.querySelector('.showMenuItem');;
        this.toggleClass(menuItemElement, "showMenuItem", "");

    }

    handleUserMenu() {
        if(!this.isGuestUser){
            const menuElement = this.querySelector('[data-id="user-menu"]');
            this.toggleClass(menuElement, "hideMenu", "showMenu");
        }
    }

    closeUserMenu() {
        const menuElement = this.querySelector('[data-id="user-menu"]');
        this.toggleClass(menuElement, "showMenu", "hideMenu");
    }

    handleMobileMenuItem(event) {
        this.showElement(this.refs.backBtn);
        const dataId = event.currentTarget.dataset.id;
        const menuElement = this.querySelector(`.${dataId}`);
        this.toggleClass(menuElement, 'showMenuItem', 'showMenuItem');
    }

    handleAccView(event) {
        const dataId = event.currentTarget.dataset.id;
        const menuElement = this.querySelector(`.${dataId}`);
        if (menuElement) {
            menuElement.classList.toggle("show-acc-body");
        } else {
            console.log('Accordion element not found');
        }
    }

    handleBackBtn() {
        this.hideElement(this.refs.backBtn);
        const refs = [this.refs.selfStudy, this.refs.public, this.refs.corporate];
        refs.forEach(ref => this.toggleClass(ref, 'showMenuItem', ''));
    }

    handleDesktopMenuBackBtn() {
        if (this.currentlyOpenMenu) {
            const backBtn = this.querySelector('.show-mega-menu');
            const menuIconEle = this.querySelector('.icon-hover');
            
            // Close the currently open menu
            this.toggleClass(this.currentlyOpenMenu, 'show-mega-menu', '');
            this.toggleClass(backBtn, 'show-mega-menu', '');
            this.toggleClass(menuIconEle, 'icon-hover', '');
            
            // Reset currentlyOpenMenu
            this.currentlyOpenMenu = null;
        }
    }
    
    @track currentlyOpenMenu = null;

    handleSubMenu(event) {
        event.preventDefault();
        event.stopPropagation();
        
        const dataId = event.currentTarget.dataset.id;
        const menuElement = this.querySelector(`.${dataId}`);
        const menuIconEle = event.currentTarget;
        const backBtn = this.querySelector('.show-mega-menu');

        // Checking if the current menu is already open
        if (this.currentlyOpenMenu === menuElement) {
            // Close the current open menu
            this.toggleClass(menuElement, '', 'show-mega-menu');
            this.toggleClass(backBtn, 'show-mega-menu', '');
            this.toggleClass(menuIconEle, 'icon-hover', '');
            this.currentlyOpenMenu = null; // Reset the current open menu
        } else {
            // Close any previous opened menu and reset icon
            if (this.currentlyOpenMenu) {
                this.toggleClass(this.currentlyOpenMenu, '', 'show-mega-menu');
                const prevIconEle = this.querySelector('.icon-hover');
                this.toggleClass(prevIconEle, 'icon-hover', '');
            }

            // Open the new menu
            this.toggleClass(menuElement, '', 'show-mega-menu');
            this.toggleClass(backBtn, 'show-mega-menu', '');
            this.toggleClass(menuIconEle, '', 'icon-hover');
            this.currentlyOpenMenu = menuElement; // Set the current open menu
        }
    }

    handleUrlNavigation(event) {
        event.preventDefault();
        const siteUrl = event.currentTarget.dataset.url;
        const backBtn = this.querySelector('.show-mega-menu');
        this.toggleClass(backBtn, "show-mega-menu", "");
        const prevIconEle = this.querySelector('.icon-hover');
        this.toggleClass(prevIconEle, 'icon-hover', '');
        this.currentlyOpenMenu = null;
        this.handleNavigation(siteUrl,false);
    }

    handleNavigation(siteUrl, isNewWindow){
        const target = isNewWindow ? '_blank' : '_self';
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: siteUrl
            }
        })
        .then((siteUrl) => {
            window.open(siteUrl,target);
        });
    }

    handleSignIn() {
        this.isShowSpinner = true;
        let pageName = window?.location?.href?.split(Labels.SIB_LWRSiteURL + '/');
        let isCartAvailable = (this.totalProductCount > 0 && this.cartId != null) ? 'true&cartId=' + this.cartId : 'false';
        let mapParams = {
            'startUrl': basePath?.replace('/en-GB', '') + '/processing?page=' + pageName[1]?.replace('en-GB/', '') + '&preserveCart=' + isCartAvailable
        };
        getStrivacityLoginUrl({ 'dataMap': mapParams})
        .then((result) => {
            if(result.isSuccess) {
                this.isShowSpinner = false;
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__webPage',
                    attributes: {
                        url:  result.ssoUrl
                    }
                }).then((url) => {
                    window.open(url,'_self');
                });
            }
           
        })
        .catch((e) => {
            this.isShowSpinner = false;
            console.log(e);
        })
        .finally(() => {

        });
    }
}