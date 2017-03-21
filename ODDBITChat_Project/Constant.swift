//
//  Constant.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import Foundation
import UIKit
import FirebaseAuth
import Firebase


let imgCache = NSCache<AnyObject, AnyObject>()
extension UIImageView{
    
    func loadImageUsingCache(urlString : String){
        self.image = nil
        if let cacheImage = imgCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cacheImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil{
                print(error)
                return
            }
            DispatchQueue.main.async {
                //cell.prof?.image = UIImage(data: data!)
                //cell.profileImageView.im
                if let downloadImage = UIImage(data: data!){
                    imgCache.setObject(downloadImage, forKey: urlString as AnyObject)
                    self.image = downloadImage
                }
            }
            
            
        }).resume()
    }
    
}


var myUID = FIRAuth.auth()?.currentUser?.uid

func SetupNavBarWithUser(_ user: Users) -> UIView {

    
    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    //        titleView.backgroundColor = UIColor.redColor()
    
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.addSubview(containerView)
    
    let profileImageView = UIImageView()
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = 20
    profileImageView.clipsToBounds = true
    if let profileImageUrl = user.profileImageUrl {
        profileImageView.loadImageUsingCache(urlString: profileImageUrl)
    }
    
    containerView.addSubview(profileImageView)
    profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    let nameLabel = UILabel()
    
    containerView.addSubview(nameLabel)
    nameLabel.text = user.name
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.font = UIFont(name: "futura", size: 20)
    nameLabel.textColor = UIColor.white
    nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
    
    containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
    containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    
    return titleView
}


struct Constants {
    
    // MARK: NotificationKeys
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    // MARK: MessageFields
    
    struct MessageFields {
        static let name = "name"
        static let text = "text"
        static let imageUrl = "photoUrl"
    }
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}




