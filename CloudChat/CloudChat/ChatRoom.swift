//
//  ChatRoom.swift
//  test
//
//  Created by Alexander on 18/06/14.
//  Copyright (c) 2014 Alexander. All rights reserved.
//

import CloudKit

enum ChatRoomKey: String
{
    case Name = "name"
    case Users = "users"
}

class ChatRoom
{
    let tableName = "ChatRoom"
    
    var name: String?
    
    var record: CKRecord?
    
    init(record: CKRecord) {
        self.record = record
    }
    
    init(name: String) {
        self.name = name
    }
    
    func getRecord(user: User) -> CKRecord {
        let userRef = CKReference(recordID: user.recordId, action: CKReferenceAction.None)
        
        if let rec = self.record {
            var users = rec.objectForKey(ChatRoomKey.Users.toRaw()) as Array<CKReference>
            let alreadyInChatroom = arrayContainsUser(users, user: userRef)
            if alreadyInChatroom == false  {
                users.append(userRef)
            }
        } else {
            self.record = CKRecord(recordType: tableName)
            self.record!.setObject(name, forKey: ChatRoomKey.Name.toRaw())
            self.record!.setObject([userRef], forKey: ChatRoomKey.Users.toRaw())
        }
        
        return self.record!
    }
    
    func arrayContainsUser(array: Array<CKReference>, user: CKReference) -> Bool {
        for (index, value) in enumerate(array) {
            if (value == user) {
                return true
            }
        }
        
        return false
    }
}
