//
//  EditProfileController.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UIViewController {
    var user = Users()
    var profileControl = ProfileController()
    

    let imgProfile : UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.masksToBounds = true
        img.image = UIImage(named: "user_default")
        return img
    }()
    
    let labelName : UITextField = {
        let label = UITextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.borderStyle = .roundedRect
        label.font = UIFont(name: "futura", size: 20)
        label.textColor = UIColor.black
        return label
    }()
    
    let labelEmail : UITextField = {
        let label = UITextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.borderStyle = .roundedRect
        label.font = UIFont(name: "futura", size: 20)
        label.textColor = UIColor.black
        return label
    }()
    
    let labelPhone : UITextField = {
        let label = UITextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "futura", size: 20)
        label.borderStyle = .roundedRect
        label.textColor = UIColor.black
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
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
        labelName.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant : -80).isActive = true
        labelName.heightAnchor.constraint(equalTo: self.labelName.heightAnchor).isActive = true
        
        labelName.placeholder = "Name"
        
        //set view email
        self.view.addSubview(labelEmail)
        labelEmail.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        labelEmail.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 20).isActive = true
        labelEmail.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant : -80).isActive = true
        labelEmail.heightAnchor.constraint(equalTo: self.labelEmail.heightAnchor).isActive = true
        labelEmail.placeholder = "Email"
        
        //set phoene label
        self.view.addSubview(labelPhone)
        labelPhone.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        labelPhone.topAnchor.constraint(equalTo: labelEmail.bottomAnchor, constant : 20).isActive = true
         labelPhone.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant : -80).isActive = true
        labelPhone.heightAnchor.constraint(equalTo: self.labelPhone.heightAnchor).isActive = true
        labelPhone.placeholder = "phone"
        

        fetchUser()
        
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
    
    func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUser(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                
                self.user.setValuesForKeys(dictionary)
                self.labelName.text = self.user.name
                self.labelEmail.text = self.user.email
                self.labelPhone.text = self.user.phone
                
                if let imgUrl = self.user.profileImageUrl{
                    self.imgProfile.loadImageUsingCache(urlString: imgUrl)
                    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width/2

                }
                
            }
        }, withCancel: nil)
    }
    
    func handleDone(){
        let email = labelEmail.text
        let name = labelName.text
        let phone = labelPhone.text
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {  print("Error Edit Data")
            return
        }
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users").child(uid)
        let values = ["name":name, "email":email,"profileImageUrl": user.profileImageUrl,"phone":phone]
        userRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print("Error Edit : \(error)")
                return
            }
            //print("Success Edit Data")
            self.profileControl.fetchUserAndSetupBar()
            let alert = UIAlertController(title: nil, message: "Success Edit Data", preferredStyle: UIAlertControllerStyle.alert)
            let actionYes = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(actionYes)
            self.present(alert, animated: true, completion: nil)
        }
    }

}
