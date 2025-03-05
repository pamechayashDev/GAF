import { LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class UppNotifications extends NavigationMixin(LightningElement) {
  
  isParent = true;
    navigateToAllNotifications(){
        console.log('called');
        this.isParent = false;
        
    }
    navigateToHome(){
        this.isParent = true; 
    }

    // navigateToAllNotifications() {
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__navItemPage',
    //         attributes: {
    //             apiName: 'All_Upp_Notifications' 
    //         },
    //         state: {
    //             fromViewAll: 'true'
    //         }
    //     });
    // }
 


}