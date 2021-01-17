import UIKit
import FirebaseFirestore
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var showErrorLabel: UILabel!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    private var firebase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setUpView() {
        createUserButton.layer.cornerRadius = 10
        nameTextField.delegate = self
        mailTextField.delegate = self
        passwordTextField.delegate = self
        createUserButton.isEnabled = false
        createUserButton.backgroundColor = .gray
        createUserButton.addTarget(self, action: #selector(tappedCreateUserButton), for: .touchUpInside)
        alreadyHaveAccountButton.addTarget(self, action: #selector(tappedAlreadyHaveAccountButton), for: .touchUpInside)
    }
    
    @objc private func tappedAlreadyHaveAccountButton() {
        let storyboard = UIStoryboard(name: "LoginView", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc private func tappedCreateUserButton() {
        guard let username = nameTextField.text else { return }
        guard let email = mailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if err != nil {
                print("認証情報の保存に失敗しました")
            } else {
                print("認証情報の保存に成功しました。")
                
                let docData = [
                    "email": email,
                    "username": username,
                ] as [String: Any]
                
                guard let uid = res?.user.uid else { return }
                Firestore.firestore().collection("user").document(uid).setData(docData) {
                    (err) in
                    if err != nil {
                        print("Firebaseへの保存に失敗しました。")
                        return
                    }
                    print("Firebaseへの保存に成功しました。")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// TextFieldに値が入力されたらButtonをTrueにする
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let nameIsEmpty = nameTextField.text?.isEmpty ?? false
        let mailIsEmpty = mailTextField.text?.isEmpty ?? false
        let passIsEmpty = passwordTextField.text?.isEmpty ?? false
        
        if nameIsEmpty || mailIsEmpty || passIsEmpty {
            createUserButton.isEnabled = false
            createUserButton.backgroundColor = .gray
            showErrorLabel.text = "入力されていない項目があります"
        } else {
            createUserButton.isEnabled = true
            createUserButton.backgroundColor = .rgb(red: 242, green: 213, blue: 224)
            showErrorLabel.text = ""
        }
    }
}
