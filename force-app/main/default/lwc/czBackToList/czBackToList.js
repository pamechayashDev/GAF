import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// Get the base path for navigating to non-named pages
import communityBasePath from '@salesforce/community/basePath';
import {
    NavigationMixin
} from 'lightning/navigation';

export default class BackToList extends NavigationMixin(LightningElement) {

    communityBasePath = communityBasePath;

     // Navigate to standard page used in Lightning communities
     navigateToTheList() {        
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: this.communityBasePath + '/manage-jobs'
            }
        });
    }

}