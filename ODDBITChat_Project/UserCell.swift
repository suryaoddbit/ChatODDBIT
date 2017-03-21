//
//  UserCell.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import UIKit
import Firebase

class UserCell : UITableViewCell {
    
    var message : Messages?{
        didSet{
            setupNameAndProfileImage()
            //        cell.textLabel?.text = message.text
            detailTextLabel?.text = message?.text
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    
    private func setupNameAndProfileImage(){
        
        
        if let id = message?.chatPartnerId(){
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject]{
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let imgUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCache(urlString: imgUrl)
                    }
                }
                
                print(snapshot)
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        iv.image = UIImage(named: "user_default")
        return iv
    }()
    
    
    let timeLabel : UILabel = {
       let label = UILabel()
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier : reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //label time
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
