import Foundation
import ObjectMapper

class Todo: Mappable, Listable {
    
    var id: String!
    var title: String?
    var description: String?
    
    var encryptedTodo: String?
    var isDecrypted: Bool = false
    
    init(id: String, encryptedTodo: String) {
        self.id = id
        self.encryptedTodo = encryptedTodo
    }
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    required init?(map: Map) {
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
    }
    
    func listingDescription() -> String {
       return title ?? id
    }
    
    func identifier() -> String {
        return id
    }
}
