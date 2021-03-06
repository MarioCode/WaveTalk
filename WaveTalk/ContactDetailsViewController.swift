//
//  tmpViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 07.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UITableViewController {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var presenceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var notificationStatus: UISwitch!
    
    var contact = Contact()
    var detailsSocket = TCPSocket()
    var myUserName: String?
    var myURL: String?
    var userMessages = [Message]()
    var delegate: UserListProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if contact.profileImageURL != nil {
            if (contact.profileImageURL?.count)! > 2 {
                photoImage.loadImageUsingCacheWithUrlString(urlString: contact.profileImageURL!)
            } else {
                photoImage.loadImageUsingCacheWithUrlString(urlString: "#" + contact.username! + " " + contact.profileImageURL!)
            }
        }
        
        usernameLabel.text = contact.username
        presenceLabel.text = contact.lastPresenceTime
        statusLabel.text = contact.status
        phoneLabel.text = contact.phoneNumber_or_Email
        (contact.notifications == true) ? (notificationStatus.setOn(true, animated: true)) : (notificationStatus.setOn(false, animated: true))
        
        let tabBarVC = self.tabBarController  as! MainUserTabViewController
        detailsSocket = tabBarVC.clientSocket
        myURL = tabBarVC.myProfile.profileImageURL
        self.navigationItem.title = usernameLabel.text
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadChatHistoryPerUser()
        (self.tabBarController  as! MainUserTabViewController).startReadingQueue(for: detailsSocket.client)
    }
    
    
    func loadChatHistoryPerUser() {
        Logger.mark()
        
        if let response = sendRequest(using: detailsSocket) {
            var bodyOfResponse: String = ""
            let head = response.getHeadOfResponse(with: &bodyOfResponse)
            
            switch(head) {
            case "PERU":
                parseResponseData(response: bodyOfResponse)
                break
            case "EMPT":
                Logger.debug(msg: "Chat List is empty" as AnyObject)
            default:
                Logger.error(msg: "Auth Error - Bad response" as AnyObject)
            }
        } else {
            Logger.error(msg: "Auth Error - Bad request" as AnyObject)
        }
    }
    
    
    private func sendRequest(using client: TCPSocket) -> String? {
        Logger.mark()
        
        if myUserName != nil {
            
            switch client.client.send(string: "LCPU" + myUserName! + " /s " + contact.username!) {
            case .success:
                return client.readResponse()
            case .failure(let error):
                Logger.error(msg: error as AnyObject)
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    func parseResponseData(response: String) {
        Logger.mark()
        
        let res = response
        var messages = res.components(separatedBy: " /pm ")
        messages.remove(at: 0) // empty string - [0]
        
        for message in messages {
            var msg = message.components(separatedBy: " /s ")
            let mess = Message()
            
            mess.from_to = msg[0]
            mess.text = msg[1]
            mess.messageTime = msg[2]
            
            self.userMessages.append(mess)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            self.notificationSwitch(true)
        }
    }
    
    
    @IBAction func notificationSwitch(_ sender: Any) {
        var state = ""
        
        if contact.notifications == true {
            contact.notifications = false
            state = "NO"
            self.notificationStatus.setOn(false, animated: true)
        } else {
            contact.notifications = true
            state = "YES"
            self.notificationStatus.setOn(true, animated: true)
        }
        
        delegate?.updateNotificationState(username: contact.username!, state: contact.notifications!)
        _ = detailsSocket.client.send(string: "UPNU" + myUserName! + " /s " + contact.username! + " /s " + state)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startChatWithUser" {
            let destinationController = segue.destination as! ChattingViewController
            
            destinationController.myURLImage = self.myURL
            destinationController.userImage = photoImage.image
            destinationController.chatMessages = userMessages
            destinationController.myUserName = myUserName
            destinationController.setUserTitle = contact.username
            
            self.userMessages.removeAll()
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
