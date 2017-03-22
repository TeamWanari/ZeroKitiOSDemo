import Foundation
import ObjectMapper

class RegResponse: Mappable {
    
    var regSessionId: String?
    var userId: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        regSessionId <- map["RegSessionId"]
        userId <- map["UserId"]
    }
}
