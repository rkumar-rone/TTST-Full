import { LightningElement, api } from 'lwc';

export default class SibSpinner extends LightningElement {
    static renderMode = 'light';
    
    @api
    messageState;
}