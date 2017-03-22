import UIKit
import ObjectMapper

enum ListingType {
    case todoLists
    case todos
}

class ListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var listType: ListingType = .todoLists
    var listItems = [Listable]()
    
    var todoListId: String?
    var navTitle: String = "Todo Lists"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navTitle
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(menuTapped))
        self.navigationItem.rightBarButtonItem = button
        
        if listType == .todoLists {
            self.navigationItem.hidesBackButton = true
            
            DatabaseManager.shared.getTodoLists(dataHandler: { (snapshot) in
                if let values : [String: Any] = snapshot.value as? [String: Any] {
                    self.listItems.removeAll()
                    for key in values.keys {
                        if let value: [String: Any] = values[key] as? [String: Any] {
                            log.debug("\n\n\nKey \(key) = \(value)")
                            let map = Map(mappingType: MappingType.fromJSON, JSON: value)
                            if let todoList = TodoList(map: map) {
                                self.listItems.append(todoList)
                            } else {
                                log.error("Couldn't parse todolist from map \(map)")
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        } else if let id = todoListId {
            self.navigationItem.hidesBackButton = false
            
            DatabaseManager.shared.getTodosById(id: id, dataHandler: { (snapshot) in
                if let values : [String: Any] = snapshot.value as? [String: Any] {
                    self.listItems.removeAll()
                    for key in values.keys {
                        let value: String = values[key] as! String
                        log.debug("Key \(key), value: \(value)")
                        let todo = Todo(id: key, encryptedTodo: value)
                        self.listItems.append(todo)
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            // TODO: Detach observers
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell {
            if self.listType == .todoLists {
                cell.titleLabel.text = listItems[indexPath.row].listingDescription()
            } else {
                cell.setTodo(todo: listItems[indexPath.row] as! Todo)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.listType == .todoLists {
            if let details = self.storyboard?.instantiateViewController(withIdentifier: "ListView") as? ListViewController {
                let list = listItems[indexPath.row] as! TodoList
                details.listType = .todos
                details.todoListId = list.id
                details.navTitle = list.title
                self.navigationController?.pushViewController(details, animated: true)
            }
        }
    }
    
    func menuTapped() {
        let sheet = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        if listType == .todoLists {
            sheet.addAction(UIAlertAction(title: "Create List", style: .default, handler: { (action) in
                self.createList()
            }))
        } else {
            sheet.addAction(UIAlertAction(title: "New Todo", style: .default, handler: { (action) in
                self.newTodo()
            }))
            sheet.addAction(UIAlertAction(title: "Share List", style: .default, handler: { (action) in
                self.shareList()
            }))
            sheet.addAction(UIAlertAction(title: "Invite", style: .default, handler: { (action) in
                self.invite()
            }))
        }
        sheet.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            self.logout()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    func createList() {
        let alert = UIAlertController(title: "New List", message: "Please name your list", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "Todo list name"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            if let text = alert.textFields?[0].text, text.characters.count > 0 {
                let newList = TodoList(title: text)
                self.showProgress()
                DatabaseManager.shared.saveTodoList(list: newList, handler: { (success) in
                    self.hideProgress()
                    if success {
                        self.showAlert("Created table with title \(text)")
                    } else {
                        self.showAlert("Couldn't create table")
                    }
                })
            } else {
                self.showAlert("Title can't be empty")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func newTodo() {
        if let tableId = self.todoListId {
            let alert = UIAlertController(title: "New Todo", message: "Please fill in the information", preferredStyle: .alert)
            alert.addTextField { (field) in
                field.placeholder = "Todo title"
            }
            alert.addTextField { (field) in
                field.placeholder = "Todo description"
            }
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
                if let title = alert.textFields?[0].text, let desc = alert.textFields?[1].text, title.characters.count > 0 {
                    let todo = Todo(title: title, description: desc)
                    self.showProgress()
                    
                    DatabaseManager.shared.saveTodo(todo: todo, tableId: tableId, handler: { (success) in
                        self.hideProgress()
                        if success {
                            self.showAlert("Created Todo with title \(title)")
                        } else {
                            self.showAlert("Couldn't create Todo")
                        }
                    })
                } else {
                    self.showAlert("Title and description can't be empty")
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func shareList() {
        if let tableId = self.todoListId {
            let alert = UIAlertController(title: "Share Todo list", message: "Enter the username of the person to share with", preferredStyle: .alert)
            alert.addTextField { (field) in
                field.placeholder = "Username"
            }
            alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action) in
                if let username = alert.textFields?[0].text, username.characters.count > 0 {
                    self.showProgress()
                    APIManager.shared.shareTable(tableId: tableId, withUser: username, responseHandler: { (success, error) in
                        self.hideProgress()
                        if success {
                            self.showAlert("Successfully shared todo list with \(username)")
                        } else {
                            self.showAlert("Error", message: error)
                        }
                    })
                } else {
                    self.showAlert("Username can't be empty")
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func invite() {
        if let tableId = self.todoListId {
            let alert = UIAlertController(title: "Invite", message: "Enter a password", preferredStyle: .alert)
            alert.addTextField { (field) in
                field.placeholder = "Password"
                field.isSecureTextEntry = true
            }
            alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
                if let password = alert.textFields?[0].text, password.characters.count > 0 {
                    self.showProgress()
                    APIManager.shared.createInvitationLink(tableId: tableId, password: password, message: "Some message", responseHandler: { (url) in
                        self.hideProgress()
                        if let url = url?.absoluteString {
                            self.showAlert("Link created and copied to pasteboard")
                            UIPasteboard.general.string = url
                        } else {
                            self.showAlert("Error")
                        }
                    })
                } else {
                    self.showAlert("Password can't be empty")
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func logout() {
        self.showProgress()
        ZeroManager.shared.zeroKit?.logout(completion: { (error) in
            self.hideProgress()
            
            guard error == nil else {
                log.error("Couldn't log out")
                self.showAlert("Error", message: "Logout failed with error: \(error!.localizedDescription)")
                return
            }
            
            let _ = self.navigationController?.popToRootViewController(animated: true)
        })
    }
}
