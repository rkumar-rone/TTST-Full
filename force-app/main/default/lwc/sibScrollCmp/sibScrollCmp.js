import { LightningElement } from 'lwc';

export default class SibScrollCmp extends LightningElement {
    connectedCallback(){
        console.log('scroll called' + window.screenY);
    }

    renderedCallback(){
        // console.log('render called');
        // const containerChoosen = this.template.querySelector('.locationlevelbottomClass');
        // let containerPosition = containerChoosen.getBoundingClientRect().top + window.scrollY;
        // window.scrollTo({
        //     top: containerPosition - 205,  
        //     behavior: 'smooth'
        // });
        setTimeout(() => {
            document.documentElement.scrollTop = 0; // For most browsers
            document.body.scrollTop = 0; // For older browsers
        }, 400);
    }
}