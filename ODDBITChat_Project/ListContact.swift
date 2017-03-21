//
//  ListContact.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import UIKit
import Firebase

class ListContact: UITableViewController {
    
    var cellId = "cell"
    var users = [Users]()
    var isPresent : Bool = false
    var messageController : MessageController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handlerLogout))
        fetchUserAndSetupNavBarTitle()
        
        
        
        if isPresent{
            navigationItem.leftBarButtonItem?.title = "Cancel"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let imgURl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCache(urlString: imgURl)
        }


        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPresent{
            dismiss(animated: true, completion: {
                let user = self.users[indexPath.row]
                self.messageController?.showChatController(user)
            })
        }
    }
    

    
    
    func handlerLogout(){
        if !isPresent{
            print("Logout")
            do {
                try
                FIRAuth.auth()?.signOut()
                
            } catch  {
                print("Unable sign Out ")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    func handlerNewMessage(){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func fetchUser(){
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let users = Users()
                users.id = snapshot.key
                users.setValuesForKeys(dictionary)
                self.users.append(users);
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        },withCancel: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = Users()
                user.setValuesForKeys(dictionary)
                self.users.removeAll()
                self.tableView.reloadData()
                self.fetchUser()
                self.navigationItem.titleView = SetupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    

}


