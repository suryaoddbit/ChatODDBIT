//
//  ChatLogController.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    let cellId = "cellId"
    var messages = [Messages]()
    
    var user : Users?{
        didSet{
            self.navigationItem.title = user?.name
            observeMessage()
        }
    }
    
    func observeMessage(){
        guard  let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                
                let message = Messages()
                
                //potensial id crashing id ket dont match
                message.setValuesForKeys(dictionary)
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
                print(message.text)
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    lazy var inputText : UITextField = {
        let txt = UITextField()
        txt.placeholder = "Enter Message"
        txt.delegate = self
        txt.translatesAutoresizingMaskIntoConstraints = false
        return txt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 120, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupInputView()

        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func setupInputView(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        self.view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handlerSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
       
        containerView.addSubview(inputText)
        
        inputText.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant : 8).isActive = true
        inputText.centerYAnchor .constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputText.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputText.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.gray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLine)
        
        separatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func handlerSend(){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toid = user!.id!
        let fromid = FIRAuth.auth()!.currentUser!.uid
        let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let value = ["text":inputText.text!, "toId": toid, "fromId": fromid, "timestamp": timestamp] as [String : Any]
        childRef.updateChildValues(value) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            
            self.inputText.text = nil
            
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromid)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toid)
            recipUserMessageRef.updateChildValues([messageId: 1])
            self.inputText.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handlerSend()
        return true
    }
    
    

    
}

extension ChatLogController{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
       cell.textChat.text = message.text
        cell.bubbleWidth?.constant = estimateFrameForText(message.text!).width + 32
        return cell
        
    }
}

extension ChatLogController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[(indexPath as NSIndexPath).item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 25
        }
        
  
        return CGSize(width: view.frame.width, height: height)
    }
    
     func estimateFrameForText(_ text : String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
}













