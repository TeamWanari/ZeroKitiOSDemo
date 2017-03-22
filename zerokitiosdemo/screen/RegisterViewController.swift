import UIKit
import ZeroKit

class RegisterViewController: BaseViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: ZeroKitPasswordField!
    @IBOutlet weak var confirmPasswordField: ZeroKitPasswordField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.matchingField = confirmPasswordField
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let username = usernameField.text, !passwordField.isEmpty && !confirmPasswordField.isEmpty else {
            self.showAlert("Username and password must not be empty")
            return
        }
        
        guard passwordField.passwordsMatch else {
            self.showAlert("Passwords do not match")
            return
        }
        
        self.showProgress()
        APIManager.shared.initUserRegistration(responseHandler: { (response) in
            guard let response = response else {
                self.hideProgress()
                self.showAlert("API Error", message: "Unable to init registration")
                return
            }
            log.debug("Got reg init response: \(response)")
            ZeroManager.shared.zeroKit?.register(withUserId: response.userId!, registrationId: response.regSessionId!, passwordField: self.passwordField) { verifier, error in
                guard error == nil else {
                    self.hideProgress()
                    self.showAlert("Sign up error", message: "\(error!)")
                    return
                }
                
                APIManager.shared.validateUser(userId: response.userId!, username: username, regSessionId: response.regSessionId!, regVerifier: verifier!, responseHandler: { (success) in
                    
                    self.hideProgress()
                    if success {
                        // TODO: Save logged in user with userId and username
                        self.showAlert("Successfully registered user \(username). You can now sign in.")
                    } else {
                        self.showAlert("Error validating user after registration")
                    }
                })
            }
        })
    }
}
