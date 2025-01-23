import { LightningElement, api } from 'lwc';
import { navigate, NavigationContext, NavigationMixin } from 'lightning/navigation';
import getDeadlineInfo from '@salesforce/apex/CourseManagementController.getDeadlineInfo';
import cancelCourseProcess from '@salesforce/apex/CourseManagementController.cancelCourseProcess';
import lmsInactive from '@salesforce/label/c.SIB_LmsInactive';
import progressText from '@salesforce/label/c.SIB_ProgressText';
import progressTextSuffix from '@salesforce/label/c.SIB_ProgressTextSuffix';
import goToCourseBtn from '@salesforce/label/c.SIB_GoToCourseBtn';
import moreBtn from '@salesforce/label/c.SIB_MoreBtn';
import switchSessions from '@salesforce/label/c.SIB_SwitchSessions';
import addSessions from '@salesforce/label/c.SIB_AddSessions';
import edit from '@salesforce/label/c.SIB_Edit';
import cancelBtn from '@salesforce/label/c.SIB_CancelBtn';
import cancelCourse from '@salesforce/label/c.SIB_CancelCourse';
import afterDeadLineText from '@salesforce/label/c.SIB_AfterDeadLineText';
import afterDeadLinePolicyText from '@salesforce/label/c.SIB_AfterDeadLinePolicyText';
import acknowledge from '@salesforce/label/c.SIB_Acknowledge';
import beforeDeadLineText from '@salesforce/label/c.SIB_BeforeDeadLineText';
import waitlistText from '@salesforce/label/c.SIB_waitlistText';
import cancelCourseBtn from '@salesforce/label/c.SIB_CancelCourseBtn';
import changedMindBtn from '@salesforce/label/c.SIB_ChangedMindBtn';
import courseCancelledSuccessMsg from '@salesforce/label/c.SIB_CourseCancelledSuccessMsg';
import courseCancelledErrorMsg from '@salesforce/label/c.SIB_CourseCancelledErrorMsg';
import courseCancelledAcknowledgeMsg from '@salesforce/label/c.SIB_CourseCancelledAcknowledgeMsg';
import courseDetailsOrStatus from '@salesforce/label/c.SIB_Course_DetailsOrStatus';
import basePath from "@salesforce/community/basePath";

const SHOW_TOAST_MSG_EVT = 'showtoastmsg'
export default class SibScheduleCard extends NavigationMixin(LightningElement) {
    static renderMode = 'light';

    labels = {
        lmsInactive,
        progressText,
        progressTextSuffix,
        goToCourseBtn,
        moreBtn,
        switchSessions,
        addSessions,
        edit,
        cancelBtn,
        cancelCourse,
        afterDeadLineText,
        afterDeadLinePolicyText,
        acknowledge,
        beforeDeadLineText,
        waitlistText,
        cancelCourseBtn,
        changedMindBtn,
        courseCancelledSuccessMsg,
        courseCancelledErrorMsg,
        courseCancelledAcknowledgeMsg,
        courseDetailsOrStatus
    };

    @api course;
    onlyonecourse = false;
    articleDefaultClass = 'courseTile slds-size_1-of-1 slds-small-size_1-of-2 slds-medium-size_1-of-3 slds-large-size_1-of-4 slds-m-around_small';
    afterDeadline = false;
    beforeDeadline = false;
    policy;
    deadlineDate;
    deadlineHour;
    deadlineMinutes;
    deadlineAmpm;
    waitlist = false;
    courseName;
    campaignMemberId;
    username;
    key;
    error;
    showAfterDeadline;
    showBeforeDeadline;
    isButtonDisabled = false;
    isShowModal = false;
    checked = false;
    showSessionEditModel = false;
    isSkeletonLoading = false


    renderedCallback(){
        const container = this.querySelector('.background-container');
        if (container) {
            // Dynamically set the background image
            container.style.backgroundImage = `url(${this.course?.cm?.Campaign?.Tile_Image_URL__c})`;
            container.style.backgroundSize = 'cover';
            container.style.backgroundPosition = 'center';
        }
    }

    get articleClass(){
        return this.course?.isActive ? this.articleDefaultClass : this.articleDefaultClass + 'inactive';
    }

    get courseImage(){
        return t;
    }


    get showProgressBar() {
        return this.course?.cm?.Completion_Enabled__c &&
               this.course?.cm?.Number_of_Activities__c &&
               this.course?.cm?.Number_of_Activities__c != 0 &&
               !this.course?.cm?.Campaign.Hide_Progress_Bar__c;
    }

    
    get progressPercentage() {
        return this.course?.cm?.Progress_Percentage__c / 100;
    }

