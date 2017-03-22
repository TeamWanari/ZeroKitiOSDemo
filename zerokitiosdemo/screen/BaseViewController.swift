import UIKit
import ZeroKit

class BaseViewController: UIViewController {
    
    var progressView: UIView?
    
    func showAlert(_ title: String?, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { (action) in
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func showProgress() {
        if progressView != nil {
            return
        }
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.65)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        activity.startAnimating()
        view.addSubview(activity)
        
        self.view.window?.addSubview(view)
        self.progressView = view
    }
    
    func hideProgress() {
        progressView?.removeFromSuperview()
        progressView = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func handleInvitation(invitationInfo: InvitationLinkPublicInfo) {
        let alert = UIAlertController(title: "Invitation", message: "Password?", preferredStyle: .alert)
        if invitationInfo.isPasswordProtected {
            alert.addTextField(configurationHandler: { (field) in
                field.placeholder = "Password"
                field.isSecureTextEntry = true
                field.autocorrectionType = .no
                field.spellCheckingType = .no
            })
        }
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action) in
            if invitationInfo.isPasswordProtected {
                if let password = alert.textFields?[0].text {
                    self.respondToInvitation(invitation: invitationInfo, withPassword: password)
                }
            } else {
                self.respondToInvitation(invitation: invitationInfo)
            }
        }))
        alert.addAction(UIAlertAction(title: "Ignore", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func respondToInvitation(invitation: InvitationLinkPublicInfo, withPassword password: String? = nil) {
        if let password = password {
            ZeroManager.shared.zeroKit?.acceptInvitationLink(with: invitation.token, password: password, completion: { (operationId, error) in
                guard error == nil else {
                    log.error("Invitation couldn't be accepted: \(error?.localizedDescription)")
                    self.showAlert("Error", message: "\(error?.localizedDescription)")
                    return
                }
                APIManager.shared.approveInvitationAcception(operationId: operationId!, responseHandler: { (success) in
                    if success {
                        self.showAlert("Success", message: "Invitation accepted")
                        self.navigateToTodoLists()
                    } else {
                        self.showAlert("Error", message: "Couldn't approve invitation")
                    }
                })
            })
        }
    }
    
    func navigateToTodoLists() {
        log.debug("Going to todo list")
    }
}
