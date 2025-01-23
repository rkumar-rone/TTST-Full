import { LightningElement, api } from 'lwc';
import getTTSEventRichText from '@salesforce/apex/TTSEventRichTextController.getTTSEventRichText';

export default class TtsEventRichText extends LightningElement {
    @api recordId
    eventRichText;
    error;

    connectedCallback() {
        getTTSEventRichText({ recordId: this.recordId})
            .then(result => {
                console.log('result: ' + result);
                this.eventRichText = result;
            })
            .catch(error => {
                this.error = error;
            });
    }
}