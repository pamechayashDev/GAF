import { LightningElement, wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';



export default class UppNotifications extends NavigationMixin(LightningElement) {

    isModalOpen = false;
    activeTab= "home";
    isParent = true;

    callGetPreferedMessageTypesFromTable() {
    const uppNotificationsTable = this.template.querySelector('c-upp-notifications-table');
        if (uppNotificationsTable) {
            uppNotificationsTable.getPreferedMessageTypes();
        }
    }

    navigateToAllNotifications() {
         this.activeTab = "detail";
    }
    navigateToHome() {
        this.isParent = true;  
         this.activeTab = "home";
         this.callGetPreferedMessageTypesFromTable();
    }
    handleOnClick(){
        console.log('handle');
    }
    handlePreferencesButtonClick() {
        this.isModalOpen = true;
        
    }
closeModal(){
    this.isModalOpen = false;
}
    

   

   

}