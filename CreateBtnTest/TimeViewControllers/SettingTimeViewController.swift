import UIKit
import FirebaseFirestore
import FirebaseAuth

class SettingTimeViewController: UIViewController {
    
    @IBOutlet weak var workTimeTextField: UITextField!
    @IBOutlet weak var restTimeTextField: UITextField!
    @IBOutlet weak var repeatTimeTextField: UITextField!
    @IBOutlet weak var showErrorLabel: UILabel!
    @IBOutlet weak var createTimeButton: UIButton!
    
    private var firebase = Firestore.firestore()
    
    var time = [Int]()
    var projectTitleName: String!
    var documentId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    private func setUpView(){
        createTimeButton.layer.cornerRadius = 10
        navigationItem.leftBarButtonItem = .none
        
        workTimeTextField.delegate = self
        restTimeTextField.delegate = self
        repeatTimeTextField.delegate = self
        
        createTimeButton.addTarget(self, action: #selector(tappedCreateTimeButton), for: .touchUpInside)
        createTimeButton.isEnabled = false
        createTimeButton.backgroundColor = .gray

        projectTitleName = UserDefaults.standard.string(forKey: "projectTitle")
        documentId = UserDefaults.standard.string(forKey: "projectId")
    }
    
    @objc private func tappedCreateTimeButton() {
        variableConversion()
        transitionView()
    }
    
    private func variableConversion() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let workString = workTimeTextField.text
        let restString = restTimeTextField.text
        let repeatString = repeatTimeTextField.text
        
        let doc = [
            "work" : workString as Any,
            "rest" : restString as Any,
            "repeat" : repeatString as Any,
            "TimeAchievementCount" : 0.0,
            "TimeNotAchievementCount" : 0.0
        ]
        firebase.collection("user").document(userId).collection("project").document(documentId).collection("timer").addDocument(data: doc as [String : Any])
        
    }
    
    private func transitionView() {
        navigationController?.popViewController(animated: true)
        UserDefaults.standard.removeObject(forKey: "projectTitle")
        UserDefaults.standard.removeObject(forKey: "projectId")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SettingTimeViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let workIsEmpty = workTimeTextField.text?.isEmpty ?? false
        let restIsEmpty = restTimeTextField.text?.isEmpty ?? false
        let repeatIsEmpty = repeatTimeTextField.text?.isEmpty ?? false
        
        if workIsEmpty || restIsEmpty || repeatIsEmpty {
            createTimeButton.isEnabled = false
            showErrorLabel.text = "入力されていない項目があります"
            createTimeButton.backgroundColor = .gray
        } else {
            createTimeButton.isEnabled = true
            createTimeButton.backgroundColor = .rgb(red: 242, green: 213, blue: 224)
            showErrorLabel.text = ""
        }
    }
}
