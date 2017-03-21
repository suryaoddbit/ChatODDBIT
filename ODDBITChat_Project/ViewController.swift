//
//  ViewController.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI



class ViewController: UIViewController, UINavigationControllerDelegate {
    
    fileprivate var _authHandler : FIRAuthStateDidChangeListenerHandle!
    var user : FIRUser?
    
    var displayName = "Anonymous"
    
    
    let imgProfile : UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.masksToBounds = true
        img.image = UIImage(named: "Firebase")
        return img
    }()
    
    let labelName : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "futura-Bold", size: 32)
        label.textColor = UIColor.white
        return label
    }()
    
    let btnLogin : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont(name: "futura-Bold", size: 20)
        btn.backgroundColor = UIColor(r: 255, g: 165, b: 0)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        labelName.text = "ODDBIT CHAT"
        
        
        //set view btn
        self.view.addSubview(btnLogin)
        btnLogin.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        btnLogin.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 30).isActive = true
        btnLogin.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -80).isActive = true
        btnLogin.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        btnLogin.setTitle("SIGN IN", for: .normal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(handleLogout))
        btnLogin.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        if FIRAuth.auth()?.currentUser?.uid == nil{
            checkSession()
        } else{
            print("Is Login")
            let mainST = UIStoryboard(name: "Main", bundle: Bundle.main)
            let VC = mainST.instantiateViewController(withIdentifier: "tabbar")
            self.present(VC, animated: true, completion: nil)
        }
       
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func checkSession(){
        let provide : [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provide
        
        _authHandler = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user: FIRUser?) in
            
            if let activeUser = user {
                self.navigationItem.leftBarButtonItem?.title = "Logout"
                if self.user != activeUser{
                    self.user = activeUser
                    let name = user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                    self.navigationItem.title = user!.displayName
                    print(user!.uid)
                    let databaseRef = FIRDatabase.database().reference()
                    
                    databaseRef.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if !snapshot.hasChild(user!.uid){
                            
                            print("false => \(user!.uid) not exist")
                            
                            let photoURL = user?.photoURL?.absoluteString ?? nil
                            let value : [String : Any] = ["name": self.displayName,
                                                          "email": user!.email!,
                                                          "profileImageUrl" : photoURL ?? nil ]
                            self.registerUserIntoDatabaseWithUID(uid: user!.uid, values: value)
                            
                        }
                        
                        let mainST = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let VC = mainST.instantiateViewController(withIdentifier: "tabbar")
                        self.present(VC, animated: true, completion: nil)
                        
                        
                    })
                    
                    
                }
                
            }else{
                self.loginSession()
            }
        })
        
    }
    
    func loginSession(){
        self.navigationItem.leftBarButtonItem?.title = "Login"
        let authView = FUIAuth.defaultAuthUI()!.authViewController()
        present(authView, animated: true, completion: nil)
    }
    
    func handleLogout(){
        print("Logout")
        do {
            try FIRAuth.auth()?.signOut()
            checkSession()
        } catch  {
            print("Unable sign Out ")
        }
    }
    
    func registerUserIntoDatabaseWithUID(uid : String, values: [String : Any]){
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users").child(uid)
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print("Error Register \(err)")
                return
            }
            
            print("save user succesfully into firebase database ")
        })
    }
    
    

}

