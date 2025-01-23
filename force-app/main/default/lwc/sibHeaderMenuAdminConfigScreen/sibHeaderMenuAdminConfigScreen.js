import { LightningElement, track } from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfigController.fetchConfigData';
import updateConfig from '@salesforce/apex/SIB_ConfigController.updateConfigData';
import Success_Code from '@salesforce/label/c.SIB_success_code';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Success from '@salesforce/label/c.SIB_Success';
import Configuration_updated_successfully from '@salesforce/label/c.SIB_Configuration_updated_successfully';
import Error_Code from '@salesforce/label/c.SIB_Error_Code';
import Error from '@salesforce/label/c.SIB_Error';
import MegaMenuId from '@salesforce/label/c.SIB_MegaMenuIdName';
import URL from '@salesforce/label/c.SIB_URL';
import menuConfigCustomLabel from '@salesforce/label/c.SIB_MenuConfigCustomLabel';
import SIB_SelfStudy from '@salesforce/label/c.SIB_SelfStudy';
import SIB_Foundations from '@salesforce/label/c.SIB_Foundations';
import SIB_Advanced from '@salesforce/label/c.SIB_Advanced';
import SIB_FoundationsPlusAdvanced from '@salesforce/label/c.SIB_FoundationsPlusAdvanced';
import SIB_InterviewFundamentals from '@salesforce/label/c.SIB_InterviewFundamentals';
import SIB_IBInterviewPrep from '@salesforce/label/c.SIB_IBInterviewPrep';
import SIB_PEInterviePrep from '@salesforce/label/c.SIB_PEInterviePrep';
import SIB_HedgeFundInterviewPrep from '@salesforce/label/c.SIB_HedgeFundInterviewPrep';
import SIB_InvestmentBanking from '@salesforce/label/c.SIB_InvestmentBanking';
import SIB_Private_Equity from '@salesforce/label/c.SIB_Private_Equity';
import SIB_EquityResearch from '@salesforce/label/c.SIB_EquityResearch';
import SIB_BondMarket from '@salesforce/label/c.SIB_BondMarket';
import SIB_Assetmanagement from '@salesforce/label/c.SIB_Assetmanagement';
import SIB_GlobalMarketandHedgeFund from '@salesforce/label/c.SIB_GlobalMarketandHedgeFund';
import SIB_Restructuring from '@salesforce/label/c.SIB_Restructuring';
import SIB_RealEstate from '@salesforce/label/c.SIB_RealEstate';
import SIB_SoftwareTech from '@salesforce/label/c.SIB_SoftwareTech';
import SIB_OilGas from '@salesforce/label/c.SIB_OilGas';
import SIB_BankingFIG from '@salesforce/label/c.SIB_BankingFIG';
import SIB_Insurance from '@salesforce/label/c.SIB_Insurance';
import SIB_PharmaBiotech from '@salesforce/label/c.SIB_PharmaBiotech';
import SIB_Mastering_Excel from '@salesforce/label/c.SIB_Mastering_Excel';
import SIB_BecomeProficientInPowerPoint from '@salesforce/label/c.SIB_BecomeProficientInPowerPoint';
import SIB_GettingStartedwithCopilot from '@salesforce/label/c.SIB_GettingStartedwithCopilot';
import SIB_OneOnOneMentoring from '@salesforce/label/c.SIB_OneOnOneMentoring';
import SIB_SelfStudyFreeResources from '@salesforce/label/c.SIB_SelfStudyFreeResources';
import SIB_EssentialComprehensive from '@salesforce/label/c.SIB_EssentialComprehensive';
import SIB_AppliedExcel from '@salesforce/label/c.SIB_AppliedExcel';
import SIB_FinancialStatementAnalysisAndAccounting from '@salesforce/label/c.SIB_FinancialStatementAnalysisAndAccounting';
import SIB_PrivateEquityTransition from '@salesforce/label/c.SIB_PrivateEquityTransition';
import SIB_FinancialModeling from '@salesforce/label/c.SIB_FinancialModeling';
import SIB_EnhancedEssential from '@salesforce/label/c.SIB_EnhancedEssential';
import SIB_WallStreetBootcamp from '@salesforce/label/c.SIB_WallStreetBootcamp';
import SIB_PrinciplesOfCapitalMarkets from '@salesforce/label/c.SIB_PrinciplesOfCapitalMarkets';
import SIB_EveningEssentials from '@salesforce/label/c.SIB_EveningEssentials';
import SIB_PythonTraining from '@salesforce/label/c.SIB_PythonTraining';
import SIB_CopilotFoundations from '@salesforce/label/c.SIB_CopilotFoundations';
import SIB_AdvancedTopics from '@salesforce/label/c.SIB_AdvancedTopics';
import SIB_SoftwareIndustryAnalysisFinancialModeling from '@salesforce/label/c.SIB_SoftwareIndustryAnalysisFinancialModeling';
import SIB_RealEstateFundamentals from '@salesforce/label/c.SIB_RealEstateFundamentals';
import SIB_CorporateOverview from '@salesforce/label/c.SIB_CorporateOverview';
import SIB_CorporateExcelTraining from '@salesforce/label/c.SIB_CorporateExcelTraining';
import SIB_ContinuingDevelopment from '@salesforce/label/c.SIB_ContinuingDevelopment';
import SIB_ProgramAdvisoryServices from '@salesforce/label/c.SIB_ProgramAdvisoryServices';
import SIB_PrivateEquity from '@salesforce/label/c.SIB_PrivateEquity';
import SIB_GlobalMarkets from '@salesforce/label/c.SIB_GlobalMarkets';
import SIB_DataScienceAndAnalytics from '@salesforce/label/c.SIB_DataScienceAndAnalytics';
import SIB_FinancialStatementAnalysis from '@salesforce/label/c.SIB_FinancialStatementAnalysis';
import SIB_CopilotForFinance from '@salesforce/label/c.SIB_CopilotForFinance';
import SIB_ModelingSolutions from '@salesforce/label/c.SIB_ModelingSolutions';
import SIB_ProfessionalSkillsTraining from '@salesforce/label/c.SIB_ProfessionalSkillsTraining';