    get showGoToCourseButton() {
        return this.course?.showGoTo &&
               this.course?.cm?.Attendee_Status__c === 'Registered' &&
               this.course?.cm?.Campaign?.Visible_on_LMS__c &&
               this.course?.cm?.Campaign?.Sync_to_LMS__c &&
               this.course?.cm?.Campaign?.LMS_ID__c;
    }

    get courseDetailUrl() {
        return basePath +  `/course-detail?CourseCode=${this.course?.cm?.Campaign?.Class_Code__c}&CourseId=${this.course?.cm?.CampaignId}`;
    }

    get canShowSessions() {
        return this.course?.cm?.Campaign?.Only_Show_Sessions__c && this.course?.cm?.Attendee_Status__c !== 'Cancelled';
    }

    get canShowCancel() {
        return this.course?.showCancel &&
            this.course?.cm?.OrderType__c === 'Individual' &&
            this.course?.cm?.Attendee_Status__c !== 'Cancelled' &&
            this.course?.cm?.Campaign.Cancellation_Deadline__c;
    }
    get SessionText() {
        return this.course?.cm?.Campaign?.Only_Show_Sessions__c ? this.labels.switchSessions : this.labels.addSessions;
    }

    get isCourseInActive(){
        return !this.course.isActive;
    }

    viewMoodle(event){
        let siteUrl = event.target.value;
        this.handleNavigation(siteUrl,true);
    }

    toggle() {
        this.querySelector('.courseTile').classList.add('flipped');
    }

    toggleBack(){
        this.querySelector('.courseTile').classList.remove('flipped');
    }

    addSessions(event){
        let siteUrl = basePath + '/register-course?id=' + event.target.dataset.value;
        this.handleNavigation(siteUrl,false);
    }

    handleShowEdit(event) {
        this.onlyonecourse = event.currentTarget.dataset.onlycourse;
        this.querySelector('c-sib-edit-course-modal').openModal();
    }

    handleShowModal(event){
        this.isShowModal = true;
        this.courseName = event.currentTarget.dataset.coursename;
        this.campaignMemberId = event.currentTarget.dataset.value; 
        this.loadCampaign();  
    }

    loadCampaign() {
        this.isSkeletonLoading = true
        getDeadlineInfo({ 
            username: this.username, 
            key: this.key, 
            campaignMemberId: this.campaignMemberId 
        })
        .then((response) => {
            if (response) {
                let deadlineDate = new Date(response?.Campaign?.Cancellation_Deadline__c);
                if (deadlineDate > new Date()) {
                    this.beforeDeadline = true;
                    this.waitlist = response?.Attendee_Status__c == 'Waiting List';
                    this.showBeforeDeadline = this.beforeDeadline && !this.waitlist;
                } else {
                    this.afterDeadline = true;
                    this.policy = response?.Campaign?.Cancellation_Policy__c;
                    this.deadlineDate = response?.Campaign?.Cancellation_Deadline_Date__c;
                    this.deadlineHour = response?.Campaign?.Cancellation_Deadline_Hours__c;
                    this.deadlineMinutes = response?.Campaign?.Cancellation_Deadline_Minutes__c;
                    this.deadlineAmpm = response?.Campaign?.Cancellation_Deadline_AM_PM__c;
                    this.waitlist = response?.Attendee_Status__c =='Waiting List';
                    this.showAfterDeadline = this.beforeDeadline && !this.waitlist;
                }
            }
            this.isSkeletonLoading = false;
        })
        .catch((error) => {
            this.error = error;
            console.log('Error:', error);
            this.isSkeletonLoading = false;
        });
    }

    handleAcknowledgeChange(event) {
        this.checked = event.target.checked;
    }

    handleConfirm(){
        this.isButtonDisabled = true;
        if(this.checked || this.beforeDeadline){
            cancelCourseProcess({ 
                campaignMemberId: this.campaignMemberId, 
                courseName: this.courseName 
            })
            .then((result) => {
                this.dispatchEvent(
                    new CustomEvent(SHOW_TOAST_MSG_EVT, {
                            detail: { msg : this.labels.courseCancelledSuccessMsg,
                                      type : 'success'
                            },
                            composed: true,
                            bubbles: true,
                    })
                );
                window.location.reload();
            })
            .catch(() => {
                this.dispatchEvent(
                    new CustomEvent(SHOW_TOAST_MSG_EVT, {
                            detail: {msg : this.labels.courseCancelledErrorMsg,
                                     type : 'error'
                            },
                            composed: true,
                            bubbles: true,
                    })
                );
            });
        } 
        else{
            this.error = this.labels.courseCancelledAcknowledgeMsg;
        }

    }

    handleCancel(){
        this.isShowModal = false;
    }
    
    handleNavigation(siteUrl, isOPenInNewTab){
        let target =  isOPenInNewTab ? '_blank' : '_self'
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
}