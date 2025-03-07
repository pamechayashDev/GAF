import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveOrUpdatePreferences from '@salesforce/apex/UPPNotificationController.saveOrUpdatePreferences';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PREFERENCES_OBJECT from '@salesforce/schema/UPP_Notifications_Preferences__c';
import PREFERENCES_FIELD from '@salesforce/schema/UPP_Notifications_Preferences__c.Preferences__c'

export default class UppNotifications extends NavigationMixin(LightningElement) {
    value = ['option1'];
    isModalOpen = false;
    master;
    options = [];
    isParent = true;
    selectedValues;
    navigateToAllNotifications() {
        console.log('called');
        this.isParent = false;

    }
    navigateToHome() {
        this.isParent = true;
    }
    handlePreferencesButtonClick() {
        this.isModalOpen = true;
    }

    @wire(getObjectInfo, { objectApiName: PREFERENCES_OBJECT })
    wiredObjectInfo({ data, error }) {
        if (data) {
            this.recordTypes = Object.keys(data.recordTypeInfos).map(recordTypeId => ({
                id: recordTypeId,
            }));
            this.master = this.recordTypes[0].id;
        } else if (error) {
            console.error('Error fetching record types', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$master", fieldApiName: PREFERENCES_FIELD })
    wiredObjectInfo1({ data, error }) {
        if (data) {

            this.options = data.values.map(picklistItem => {
                return {
                    label: picklistItem.value,
                    value: picklistItem.value
                };
            })
        } else if (error) {
            console.error('Error fetching picklist values', error);
        }
    }

    handleChange(e) {
        this.value = e.detail.value;
        this.selectedValues = this.value.join(';');

    }

    handleSave() {
        saveOrUpdatePreferences({ preferences: this.selectedValues }).then(() => {
            this.showToast('Success', 'UPP Notification Preferences Saved', 'Success');
            this.isModalOpen = false;
           location.reload();
        }).catch((error) => {
            console.log('Error :' + error);
            this.showToast('Failed', 'Error in saving UPP Notification Preferences', 'Failed');
        })
    }


    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}