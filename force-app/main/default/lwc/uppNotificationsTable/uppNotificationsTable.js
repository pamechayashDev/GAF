import { LightningElement, track, api, wire } from 'lwc';
import getNotifications from '@salesforce/apex/UPPNotificationController.getUserNotifications';
import updateUppNotificationRecords from '@salesforce/apex/UPPNotificationController.updateUppNotificationRecords';
import getUppNotificationPreferences from '@salesforce/apex/UPPNotificationController.getUppNotificationPreferences';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord,updateRecords, getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import logo from "@salesforce/resourceUrl/logo";
import UPP_OBJECT from '@salesforce/schema/Upp_Notification__c';


export default class UppNotificationsTable extends LightningElement {
    @api from;
    isParent = false;
    dateFrom = null;
    isPreferencesModalOpen=false;
    dateTo = null;
    @track sortBy;
    @track sortDirection = 'asc';
    @track isBusinessAreaSortedAsc = false;
    @track isBusinessAreaSortedDesc = false;
    @track isMessageTypeSortedAsc = false;
    @track isMessageTypeSortedDesc = false;
    @track isSentSortedAsc = false;
    @track isSentSortedDesc = false;
    preferencesString = '';
    showArchived = false;
    @track notifications = [];
    displayValue = 'None';
    messageTypeValue = 'None';
    @track messageTypeOptions = [];
    displayOptions = [
        {
            label: 'Unread Only',
            value: 'Unread Only'
        },
        {
            label: 'Read',
            value: 'Read'
        },
        {
            label: 'None',
            value: 'None'
        }

    ]

    isModalOpen = false;
    logoImageUrl = logo;
    @track selectedNotification = null;


checkedIds = [];

    handleCheckboxChange(event){
   let value=  event.target.checked;
   let recId = event.target.dataset.id;
   if(value){
    this.checkedIds.push(recId);
   }
   else{
    this.checkedIds = this.checkedIds.filter(item => item !== recId);
   }

   console.log(JSON.stringify(this.checkedIds));
    }
    archiveSelectedRecords(event){
        let clickedFrom = event.target.dataset.from;
          
        let recordsToUpdate;
        if(clickedFrom=='Multiple'){
             recordsToUpdate = this.checkedIds.map(recordId => 

                ( {
                    'Id' : recordId,
                    'RecordTypeId' : this.recordTypes[2].id
                })
            
            );
        }
        else if(clickedFrom=='Modal'){
            
            recordsToUpdate  =  [ {
                'Id' :   this.selectedNotification.Id,
                'RecordTypeId' : this.recordTypes[2].id
            }]; 
         
        }
        else{
            recordsToUpdate  =  [ {
                'Id' :   event.target.dataset.id,
                'RecordTypeId' : this.recordTypes[2].id
            }];   
        }
    
 
        updateUppNotificationRecords({records:recordsToUpdate}).then(res=>{
        this.applyFilters();
        this.closeModal();
        this.showToast('Success','Archived Recoreds','Success');
      }).catch(error => {
            this.showToast('Error','Error Occured','Error');
        });
    }

    handleSort(event) {
        
        const field = event.currentTarget.dataset.field;
        this.sortBy = field;
    console.log( this.sortBy)
        // Toggle Sort Direction
        this.sortDirection = this.sortDirection == 'asc' ? 'desc' : 'asc';

        // Reset Sorting Icons
        this.isBusinessAreaSortedAsc = false;
        this.isBusinessAreaSortedDesc = false;
        this.isMessageTypeSortedAsc = false;
        this.isMessageTypeSortedDesc = false;
        this.isSentSortedAsc = false;
        this.isSentSortedDesc = false;
        

        // Set Sorting Icon for Current Column
        if (field === 'Business_Area__c') {
            this.isBusinessAreaSortedAsc = this.sortDirection === 'asc';
            this.isBusinessAreaSortedDesc = this.sortDirection === 'desc';
        } else if (field === 'Message_Type__c') {
            this.isMessageTypeSortedAsc = this.sortDirection === 'asc';
            this.isMessageTypeSortedDesc = this.sortDirection === 'desc';
        } else if (field === 'Sent__c') {
            this.isSentSortedAsc = this.sortDirection === 'asc';
            this.isSentSortedDesc = this.sortDirection === 'desc';
        }
 
        // Perform Sorting
        this.notifications = [...this.notifications].sort((a, b) => {
            let valueA = a[field];
            let valueB = b[field];

            // Convert Date String to Comparable Value
            if (field === 'Sent__c') {
                valueA = new Date(a[field]);
                valueB = new Date(b[field]);
            }

            let comparison = 0;
            if (valueA > valueB) {
                comparison = 1;
            } else if (valueA < valueB) {
                comparison = -1;
            }

           return this.sortDirection === 'asc' ? comparison : -comparison;


        }
    );
    console.log('no-',JSON.stringify(this.notifications));
    }














