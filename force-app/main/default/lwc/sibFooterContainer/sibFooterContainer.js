import { LightningElement, wire,track } from 'lwc';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorTemplateSettings';
import getFooterConfiguration from '@salesforce/apex/SIB_FooterController.getFooterConfiguration';

export default class SibFooterContainer extends LightningElement {

    questStore;

    @track footerConfiguration;

    @wire(getConfig,  { })
    getConfigWired({ error, data }) {
        if (data) {
            this.questStore = data == 'templateTwo' ? true : false;
        } else if (error) {
            console.error(error);
        }
    };

    @wire(getFooterConfiguration,  {mapParams : {} })
    wiredFooterConfig({ error, data }) {
        if (data) {
            // Create a deep copy of the footerConfiguration to avoid direct modification
            this.footerConfiguration = JSON.parse(JSON.stringify(data.footerConfig));
    
            // Sort and assign topSection subsections
            if (this.footerConfiguration.topSection?.subsections) {
                this.footerConfiguration.topSection.subsections = this.sortByOrder(this.footerConfiguration.topSection.subsections);
                
                this.footerConfiguration.topSection.subsections = this.footerConfiguration.topSection.subsections.map(subsection => {
                    if (subsection.records) {
                        return {
                            ...subsection,
                            records: this.sortByOrder(subsection.records)
                        };
                    }
                    return subsection;
                });
            }
    
            // Sort and assign middleSection records
            if (this.footerConfiguration.middleSection?.records) {
                this.footerConfiguration.middleSection.records = this.sortByOrder(this.footerConfiguration.middleSection.records);
            }
    
            // Sort and assign bottomSection records
            if (this.footerConfiguration.bottomSection?.records) {
                this.footerConfiguration.bottomSection.records = this.sortByOrder(this.footerConfiguration.bottomSection.records);
            }

            this.prepareSocialMediaLinks(); 

        } else if (error) {
            console.error(error);
        }
    };

    sortByOrder(array) {
        // Ensure we're working with a copy of the array to avoid modifying the original
        return [...array].sort((a, b) => a.sortOrder - b.sortOrder);
    }

    prepareSocialMediaLinks() {

        // Helper function to set target for a section
        const setTargetForSection = (section) => {
            if (section?.records) {
                const target = section.openInNewWindow ? '_blank' : '_self';
                section.records = section.records.map(record => {
                    // Ensure that the object is correctly updated with the target property
                    const updatedRecord = { ...record, target: target };
                    return updatedRecord;
                });
            }
        };

        // Configure social media links for topSection
        if (this.footerConfiguration?.topSection?.subsections) {
            let target = this.footerConfiguration.topSection.openInNewWindow ? '_blank' : '_self';
            this.footerConfiguration.topSection.subsections = this.footerConfiguration.topSection.subsections.map(subsection => {
                subsection.records = subsection.records.map(link => {
                    return {
                        ...link,
                        isFacebook: link.Label.toLowerCase() === 'facebook',
                        isTwitter: link.Label.toLowerCase() === 'twitter',
                        isLinkedIn: link.Label.toLowerCase() === 'linkedin',
                        isYoutube: link.Label.toLowerCase() === 'youtube',
                        isInstagram: link.Label.toLowerCase() === 'instagram',
                        target: target
                    };
                });
                return subsection;
            });
        }

        // Set target for middleSection
        setTargetForSection(this.footerConfiguration.middleSection);

        // Set target for bottomSection
        setTargetForSection(this.footerConfiguration.bottomSection);

    }
}