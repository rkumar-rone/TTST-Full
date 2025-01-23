import { LightningElement } from 'lwc';
import SIBTemplateImages from '@salesforce/resourceUrl/SIBTemplateImages';
import saveConfig from '@salesforce/apex/SIB_ConfiguratorController.saveConfiguratorTemplateSettings';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorTemplateSettings';

export default class SibTemplateConfigurator extends LightningElement {

templateOne;
templateTwo;
templateTwoCart;
templateTwoPDP;
templateTwoPLP;
selectedTemplate;

connectedCallback(){
   this.initialLoadCSSAndJS();
   getConfig({})
   .then(result => {
      if(result == 'templateOne'){
         this.template.querySelector('[data-id="templateImageOne"]').classList.add('sibImageWrapperSelect');
         this.template.querySelector('[data-id="templateImageTwo"]').classList.remove('sibImageWrapperSelect');
      }
      else if(result == 'templateTwo'){
         this.template.querySelector('[data-id="templateImageTwo"]').classList.add('sibImageWrapperSelect');
         this.template.querySelector('[data-id="templateImageOne"]').classList.remove('sibImageWrapperSelect');
      }
   })
   .catch(error => {
      window.console.log("error",error.message);
   });
}

initialLoadCSSAndJS() {
   this.templateOne = SIBTemplateImages + '/SIBTemplates/Generateo.png';
   this.templateTwo = SIBTemplateImages + '/SIBTemplates/Quest.png';
   this.templateTwoPLP = SIBTemplateImages + '/SIBTemplates/PLP.png';
   this.templateTwoPDP = SIBTemplateImages + '/SIBTemplates/PDP.png';
   this.templateTwoCart = SIBTemplateImages + '/SIBTemplates/Cart.png';
}

onSelectTemplate(event){
   if(event.currentTarget.dataset.id == 'templateOne'){
      this.selectedTemplate = 'templateOne';
      this.template.querySelector('[data-id="templateImageOne"]').classList.add('sibImageWrapperSelect');
      this.template.querySelector('[data-id="templateImageTwo"]').classList.remove('sibImageWrapperSelect');
   }
   else if(event.currentTarget.dataset.id == 'templateTwo'){
      this.selectedTemplate = 'templateTwo';
      this.template.querySelector('[data-id="templateImageTwo"]').classList.add('sibImageWrapperSelect');
      this.template.querySelector('[data-id="templateImageOne"]').classList.remove('sibImageWrapperSelect');
   }
}
handleSaveConfig(){
   saveConfig({
      selectedTemplate :  this.selectedTemplate
   })
   .then(result => {
      window.console.log(result);
   })
   .catch(error => {
      window.console.log("error",error);
      this.error = error.message;
   });
}
}