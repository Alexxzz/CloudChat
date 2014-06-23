//
//  CloudChat.swift
//  CloudChat
//
//  Created by Alexander on 18/06/14.
//  Copyright (c) 2014 Alexander. All rights reserved.
//

import CloudKit

let CloudChatErrorDomain = "CloudChatErrorDomain"

enum CloudChatError: Int {
    case MissingUserRecord = 0
    case ChatRoomWithProvidedNameExists = 1
    case ChatRoomWithProvidedNameMissing = 2
}

class CloudChat
{
    let container = CKContainer.defaultContainer()
    var publicDatabase: CKDatabase {
        get {
            return container.publicCloudDatabase
        }
    }
    
    var currentUser: User?
    
    init() {
        
    }
    
    // MARK: - User
    
    func getCurrentUser(completion: ((user: User!, error: NSError!) -> ()) ) {
        container.accountStatusWithCompletionHandler { (status: CKAccountStatus, error: NSError!) in
            if (status == .Available) {
                self.container.fetchUserRecordIDWithCompletionHandler { (recordId: CKRecordID!, error: NSError!) in
                    if let err = error {
                        completion(user: nil, error: err)
                    } else {
                        println("recordId: \(recordId)\trecord name:\(recordId.recordName)")
                        
                        self.currentUser = User(recordId: recordId)
                        completion(user: self.currentUser, error: nil)
                    }
                }
            } else {
                completion(user: nil, error: error)
            }
        }
    }
    
    // MARK: - Messages
    
    func getMessages(chatRoom: ChatRoom, completion: ((messages: Array<Message>!, error: NSError!) -> (Void))) {
        let predicate = NSPredicate(format: "chatRoom == %@", chatRoom.record!)
        let query = CKQuery(recordType: "Message", predicate: predicate)
        
        self.publicDatabase.performQuery(query, inZoneWithID: nil) { (result: AnyObject[]!, error: NSError!) in
            println(result)
            println(error)
            
            if error == nil {
                var messages = Array<Message>()
                for (record: CKRecord) in result as Array<CKRecord> {
                    let message = Message(record: record)
                    messages.append(message)
                }
                
                completion(messages: messages, error: nil)
            } else {
                completion(messages: nil, error: error)
            }
        }
    }
    
    func send(message: Message, chatRoom: ChatRoom, completion: ((message: Message!, error: NSError!) -> (Void)) ) {
        let messageRecord = message.getRecord(chatRoom)
        
        publicDatabase.saveRecord(messageRecord) { (record: CKRecord!, error: NSError!) in
            println(record)
            println(error)
            
            completion(message: message, error: error)
        }
    }
    
    // MARK: - Chat rooms
    
    func getChatRooms(completion: ((chatRooms: Array<ChatRoom>!, error: NSError!) -> (Void)) ) {
        if let user = currentUser {
            let predicate = NSPredicate(format: "%@ in users", user.recordId)
            let query = CKQuery(recordType: "ChatRoom", predicate: predicate)
            self.publicDatabase.performQuery(query, inZoneWithID: nil) { (result: AnyObject[]!, error: NSError!) in
                println(result)
                println(error)
                
                if error == nil {
                    var chatRooms = Array<ChatRoom>()
                    for (record: CKRecord) in result as Array<CKRecord> {
                        let chatRoom = ChatRoom(record: record)
                        chatRooms.append(chatRoom)
                    }
                    
                    completion(chatRooms: chatRooms, error: nil)
                } else {
                    completion(chatRooms: nil, error: error)
                }
            }
        } else {
            completion(chatRooms: nil, error: NSError(domain: CloudChatErrorDomain, code: CloudChatError.MissingUserRecord.toRaw(), userInfo: nil))
        }
    }
    
    func createChatRoom(name: String, completion: ((chatRoom: ChatRoom!, error: NSError!) -> (Void)) ) {
        findChatRoom(name) { (chatRoom: ChatRoom!, error: NSError!) in
            if chatRoom == nil {
                let chatRoom = ChatRoom(name: name)
                let chatRoomRecord = chatRoom.getRecord(self.currentUser!)
                
                self.publicDatabase.saveRecord(chatRoomRecord) { (record: CKRecord!, error: NSError!) in
                    println(record)
                    println(error)
                    
                    completion(chatRoom: chatRoom, error: error)
                }
            } else {
                completion(chatRoom: nil, error: NSError(domain: CloudChatErrorDomain, code: CloudChatError.ChatRoomWithProvidedNameExists.toRaw(), userInfo: nil))
            }
        }
    }
    
    func findChatRoom(name: String, completion: ((chatRoom: ChatRoom!, error: NSError!) -> (Void)) ) {
        let predicate = NSPredicate(format: "name = %@", name)
        let query = CKQuery(recordType: "ChatRoom", predicate: predicate)
        
        self.publicDatabase.performQuery(query, inZoneWithID: nil) { (result: AnyObject[]!, error: NSError!) in
            println(result.count)
            println(error)
            
            if error == nil {
                if result.count > 0 {
                    let record = result[0] as CKRecord
                    let chatRoom = ChatRoom(record: record)
                    
                    completion(chatRoom: chatRoom, error: nil)
                } else {
                    completion(chatRoom: nil, error: NSError(domain: CloudChatErrorDomain, code: CloudChatError.ChatRoomWithProvidedNameMissing.toRaw(), userInfo: nil))
                }
            } else {
                completion(chatRoom: nil, error: error)
            }
        }
    }
    
    func joinChatRoom(name: String, completion: ((chatRoom: ChatRoom!, error: NSError!) -> (Void)) ) {
        findChatRoom(name) { (chatRoom: ChatRoom!, error: NSError!) in
            if chatRoom != nil {
                // Join
            } else if (error.code == CloudChatError.ChatRoomWithProvidedNameMissing.toRaw()) {
                // create and join
            } else {
                // error
            }
        }
    }
}
