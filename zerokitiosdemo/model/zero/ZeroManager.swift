import Foundation
import ZeroKit

protocol ZeroLoadDelegate {
    func zeroLoadingDone()
}

class ZeroManager {
    
    static let shared = ZeroManager()
    
    var zeroKit: ZeroKit?
    var delegate: ZeroLoadDelegate?
    var loaded = false
    
    func initKit() {
        if zeroKit != nil {
            return
        }
        let zeroKitApiUrl = URL(string: Bundle.main.infoDictionary!["ZeroKitAPIURL"] as! String)!
        let zeroKitConfig = ZeroKitConfig(apiUrl: zeroKitApiUrl)
        zeroKit = try! ZeroKit(config: zeroKitConfig)
        
        NotificationCenter.default.addObserver(self, selector: #selector(zeroKitDidLoad), name: ZeroKit.DidLoadNotification, object: zeroKit!)
        NotificationCenter.default.addObserver(self, selector: #selector(zeroKitDidFailLoading), name: ZeroKit.DidFailLoadingNotification, object: zeroKit!)
    }
    
    @objc fileprivate func zeroKitDidLoad(_ notification: Notification) {
        log.debug("ZeroKit loaded!")
        loaded = true
        delegate?.zeroLoadingDone()
    }
    
    @objc fileprivate func zeroKitDidFailLoading(_ notification: Notification) {
        // Handle error, retry...
        log.error("ZeroKit API load failed!")
        loaded = true
        delegate?.zeroLoadingDone()
    }
}
