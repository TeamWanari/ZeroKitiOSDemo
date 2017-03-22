import Foundation
import ObjectMapper

class User: Mappable {
    
    var userId: String?
    var username: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        userId <- map["UserId"]
        username <- map["UserName"]
    }
}
