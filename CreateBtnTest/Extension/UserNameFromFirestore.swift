import UIKit
import FirebaseFirestore

class UserNameFromFirestore() do {
    let firebase = Firestore.firestore()
    
    firebase.collection("user").getDocuments { (snapshot, err) in
        if err != nil {
            
        }
    }
}
