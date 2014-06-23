//
//  User.swift
//  CloudChat
//
//  Created by Alexander on 18/06/14.
//  Copyright (c) 2014 Alexander. All rights reserved.
//

import CloudKit

enum UserKey: String {
    case ChatRooms = "chatRooms"
}

class User
{
    var chatRooms: Array<ChatRoom>?
    let recordId: CKRecordID
    
    init(recordId: CKRecordID) {
        self.recordId = recordId
    }
}