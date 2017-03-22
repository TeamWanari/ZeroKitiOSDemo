import Foundation
import Firebase

class DatabaseManager {
    
    typealias DataCallback = (FIRDataSnapshot) -> Void
    typealias SuccessCallback = (Bool) -> Void
    
    let TABLES = "tableslist"
    let TODOS = "todos"
    
    static let shared = DatabaseManager()
    
    private var db: FIRDatabaseReference!
    
    private var currentTables: [TodoList]?
    
    func initDatabase() {
        FIRApp.configure()
        db = FIRDatabase.database().reference()
    }
    
    func getTodoLists(dataHandler: @escaping DataCallback) {
        db.child(TABLES).observe(.value, with: dataHandler)
    }
    
    func getTodosById(id: String, dataHandler: @escaping DataCallback) {
        db.child(TABLES).child(id).child(TODOS).observe(.value, with: dataHandler)
    }
    
    func getTresorIdByTableId(tableId: String, dataHandler: @escaping DataCallback) {
        db.child(TABLES).child(tableId).child("tresorId").observeSingleEvent(of: .value, with: dataHandler)
    }
    
    func saveTodoList(list: TodoList, handler: @escaping SuccessCallback) {
        ZeroManager.shared.zeroKit?.createTresor(completion: { (tresorId, error) in
            guard error == nil else {
                log.error("Tresor creation failed")
                handler(false)
                return
            }
            APIManager.shared.approveTresor(tresorId: tresorId!, responseHandler: { (success) in
                let key = self.db.childByAutoId().key
                list.tresorId = tresorId
                list.id = key
                self.db.child(self.TABLES).child(key).setValue(list.toJSON(), withCompletionBlock: { (error, ref) in
                    handler(error == nil)
                })
            })
        })
    }
    
    func saveTodo(todo: Todo, tableId: String, handler: @escaping SuccessCallback) {
        let key = db.childByAutoId().key
        todo.id = key
        guard let jsonString = todo.toJSONString() else {
            log.error("Couldn't create json string from todo")
            handler(false)
            return
        }
        log.debug("Json string: \(jsonString)")
        getTresorIdByTableId(tableId: tableId) { (snapshot) in
            guard let tresorId = snapshot.value as? String else {
                log.error("Couldn't get tresorId for tableId \(tableId)")
                handler(false)
                return
            }
            ZeroManager.shared.zeroKit?.encrypt(plainText: jsonString, inTresor: tresorId, completion: { (encryptedTodo, error) in
                guard error == nil else {
                    log.error("Couldn't encrypt todo")
                    handler(false)
                    return
                }
                self.db.child(self.TABLES).child(tableId).child(self.TODOS).child(key).setValue(encryptedTodo!, withCompletionBlock: { (error, ref) in
                    handler(error == nil)
                })
            })
        }
    }
}
