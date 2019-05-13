//
//  TicTacToeTableViewController.swift
//  TicChatToe
//
//  Created by Hunter Boleman on 5/2/19.
//  Copyright © 2019 Ricky Bernal. All rights reserved.
//

import UIKit
import Parse

class TicTacToeViewController: UIViewController, UITableViewDataSource {

    // Make UserDefautls Accessable
    //let defaults = UserDefaults.standard
    
    // Class Variables
    var connectedUser: String = "" 
    let expireTime = 30.0;
    var currentTurnNum = 0;
    let dataExpireTime = 60.0;
    var tttRunTimer: Bool = true;
    var tttTimerCount: Int = 0;
    var tttTimerMax: Int = 3;
    
    // Master Message Object
    var chatMessages: [PFObject] = [];
    var tttData: [PFObject] = [];
    
    //Outlets
    @IBOutlet weak var chatMessageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillDisappear(_ animated: Bool) {
        
//        if (defaults.string(forKey: "nil_test") == nil){
//            defaults.set(true, forKey: "reset");
//            defaults.set("TEST", forKey: "nil_test");
//            defaults.synchronize();
//        }
//        defaults.set(true, forKey: "reset");
//        defaults.synchronize();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TESTING: \(connectedUser)")
        
        // Needed for the UITableView
        tableView.dataSource = self as UITableViewDataSource
        // Auto size row height based on cell autolayout constraints
        tableView.rowHeight = UITableView.automaticDimension
        // Provide an estimated row height. Used for calculating scroll indicator
        tableView.estimatedRowHeight = 50
        // Sets getChatMessage to retrieve messages every 5 seconds
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.getChatMessages), userInfo: nil, repeats: true)
        // runs getChatMessages for the first time
        getChatMessages();
        print ("reload tableView")
        self.tableView.reloadData();

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //-------------------- Main Timer Function --------------------//
    
    // The logic that will run on a timer
    @objc func timedFunc() {
        // Run when timer is "active"
        if (tttRunTimer == true){
            print("in active timed func")
            
            // Refresh player list at begining of count
            if (tttTimerCount <= 0){
                getTicTacToeData()
            }
            
            // Listen for data at end of count
            if (tttTimerCount >= tttTimerMax){
                listenForValidMove()
            }
            
            // Used to create actions on a delay
            if (tttTimerCount >= tttTimerMax){tttTimerCount = 0}
            tttTimerCount = tttTimerCount + 1;
        }
    }
    
    //-------------------- Chat Functionality --------------------//
    
    // Gets Chat Messages
    @objc func getChatMessages(){
        let query = PFQuery(className:"Messages")
        query.addDescendingOrder("createdAt")
        query.limit = 5
        query.includeKey("user")
        
        query.findObjectsInBackground { (messages, error) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let messages = messages {
                // The find succeeded.
                self.chatMessages = messages
                print("Successfully retrieved \(messages.count) posts.")
            }
        }
        print ("reload tableView")
        self.tableView.reloadData();
    }
    
    // Sends The User's Message
    @IBAction func doSendMessage(_ sender: Any) {
        let chatMessage = PFObject(className: "Messages");
        chatMessage["text"] = chatMessageField.text!
        chatMessage["user"] = PFUser.current();
        chatMessage.saveInBackground { (success, error) in
            if success {
                print("The message was saved!")
                self.chatMessageField.text = "";
            } else if let error = error {
                print("Problem saving message: \(error.localizedDescription)")
            }
        }
    }
    
    //-------------------- Table View Related --------------------//
    
    // Sets Table Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for index in 0..<chatMessages.count {
            isExpired(obj: chatMessages[index])
        }
        return chatMessages.count;
    }
    
    // Sets Table Cell Contents
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reusable Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicTacToeTableViewCell") as! TicTacToeTableViewCell;
        // gets a single message
        let chatMessage = chatMessages[indexPath.row];
        // Set text
        cell.messageLable.text = chatMessage["text"] as? String;
        //Set username
        if let user = chatMessage["user"] as? PFUser {
            // User found! update username label with username
            cell.usernameLabel.text = user.username;
        } else {
            // No user found, set default username
            cell.usernameLabel.text = "🤖"
        }
        return cell;
    }
    
    //-------------------- Utilities --------------------//
    
    // Finds if object is expired or not, and if it is it will call the garbage collector.
    func isExpired(obj: PFObject) -> Bool {
        if ((obj.createdAt) == nil){
            print("EXPIRED")
            garbageObj(obj: obj)
            return true;
        }
        
        
        let storedTime = obj.createdAt as! Date;
        let expTime = storedTime.addingTimeInterval(expireTime);
        let nowTime = Date();
        
        if (expTime < nowTime){
            garbageObj(obj: obj)
            return true
        }
        else {
            return false
        }
    }
    
    // Finds if object is expired or not, and if it is it will call the garbage collector.
    func isDataExpired(obj: PFObject) -> Bool {
        if ((obj.createdAt) == nil){
            print("EXPIRED")
            garbageObj(obj: obj)
            return true;
        }
        
        
        let storedTime = obj.createdAt as! Date;
        let expTime = storedTime.addingTimeInterval(dataExpireTime);
        let nowTime = Date();
        
        if (expTime < nowTime){
            garbageObj(obj: obj)
            return true
        }
        else {
            return false
        }
    }
    
    // Used for populating the tableview without disrupting it's own process (aka, it doesn't remove anything during the check)
    func canDisplay(obj: PFObject) -> Bool {
        if ((obj.createdAt) == nil){
            print("EXPIRED")
            return false;
        }
        
        let storedTime = obj.createdAt as! Date;
        let expTime = storedTime.addingTimeInterval(expireTime);
        let nowTime = Date();
        
        if (expTime < nowTime){
            return false
        }
        else {
            return true
        }
    }
    
    // Removed a specified object
    func garbageObj(obj: PFObject){
        obj.deleteInBackground(block: { (sucess, error) in
            if (sucess == true){
                print("Delete: TRUE")
                //self.getOnlineUserList()
            }
            else {
                print("Delete: FALSE")
            }
        })
    }
    
    //-------------------- Tic Tac Toe Data Handling --------------------//
    
    func sendValidMove(symbol: String, row: Int, col: Int, turnNum: Int){
        let data = PFObject(className: "TicTacToe");
        data["user"] = PFUser.current();
        data["symbol"] = symbol
        data["row"] = row
        data["col"] = col
        data["turn"] = turnNum
        data.saveInBackground { (success, error) in
            if success {
                print("The TicTacToe message was saved!")
                self.chatMessageField.text = "";
            } else if let error = error {
                print("Problem saving message: \(error.localizedDescription)")
            }
        }
    }
    
    func listenForValidMove(){
        // [row][col]
        //   1 2 3
        // 1 X X X
        // 2 X X X
        // 3 X X X
        
        for index in 0..<tttData.count {
            let singleData = tttData[index];
            let user = singleData["user"] as! PFUser
            let symbol = singleData["symbol"] as! String
            let row = singleData["row"] as! Int
            let col = singleData["col"] as! Int
            let turn = singleData["turn"] as! Int
            
            if (user.username == connectedUser && turn > currentTurnNum){
                // Send move to Tic Tac Toe Front End Logic
                // processRecievedMove(symbol, row, col, turn)
                garbageObj(obj: singleData)
            }
            // Remove old data
            if (isExpired(obj: singleData)){}
        }
    }
    
    func getTicTacToeData(){
        let query = PFQuery(className:"TicTacToe")
        query.addDescendingOrder("createdAt")
        query.limit = 20
        query.includeKey("user")
        
        query.findObjectsInBackground { (messages, error) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let messages = messages {
                // The find succeeded.
                self.tttData = messages
                print("Successfully retrieved TicTacToe \(messages.count) posts.")
            }
        }
    }
}
