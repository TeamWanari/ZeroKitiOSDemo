import Foundation
import ObjectMapper

class TodoList: Mappable, Listable {
    
    var id: String!
    var title: String!
    var tresorId: String!
    
    init(title: String) {
        self.title = title
    }
    
    required init?(map: Map) {
        id <- map["id"]
        title <- map["title"]
        tresorId <- map["tresorId"]
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        tresorId <- map["tresorId"]
    }
    
    func listingDescription() -> String {
        return title
    }
    
    func identifier() -> String {
        return id
    }
}