export default class SibHeaderMenuAdminConfigScreen extends LightningElement {
        
    @track config = [];
    @track parsedData = {};

    labelMapping = {
    };

    label  = {
        Success_Code,
        Success,
        Configuration_updated_successfully,
        Error_Code,
        Error,
        MegaMenuId,
        URL,
        menuConfigCustomLabel,
        SIB_SelfStudy,
        SIB_Foundations,
        SIB_Advanced,
        SIB_FoundationsPlusAdvanced,
        SIB_InterviewFundamentals,
        SIB_IBInterviewPrep,
        SIB_PEInterviePrep,
        SIB_HedgeFundInterviewPrep,
        SIB_InvestmentBanking,
        SIB_Private_Equity,
        SIB_EquityResearch,
        SIB_BondMarket,
        SIB_Assetmanagement,
        SIB_GlobalMarketandHedgeFund,
        SIB_Restructuring,
        SIB_RealEstate,
        SIB_SoftwareTech,
        SIB_OilGas,
        SIB_BankingFIG,
        SIB_Insurance,
        SIB_PharmaBiotech,
        SIB_Mastering_Excel,
        SIB_BecomeProficientInPowerPoint,
        SIB_GettingStartedwithCopilot,
        SIB_OneOnOneMentoring,
        SIB_SelfStudyFreeResources,
        SIB_EssentialComprehensive,
        SIB_AppliedExcel,
        SIB_FinancialStatementAnalysisAndAccounting,
        SIB_PrivateEquityTransition,
        SIB_FinancialModeling,
        SIB_EnhancedEssential,
        SIB_WallStreetBootcamp,
        SIB_PrinciplesOfCapitalMarkets,
        SIB_EveningEssentials,
        SIB_PythonTraining,
        SIB_CopilotFoundations,
        SIB_AdvancedTopics,
        SIB_SoftwareIndustryAnalysisFinancialModeling,
        SIB_RealEstateFundamentals,
        SIB_CorporateOverview,
        SIB_CorporateExcelTraining,
        SIB_ContinuingDevelopment,
        SIB_ProgramAdvisoryServices,
        SIB_PrivateEquity,
        SIB_GlobalMarkets,
        SIB_DataScienceAndAnalytics,
        SIB_FinancialStatementAnalysis,
        SIB_CopilotForFinance,
        SIB_ModelingSolutions,
        SIB_ProfessionalSkillsTraining
    }

    connectedCallback() {
        this.loadConfig();
    }
    async loadConfig() {
        debugger;
        try {
            const data = await getConfig({ configType: this.label.MegaMenuId });
            if (data) {
                this.parsedData = JSON.parse(data);
                if(this.parsedData){
                    this.config = this.parsedData.Category
                    console.log(JSON.stringify(this.config));
                    // this.mapLabels();
                }
                
            }
        } catch (error) {
            console.log(error);
        }
    }

    // Update main section URL
    handleInputChange(event) {
        const sectionIndex = event.target.dataset.id;
        this.config[sectionIndex].URL = event.target.value;
        console.log('updated confi + '+ JSON.stringify(this.config));
        this.parsedData.Category = this.config;

    }

    // Update subcategory record URL
    handleSubCategoryInputChange(event) {
        const sectionIndex = event.target.dataset.parentId;
        const subCategoryIndex = event.target.dataset.id;
        const recordIndex = event.target.dataset.recordId;
        this.config[sectionIndex].subCategories[subCategoryIndex].records[recordIndex].URL = event.target.value;
        this.parsedData.Category = this.config;
    }

    handleSave(event) {
        const keyOrder = Object.keys(this.parsedData);

        updateConfig({ configStr: JSON.stringify(this.parsedData),keyOrder: JSON.stringify(keyOrder),configId:'MEGAMENU'})
            .then(result => {
                if (result.status == this.label.Success_Code) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.Success,
                            message: this.label.Configuration_updated_successfully,
                            variant: this.label.Success
                        })
                    );
                    this.config = [];
                    this.parsedData ={};
                    this.loadConfig();
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.Error,
                            message: result.message,
                            variant: this.label.Error_Code
                        })
                    );
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.Error,
                        message: error,
                        variant: this.label.Error_Code
                    })
                );
            });
    }

    handleCancel() {
        this.config = [];
        this.parsedData ={};
        this.loadConfig();
    }
}