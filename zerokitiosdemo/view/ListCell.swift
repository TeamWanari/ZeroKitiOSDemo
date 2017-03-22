import UIKit
import ObjectMapper

class ListCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setTodo(todo: Todo) {
        if todo.isDecrypted {
            titleLabel.text = todo.title
        } else {
            titleLabel.text = "Decrypting text ..."
            ZeroManager.shared.zeroKit?.decrypt(cipherText: todo.encryptedTodo!, completion: { (text, error) in
                if let text = text {
                    do {
                        let json = try JSONSerialization.jsonObject(with: text.data(using: .utf8, allowLossyConversion: false)!, options: JSONSerialization.ReadingOptions.mutableContainers)
                        let map = Map(mappingType: .fromJSON, JSON: json as! [String : Any])
                        if let copyTodo = Todo(map: map) {
                            todo.description = copyTodo.description
                            todo.id = copyTodo.id
                            todo.title = copyTodo.title
                            todo.isDecrypted = true
                            self.titleLabel.text = "\(todo.title!) - \(todo.description!)"
                        }
                    } catch let error {
                        self.titleLabel.text = "Failed to parse JSON"
                        log.error("JSON parsing failed: \(error)")
                    }
                } else {
                    self.titleLabel.text = "Decryption failed"
                }
            })
        }
    }
}
