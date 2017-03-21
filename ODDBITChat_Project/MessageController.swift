//
//  MessageController.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import UIKit
import Firebase

class MessageController: UITableViewController {
    
    var messages = [Messages]()
    var messagesDictionary = [String : Messages]()
    var cellid = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellid)
        
        checkIfUserIsLoggedIn()
        
       

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
            dismiss(animated: true, completion: nil)
        } catch let logoutError {
            print(logoutError)
        }
        

    }
    
    func handleNewMessage() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let listContact = story.instantiateViewController(withIdentifier: "ListContant") as! ListContact
        listContact.isPresent = true
        listContact.messageController = self
        let navController = UINavigationController(rootViewController: listContact)
        present(navController, animated: true, completion: nil)
    }
    
    func showChatController(_ user: Users){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func  observeUserMessage(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageReference = FIRDatabase.database().reference().child("messages").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let messages = Messages()
                    messages.setValuesForKeys(dictionary)
                    //self.messages.append(messages)
                    
                    if let chatPartnerId = messages.chatPartnerId(){
                        self.messagesDictionary[chatPartnerId] = messages
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (mess1, mess2) -> Bool in
                            return mess1.timestamp!.intValue > mess2.timestamp!.intValue
                        })
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }, withCancel: nil )
        }, withCancel: nil)
    }
    
    func observeMessage(){
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let messages = Messages()
                messages.setValuesForKeys(dictionary)
                //self.messages.append(messages)
                
                if let toId = messages.toId{
                    self.messagesDictionary[toId] = messages
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (mess1, mess2) -> Bool in
                        return mess1.timestamp!.intValue > mess2.timestamp!.intValue
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = Users()
                user.setValuesForKeys(dictionary)
                self.messages.removeAll()
                self.messagesDictionary.removeAll()
                self.tableView.reloadData()
                self.observeUserMessage()
                self.navigationItem.titleView = SetupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    

}

extension MessageController{
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard  let chatParnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatParnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = Users()
            user.id = chatParnerId
            user.setValuesForKeys(dictionary)
            self.showChatController(user)
        }, withCancel: nil)
    }
}
