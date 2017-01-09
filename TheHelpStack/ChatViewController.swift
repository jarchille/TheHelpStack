//
//  ViewController.swift
//  TheHelpStack
//
//  Created by Jonathan Archille on 1/8/17.
//  Copyright © 2017 The Iron Yard. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    
    var messages = Array<FIRDataSnapshot>()
    var textFieldContainerViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        checkifUserLoggedIn()
        
        observeMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    let tableViewz: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let textFieldContainerView: UIView = {
        let cv = UIView()
        cv.backgroundColor = UIColor(white: 0.8, alpha: 1)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    lazy var messageTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Enter message..."
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var messageTextFieldChatSendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    func setupViews()
    {
        title = "HelpStack"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(showKeyboard))
        
        view.addSubview(tableViewz)
        view.addSubview(textFieldContainerView)
        
        textFieldContainerView.addSubview(messageTextFieldChatSendButton)
        textFieldContainerView.addSubview(messageTextField)
        
        // MARK: - Configure Table View
        
        tableViewz.register(MessageTableViewCell.self, forCellReuseIdentifier: "ChatCell")
        tableViewz.dataSource = self
        tableViewz.rowHeight = UITableViewAutomaticDimension
        tableViewz.estimatedRowHeight = 100
        tableViewz.allowsMultipleSelectionDuringEditing = true
        
        tableViewz.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableViewz.bottomAnchor.constraint(equalTo: textFieldContainerView.topAnchor, constant: 8).isActive = true
        tableViewz.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableViewz.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        textFieldContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        textFieldContainerViewBottomAnchor = textFieldContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        textFieldContainerViewBottomAnchor?.isActive = true
        textFieldContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        textFieldContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        messageTextField.leftAnchor.constraint(equalTo: textFieldContainerView.leftAnchor, constant: 8).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: textFieldContainerView.centerYAnchor).isActive = true
        messageTextField.rightAnchor.constraint(equalTo: messageTextFieldChatSendButton.leftAnchor).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: textFieldContainerView.heightAnchor, constant: -16).isActive = true
        
        messageTextFieldChatSendButton.rightAnchor.constraint(equalTo: textFieldContainerView.rightAnchor).isActive = true
        messageTextFieldChatSendButton.centerYAnchor.constraint(equalTo: textFieldContainerView.centerYAnchor).isActive = true
        messageTextFieldChatSendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        messageTextFieldChatSendButton.heightAnchor.constraint(equalTo: textFieldContainerView.heightAnchor).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! MessageTableViewCell
        let messageSnapshot = messages[indexPath.row]
        print(messageSnapshot)
        let message = messageSnapshot.value as? Dictionary<String, String>
        if let _message = message?["message"], let timestamp = message?["timestamp"]
        {
            cell.nameLabel.text = "Message sent: \(timestamp)"
            cell.detailLabel.text = _message
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        print(indexPath.row)
        print(messages[indexPath.row])
        
        let messageToDelete = messages[indexPath.row]
        
        FIRDatabase.database().reference().child("messages").child(messageToDelete.key).removeValue(completionBlock: ({  (error, ref) in
            
            if error != nil
            {
                print("deletion error")
                return
            }
            DispatchQueue.main.async() {
                self.messages.remove(at: indexPath.row)
                self.tableViewz.deleteRows(at: [indexPath], with: .automatic)
                self.tableViewz.reloadData()
            }
        }))
    }
    
    // MARK: - Helper functions
    
    func checkifUserLoggedIn ()
    {
        if FIRAuth.auth()?.currentUser?.uid == nil
        {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    
    func handleLogout()
    {
        do {
            try FIRAuth.auth()?.signOut()
        } catch
            let logoutError
        {
            print(logoutError)
        }
        
        let loginController = LoginViewController()
        present(loginController, animated: true, completion: nil)
        
    }
    
    func showKeyboard()
    {
        messageTextField.becomeFirstResponder()
        
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let height = ((notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height)
        textFieldContainerViewBottomAnchor?.isActive = false
        textFieldContainerViewBottomAnchor = textFieldContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -height)
        textFieldContainerViewBottomAnchor?.isActive = true
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        textFieldContainerViewBottomAnchor?.isActive = false
        textFieldContainerViewBottomAnchor = textFieldContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        textFieldContainerViewBottomAnchor?.isActive = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        sendMessage()
        messageTextField.resignFirstResponder()
        messageTextField.text = ""
        return false
    }
    
    func sendMessage()
    {
        let ref = FIRDatabase.database().reference().child("messages").childByAutoId()
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        let formattedDateTime = formatter.string(from: currentDateTime)
        let values = ["message" : self.messageTextField.text, "timestamp" : formattedDateTime] as [String : Any]
        ref.updateChildValues(values)
        messageTextField.text = ""
        messageTextField.resignFirstResponder()
    }
    
    func observeMessages() {
        FIRDatabase.database().reference().child("messages").observe(.childAdded, with: { (snapshot) -> Void in
            
            self.messages.append(snapshot)
            let indexpath = IndexPath(row: self.messages.count - 1, section: 0)
            
            DispatchQueue.main.async() {
                self.tableViewz.reloadData()
                self.tableViewz.scrollToRow(at: indexpath, at: .bottom, animated: true)
            }
        })
    }
    
}

