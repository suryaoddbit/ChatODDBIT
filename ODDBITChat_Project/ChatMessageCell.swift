//
//  ChatMessageCell.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    var bubbleWidth : NSLayoutConstraint?
    let textChat : UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Sample Text"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        return tv
    }()
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    let bubbleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textChat)
        
        
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidth?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        

        textChat.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textChat.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textChat.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textChat.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder not implement")
    }
    
}
