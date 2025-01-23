import { LightningElement, api, wire } from 'lwc';
import questionsList from '@salesforce/apex/FrequentlyQuestions.getFrequentlyQuestions';

export default class FrequentlyQuestions extends LightningElement {

    @api textTitle;
    @api textTitleSize;
    @api textSize;
    @api textColor;

    questions;
	isLoading = false;

    @wire(questionsList)
	wiredQuestionsList({ error, data }) {
        if (data) {

			let generalQuestions = [];
			let publicQuestions = [];
			let selfStudyQuestions = [];

            data.map((question) => {
				if (question.Category__c == "generalLabels") {
					generalQuestions.push(question);
				}
				if (question.Category__c == "publicLabels") {
					publicQuestions.push(question);
				}
				if (question.Category__c == "selfStudyLabels") {
					selfStudyQuestions.push(question);
				}
			});

			this.questions = { 
				general: generalQuestions , 
				public:  publicQuestions , 
				selfStudy: selfStudyQuestions
			};

			this.isLoading = true;

        }else{
            console.log(error);
        }
	};

    connectedCallback() {
		// Set text size
		this.textSize = 'font-size:' + this.textSize;
        // Set text color
        this.textColor = 'color:' + this.textColor;
        // Set text title size
        this.textTitleSize = 'font-size:' + this.textTitleSize;
        // Set text title size
        this.textTitle = this.textTitle;
	}
}