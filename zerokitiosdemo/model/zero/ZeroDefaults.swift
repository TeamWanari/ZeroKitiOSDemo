import Foundation

class ZeroDefaults {
    
    static let shared = ZeroDefaults()
    
    let keyForLoggedInUser = "loggedInUsername"
    let keyForUserDict = "userDictionary"
    
    func storeLogin(user: User) {
        guard let name = user.username else {
            log.error("Can't save logged in user, user has no username???")
            return
        }
        UserDefaults.standard.set(name, forKey: keyForLoggedInUser)
        setUserId(id: user.userId!, forUsername: name)
    }
    
    func getLoggedInUsername() -> String? {
        return UserDefaults.standard.value(forKey: keyForLoggedInUser) as? String
    }
    
    func clearLogin() {
        if UserDefaults.standard.value(forKey: keyForLoggedInUser) != nil {
            UserDefaults.standard.set(nil, forKey: keyForLoggedInUser)
            UserDefaults.standard.synchronize()
        }
    }
    
    func getUserIdByUsername(username: String) -> String? {
        if let dict: [String: String] = UserDefaults.standard.value(forKey: keyForUserDict) as? [String: String] {
            return dict[username]
        }
        return nil
    }
    
    func setUserId(id: String, forUsername username: String) {
        if var dict: [String: String] = UserDefaults.standard.value(forKey: keyForUserDict) as? [String: String] {
            dict[username] = id
            UserDefaults.standard.set(dict, forKey: keyForUserDict)
        } else {
            let dict : [String: String] = [username:id]
            UserDefaults.standard.set(dict, forKey: keyForUserDict)
        }
        UserDefaults.standard.synchronize()
    }
}
