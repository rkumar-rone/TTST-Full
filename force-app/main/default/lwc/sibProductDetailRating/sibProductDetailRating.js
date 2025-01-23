import { LightningElement } from 'lwc';
import { calculateReviewStars } from 'c/sibUtils';
export default class SibProductDetailRating extends LightningElement {

    avgRating;
    totalRatings;
    stars=[];

    get showReview(){
        return this.stars.length>0;
    }

    connectedCallback() {
        window.addEventListener('ratingreviews', this.handleRatingReviews.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('ratingreviews', this.handleRatingReviews.bind(this));
    }

    handleRatingReviews(msg) {
        this.avgRating = parseFloat(msg.detail.rating).toFixed(1);
        
        if(this.avgRating){
            this.stars = calculateReviewStars(this.avgRating);
        }
        this.totalRatings = msg.detail.reviews;
    }
}