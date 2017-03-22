import UIKit
import ZeroKit

class LoginViewController: BaseViewController, ZeroLoadDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: ZeroKitPasswordField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.showProgress()
        
        if ZeroManager.shared.loaded {
            loginSilently()
        } else {
            ZeroManager.shared.delegate = self
        }
    }

    func zeroLoadingDone() {
        loginSilently()
    }
    
    func loginSilently() {
        if let username = ZeroDefaults.shared.getLoggedInUsername() {
            guard let userId = ZeroDefaults.shared.getUserIdByUsername(username: username) else {
                log.error("User not registered")
                self.hideProgress()
                return
            }
            
            if ZeroManager.shared.zeroKit?.canLoginByRememberMe(with: userId) == true {
                ZeroManager.shared.zeroKit?.loginByRememberMe(with: userId, completion: { (error) in
                    
                    self.hideProgress()
                    
                    guard error == nil else {
                        log.error("Sign in error, message: \(error?.localizedDescription)")
                        return
                    }
                    
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListView") as? ListViewController {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            } else {
                log.debug("User can't be logged in with remember me")
                self.hideProgress()
            }
        } else {
            self.hideProgress()
        }
    }

    @IBAction func loginTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let username = usernameField.text, !passwordField.isEmpty else {
            self.showAlert("Username and password must not be empty")
            return
        }
        
        showProgress()
        
        APIManager.shared.getUserIdByUsername(username: username, responseHandler: { (user) in
            guard let user = user else {
                self.showAlert("User not registered")
                self.hideProgress()
                return
            }
            
            let remember = self.rememberMeSwitch.isOn
            ZeroManager.shared.zeroKit?.login(withUserId: user.userId!, passwordField: self.passwordField, rememberMe: remember, completion: { (error) in
                self.hideProgress()
                
                guard error == nil else {
                    self.showAlert("Sign in error", message: "\(error!)")
                    return
                }
                if remember {
                    ZeroDefaults.shared.storeLogin(user: user)
                } else {
                    ZeroDefaults.shared.clearLogin()
                }
                
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListView") as? ListViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        })
    }
}

