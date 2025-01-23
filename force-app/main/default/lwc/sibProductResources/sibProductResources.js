import { LightningElement,api } from 'lwc';

export default class SibProductResources extends LightningElement {
    @api resources;

    images = {
        doc : 'https://lightningdemo1--demolwr3.sandbox.file.force.com/servlet/servlet.ImageServer?id=015DM000001lkH1&oid=00DDM000003rXE7&lastMod=1710323925000'
    };
}