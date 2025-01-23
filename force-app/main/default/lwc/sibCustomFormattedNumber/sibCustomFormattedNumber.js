import { LightningElement,api } from 'lwc';

export default class SibCustomFormattedNumber extends LightningElement {
  @api value;
  @api currencyCode;
  integerPart = '';
  fractionPart = '';
  
  get isUSD(){
    return this.currencyCode === 'USD';
  }

  get isCAD(){
    return this.currencyCode === 'CAD';
  }

  get isEUR(){
    return this.currencyCode === 'EUR';
  }


  connectedCallback() {
    if (this.value) {
      const parts = this.value.toString().split('.');
      this.integerPart = parts[0];
      this.fractionPart = parts[1] ? '.' + parts[1] : '';
    }
  }
}