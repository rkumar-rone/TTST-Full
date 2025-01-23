import { LightningElement, api } from 'lwc';
import loadSchedule from '@salesforce/apex/CourseManagementController.loadSchedule';
import noCourseText from '@salesforce/label/c.SIB_NoCourseText';
import allOnlineContentBtn from '@salesforce/label/c.SIB_AllOnlineContentBtn';
import allCourseLabel from '@salesforce/label/c.SIB_All_Course_Option';
import selfStudyLabel from '@salesforce/label/c.SIB_Self_Study_Option';
import trainingProgramLabel from '@salesforce/label/c.SIB_Training_Programs_Option';
import activeInactiveLabel from '@salesforce/label/c.SIB_Active_and_Inactive_Option';
import activeLabel from '@salesforce/label/c.SIB_Active_Option';
import inactiveLabel from '@salesforce/label/c.SIB_Inactive_Option';
import lmsSuffixUrl from '@salesforce/label/c.SIB_LmsSuffixUrl';
import { NavigationMixin } from 'lightning/navigation';
import isGuestUser from "@salesforce/user/isGuest";
export default class SibSchedule extends NavigationMixin(LightningElement) {
     static renderMode = 'light';
    labels = {
        noCourseText,
        allOnlineContentBtn,
        lmsSuffixUrl,
        allCourseLabel,
        selfStudyLabel,
        trainingProgramLabel,
        activeInactiveLabel,
        activeLabel,
        inactiveLabel
    };

    courseCards = Array.from({ length: 6 });
    isSkeletonLoading = false
    courses = [];  
    hasonline = false; 
    moodleURL = '';  
    selectedtype = this.labels.activeInactiveLabel;  
    selectedstudytype = this.labels.allCourseLabel;  
    username = '';
    key = '';
    loggedIn = '';
    onlyonecourse = false;
    noCourses = false;

    studyTypeOptions = [
        { label: this.labels.allCourseLabel, value: 'All Course Types' },
        { label: this.labels.selfStudyLabel, value: 'Self-Study' },
        { label: this.labels.trainingProgramLabel, value: 'Training Programs' }
    ];

    courseTypeOptions = [
        { label: this.labels.activeInactiveLabel, value: 'Active and Inactive' },
        { label: this.labels.activeLabel, value: 'Active Only' },
        { label: this.labels.inactiveLabel, value: 'Inactive Only' }
    ];

    connectedCallback() {
        if(isGuestUser){
            this.returnToLogin();
        }
        else{
            this.loadCourses();
        }
    }

    returnToLogin() {
        let url = '/' + window.location.href.split('/s/');
        let destURL = "/?origURL=" + encodeURIComponent(url);

        if (url.startsWith('/view-event')) {
            destURL = url.replace('view-event', 'viewevent');
        }
        if (!url.startsWith('/public-courses')) {
            this.handleNavigation(destURL)
        }

    }

    loadCourses() {
        this.isSkeletonLoading = true;
        loadSchedule({
            username: this.username,
            key: this.key,
            courseType: this.selectedtype,
            courseStudyType: this.selectedstudytype
        })
        .then((response) => {
            if (response) {
                if (response.success) {
                    this.courses = response?.scheds;
                    this.hasonline = response?.hasonline;
                    this.moodleURL = response?.moodleURL;
                    this.noCourses = this.courses?.length > 0 ? false : true;
                } else {
                    this.noCourses = true;
                }
            }
            else {
                this.noCourses = true;
            }
            this.isSkeletonLoading = false
        })
        .catch((error) => {
            this.noCourses = true;
            if (error && error?.body && error?.body?.message) {
                console.log(error?.body?.message);
            }          
            this.isSkeletonLoading = false;
        });
    }

    get moodleLink() {
        return his.moodleURL + this.labels.lmsSuffixUrl;
    }

    handleNavigation(siteUrl){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: siteUrl
            }
        })
        .then((siteUrl) => {
            window.open(siteUrl,'_self');
        });
    }

    handleCourseTypeAndStudyType(event) {
        const { name, value } = event.target;
        if (name === 'type') {
            this.selectedstudytype = value;
        } else if (name === 'coursetype') {
            this.selectedtype = value;
        }
        this.loadCourses();
    }

    handleToastMsg(evt){
        this.querySelector('c-sib-show-toast-message').showToast(evt.detail.msg,evt.detail.type,5000);
    }
}