import UIKit
import FirebaseFirestore
import FirebaseAuth

class CreateViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var showErrorLabel: UILabel!
    private var firebase = Firestore.firestore()
    
    private var titleText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    private func setUpView() {
        createButton.layer.cornerRadius = 10
        titleTextField.delegate = self
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(tappedCreateButton), for: .touchUpInside)
        createButton.backgroundColor = .gray
    }
    
    // Buttonを押した時の処理
    @objc private func tappedCreateButton() {
        titleText = titleTextField.text
        guard let userId = Auth.auth().currentUser?.uid else { return }
        firebase.collection("user").document("\(userId)").collection("project").addDocument(data: ["project_Name" : titleText!])

        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension CreateViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let titleIsEmpty = titleTextField.text?.isEmpty ?? false
        
        if titleIsEmpty {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
            showErrorLabel.text = "入力されていません"
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .rgb(red: 242, green: 213, blue: 224)
            showErrorLabel.text = ""
        }
    }
}
