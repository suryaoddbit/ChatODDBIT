//
//  ProfileController.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import UIKit
import Firebase

class ProfileController: UIViewController {

    
    let imgProfile : UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.masksToBounds = true
        img.image = UIImage(named: "user_default")
        return img
    }()
    
    let labelName : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "futura", size: 20)
        label.textColor = UIColor.black
        return label
    }()
    
    let labelEmail : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "futura", size: 20)
        label.textColor = UIColor.black
        return label
    }()
    
    let labelPhone : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "futura", size: 20)
        label.textColor = UIColor.black
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEdit))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(handleLogout))
        
        // set view profile
        self.view.addSubview(imgProfile)
        
        imgProfile.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        imgProfile.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        imgProfile.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imgProfile.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //set view name
        self.view.addSubview(labelName)
        labelName.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        labelName.topAnchor.constraint(equalTo: imgProfile.bottomAnchor, constant: 20).isActive = true
        labelName.widthAnchor.constraint(equalTo: self.labelName.widthAnchor).isActive = true
        labelName.heightAnchor.constraint(equalTo: self.labelName.heightAnchor).isActive = true
        
        labelName.text = "-"
        
        //set view email
        self.view.addSubview(labelEmail)
        labelEmail.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        labelEmail.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 20).isActive = true
        labelEmail.widthAnchor.constraint(equalTo: self.labelEmail.widthAnchor).isActive = true
        labelEmail.heightAnchor.constraint(equalTo: self.labelEmail.heightAnchor).isActive = true
        labelEmail.text = "-"
        
        //set phoene label
        self.view.addSubview(labelPhone)
        labelPhone.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        labelPhone.topAnchor.constraint(equalTo: labelEmail.bottomAnchor, constant : 20).isActive = true
        labelPhone.widthAnchor.constraint(equalTo: self.labelPhone.widthAnchor).isActive = true
        labelPhone.heightAnchor.constraint(equalTo: self.labelPhone.heightAnchor).isActive = true
        labelPhone.text = "-"
        
        
        
        
        fetchUserAndSetupBar()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetchUserAndSetupBar(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let user = Users()
                user.setValuesForKeys(dictionary)
                self.navigationItem.titleView = SetupNavBarWithUser(user)
                self.labelEmail.text = user.email
                self.labelName.text = user.name
                self.labelPhone.text = user.phone
                
                
                if let imgUrl = user.profileImageUrl{
                    self.imgProfile.loadImageUsingCache(urlString: imgUrl)
                    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width/2
                }
                
            }
            
        }, withCancel: nil)
    }
    
    //func Logout
    func handleLogout(){
        do {
            try FIRAuth.auth()?.signOut()
        } catch  {
            print("Cannot Sign Out")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func handleEdit(){
        let edit = EditProfileController()
        edit.profileControl = self
        let navController = UINavigationController(rootViewController: edit)
        present(navController, animated: true, completion: nil)
    }
    

}

