import { LightningElement, wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';



export default class UppNotifications extends NavigationMixin(LightningElement) {
    isModalOpen = false;
    activeTab= "home";
    
    isParent = true;
    isDetail = false;



    connectedCallback(){
        console.log('connected callback');
       
    }

    navigateToAllNotifications() {
         this.isDetail = true;
         this.isParent=false;
         this.activeTab ="detail";
         console.log(this.activeTab);
    }
    navigateToHome() {
        this.isParent = true;
        
        this.activeTab = "home";
        console.log(this.activeTab);
    }
    handlePreferencesButtonClick() {
        this.isModalOpen = true;
        
    }
closeModal(){
    this.isModalOpen = false;
}
    

   

   

}