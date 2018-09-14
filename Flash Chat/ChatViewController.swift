//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray: [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var messageTextfield: UITextField!
    
    @IBOutlet var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        navigationItem.hidesBackButton = true
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        let tapGesture = UIGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        
        retrieveMessages()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationItem.hidesBackButton = false
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        let currentMessage = messageArray[indexPath.row]
        
        cell.messageBody.text = currentMessage.messageBody

        cell.senderUsername.text = currentMessage.sender
        
        cell.avatarImageView.image = #imageLiteral(resourceName: "egg")

        if currentMessage.sender != Auth.auth().currentUser?.email {
            cell.messageBackground.backgroundColor = UIColor.flatMint()
        } else {
            cell.messageBackground.backgroundColor = UIColor.flatRed()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped () {
        print("ending")
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    func configureTableView () {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    
    var preEditHeightConstraint: CGFloat?
    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textView: UITextField) {
        preEditHeightConstraint = heightConstraint.constant

        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textView: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = self.preEditHeightConstraint!
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        SVProgressHUD.show()

        messageTextfield.endEditing(true)

        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let fireDB = Database.database().reference().child("Messages")
        
        let message = [
            "Sender": Auth.auth().currentUser?.email,
            "Message": messageTextfield.text
        ]
        
        // `.childByAutoId()` -> Custom random key for the message object
        fireDB.childByAutoId().setValue(message) {
            (error, ref) in
            if error != nil {
                print("Some error saving message")
            } else {
                print("Message saved")
                self.messageTextfield.text = ""
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages () {
        let messagesDB = Database.database().reference().child("Messages")
        
        messagesDB.observe(.childAdded) { (dataSnapshot) in
            let snapshotValue = dataSnapshot.value as! Dictionary<String, String>
            
            let sender = snapshotValue["Sender"]!
            
            let messageBody = snapshotValue["Message"]!
            
            self.messageArray.append(Message(sender: sender, message: messageBody))
            
            self.configureTableView()
            
            self.messageTableView.reloadData()
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error signing out")
        }
    }
}
