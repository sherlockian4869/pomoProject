import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showErrorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    private func setUpView() {
        loginButton.layer.cornerRadius = 10
        emailTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.backgroundColor = .gray
        loginButton.isEnabled = false
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
    }
    
    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
                
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if err != nil {
                print("ログインに失敗しました")
                return
            }
            
            print("ログインに成功しました")
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .gray
            showErrorLabel.text = "入力されていない項目があります"
        } else {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .rgb(red: 154, green: 224, blue: 97)
            showErrorLabel.text = ""
        }
    }
}
