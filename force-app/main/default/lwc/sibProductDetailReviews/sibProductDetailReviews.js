import { LightningElement,api } from 'lwc';
import { calculateReviewStars } from 'c/sibUtils';
import RATING_HEADING from '@salesforce/label/c.SIB_PDPRatingHeading';
import getStoredReviews from '@salesforce/apex/SIB_CourseReviewController.getStoredReviews';

export default class SibProductDetailReviews extends LightningElement {
    static renderMode = 'light';

    @api recordId;

    reviews=[];
    averageRating;
    totalRatings;

    labels={
        RATING_HEADING,
    }

    connectedCallback(){
        if(this.recordId){
            this.getReviews();
        }
    }

    get showReviews(){
        return this.reviews.length>0;
    }
    

    getReviews(){
        let dataMap={
           'CourseId':this.recordId
        }
        getStoredReviews({'dataMap':dataMap})
        .then(result=>{
            if(result.isSuccess && result.Reviews){
                let tempReviews=[];
                result.Reviews.forEach((review)=>{
                    let item = review;
                    item['stars'] = calculateReviewStars(item.Rating__c);
                    tempReviews.push(item);
                });
                this.reviews = tempReviews;
                this.averageRating = result.AverageRating;
                this.totalRatings = result.TotalRatings;
                this.dispatchEvent(
                    new CustomEvent('ratingreviews', {
                        detail: {rating: this.averageRating, reviews: this.totalRatings},
                        bubbles: true,
                        composed: true
                    })
                );
            }
            else{

            }
        }).catch(error=>{
            console.error(error);
        });
    }
}