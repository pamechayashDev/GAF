import { LightningElement,wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PREFERENCES_OBJECT from '@salesforce/schema/UPP_Notifications_Preferences__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUppNotificationPreferences from '@salesforce/apex/UPPNotificationController.getUppNotificationPreferences';
import PREFERENCES_FIELD from '@salesforce/schema/UPP_Notifications_Preferences__c.Preferences__c';
import saveOrUpdatePreferences from '@salesforce/apex/UPPNotificationController.saveOrUpdatePreferences';


export default class PreferencesModal extends LightningElement {

   
    value = [];
    master;
    options = [];
    selectedValues;
    recordTypes=[];
     deliverMessageByEmail = false;
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
            console.log('options');
            this.options = data.values.map(picklistItem => {
                return {
                    label: picklistItem.value,
                    value: picklistItem.value
                };
            })
            console.log('options');
        } else if (error) {
            console.error('Error fetching picklist values', error);
        }
    }

    
    handleDeliverCheckboxChange(event){
        const { checked } = event.target;
        this.deliverMessageByEmail = checked;
        
    }
    connectedCallback(){

        getUppNotificationPreferences()
        .then(preferencesResult=>{
            console.log('data'+JSON.stringify(preferencesResult));
            if(preferencesResult.preferences){
         this.value = preferencesResult.preferences.split(';');
         
            }
 
               console.log('data--'+JSON.stringify(this.value));
                this.deliverMessageByEmail = preferencesResult.deliverMessageByEmail;
          })
    }

    handleChange(e) {
        this.value = e.detail.value;
        this.selectedValues = this.value.join(';');

    }
    handleClose(){
        console.log('close');
        this.dispatchEvent(new CustomEvent('close'));
    }
    handleSave() {
        saveOrUpdatePreferences({ preferences: this.selectedValues,deliverMessageByEmail : this.deliverMessageByEmail }).then(() => {
            this.showToast('Success', 'UPP Notification Preferences Saved', 'Success');
            this.isModalOpen = false;
           location.reload();
        }).catch((error) => {
            console.log('Error :' + error);
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