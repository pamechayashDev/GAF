import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUppNotificationPreferences from '@salesforce/apex/UPPNotificationController.getUppNotificationPreferences';
import saveOrUpdatePreferences from '@salesforce/apex/UPPNotificationController.saveOrUpdatePreferences';
import getUserPermissions from '@salesforce/apex/UPPNotificationController.getUserPermissions';



export default class PreferencesModal extends LightningElement {


    value = [];
    master;
    options = [];
    selectedValues;
    recordTypes = [];
    numberOfRecords = 10;
    deliverMessageByEmail = false;
 

    handleRecordsPerPageChange(event) {
        this.numberOfRecords = event.detail.value;
    }
    handleDeliverCheckboxChange(event) {
        const { checked } = event.target;
        this.deliverMessageByEmail = checked;

    }
    userProgramList = [];
   programPreferencesMapping = {};

    async connectedCallback() {
  
     let  permissionList =  await  getUserPermissions();
           
     this.options = permissionList.map(preference => {
                return {
                    label: preference,
                    value: preference
                };
            })
  


        getUppNotificationPreferences()
            .then(preferencesResult => {
                if (preferencesResult.length != 0) {
                    if (preferencesResult[0].Preferences__c) {
                        this.selectedValues = preferencesResult[0].Preferences__c;
                        this.value = preferencesResult[0].Preferences__c.split(';');
                    }
                    this.deliverMessageByEmail = preferencesResult[0].Deliver_message_by_email__c;
                    this.numberOfRecords = preferencesResult[0].Records_per_page__c;
                }
            })

            console.log('preference Modal called');
    }

    handleChange(e) {
        this.value = e.detail.value;
        this.selectedValues = this.value.join(';');

    }
    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
    handleSave() {

        let args = {
            messageTypes: this.selectedValues,
            deliverByEmail: this.deliverMessageByEmail,
            recordsPerPage: this.numberOfRecords
        }

        saveOrUpdatePreferences({ preferences: args }).then(() => {
            this.showToast('Success', 'UPP Notification Preferences Saved', 'Success');
            this.isModalOpen = false;
            this.dispatchEvent(new CustomEvent('save'));
            this.handleClose();
        }).catch((error) => {
            this.showToast('Failed', 'Error in saving UPP Notification Preferences', 'Failed');
        })
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