    recordTypes = [];
    master;
    @wire(getObjectInfo, { objectApiName: UPP_OBJECT })
    wiredObjectInfo({ data, error }) {
        if (data) {
            this.recordTypes = Object.keys(data.recordTypeInfos).map(recordTypeId => ({
                id: recordTypeId,

                name: data.recordTypeInfos[recordTypeId].name
            }));
            this.master = this.recordTypes[0].id;

            console.log('this.recordTypes' + JSON.stringify(this.recordTypes));
        } else if (error) {
            console.error('Error fetching record types', error);
        }
    }
    getPreferedMessageTypes() {
        getUppNotificationPreferences().then((preferencesResult) => {
         let responseString  = preferencesResult.preferences;
          
            this.preferencesString = responseString;

            if (responseString != null) {
                this.messageTypeOptions = responseString.split(';').map(preferenceValue => {
                    return {
                        label: preferenceValue,
                        value: preferenceValue
                    }
                });
            }

           
            this.messageTypeOptions.push({label:'None',value:'None'});
            this.getNotificationData();
           
        })

    }

    formatDate(dateToFormat) {
        let date = new Date(dateToFormat);
        let options = {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: 'numeric',
            minute: 'numeric',
            second: 'numeric',
            hour12: true
        };
        return new Intl.DateTimeFormat('en-US', options).format(date);
    }
    getNotificationData() {
        console.log('preferencesString==' + this.preferencesString);
        getNotifications(
            {
                dateFrom: this.dateFrom,
                dateTo: this.dateTo,
                showArchived: this.showArchived,
                calledFrom: this.from,
                messageStatus: this.displayValue,
                messageType: this.messageTypeValue,
                preferencesString: this.preferencesString

            }
        ).then(data => {
            if (data) {

                 this.notifications = this.from == 'parent' ? data.slice(0, 3) : data;
                
                // this.notifications = this.notifications.map(notification => ({
                //     ...notification,
                // }));
     
                console.log('dttt--'+JSON.stringify(data));
            }
        }).catch(error => {
            console.error('Error retrieving notifications-1', error);
        })
    }

    async connectedCallback() {
        this.isParent = this.from == 'parent' ? true : false;
        this.getPreferedMessageTypes();



    }



    handleChange(event) {
        const { name, value, checked } = event.target;
        if (name === 'showArchived') {
            this.showArchived = checked;

        } else if (name === 'dateFrom') {
            const today = new Date().toISOString().split('T')[0];
            value > today ? this.showToast('Error', 'From Date cannot be in the future', 'error') : this.dateFrom = value;

        } else {
            this[name] = value;
        }
    }

    //applying filters
    applyFilters() {
        console.log('prefer='+this.preferencesString);

        getNotifications({
            dateFrom: this.dateFrom,
            dateTo: this.dateTo,
            showArchived: this.showArchived,
            calledFrom: 'child',
            messageStatus: this.displayValue,
            messageType: this.messageTypeValue,
            preferencesString: this.preferencesString

        }).then(data => {
            if (data) {
   
                 this.notifications = this.from == 'parent' ? data.slice(0, 3) : data;
           
   
                this.isParent = this.from == 'parent' ? true : false;
   
                 console.log('data--'+JSON.stringify(data));
            }
        }).catch(error => {
            console.error('Error retrieving notifications', JSON.stringify(error));
        })
    }

    //clear all filters
    clearFilters() {
        this.dateFrom = null;
        this.dateTo = null;
        this.displayValue = 'None';
        this.messageTypeValue = 'None';
        this.showArchived = false;
        this.getNotificationData();
    }

    handleSubjectAction(event) {
        const notificationId = event.target.dataset.id;
        if (!notificationId) {
            console.error("Notification ID is missing");
            return;
        }

        this.selectedNotification = this.notifications.find(notif => notif.Id === notificationId) || null;
        if (this.selectedNotification) {

            this.selectedNotification.Sent__c = this.formatDate(this.selectedNotification.Sent__c);

            //mark notification read 
            if (!this.selectedNotification.Is_Read__c) {
                const fields = {
                    Id: this.selectedNotification.Id,
                    Is_Read__c: true
                };
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    this.applyFilters();
                })
                    .catch(error => {
                        console.error('Error updating notification:', JSON.stringify(error));
                    });

            }

            this.isModalOpen = true;

        }
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedNotification = null;
    }
    handlePreferencesButtonClick() {
        this.isPreferencesModalOpen = true;
    }
closePreferencesModal(){
    this.isPreferencesModalOpen = false;
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