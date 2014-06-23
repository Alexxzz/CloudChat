//
//  Message.swift
//  CloudChat
//
//  Created by Alexander on 18/06/14.
//  Copyright (c) 2014 Alexander. All rights reserved.
//

import CloudKit

enum MessageKey: String
{
    case Text = "text"
    case ChatRoom = "chatRoom"
}

class Message
{
    var record: CKRecord?
    var text: String
    
    let tableName = "Message"
    
    init(record: CKRecord) {
        text = record.valueForKey(MessageKey.Text.toRaw()) as String
    }
    
    init(text: String) {
        self.text = text
    }
    
    func getRecord(chatRoom: ChatRoom) -> CKRecord {
        let chatRoomRef = CKReference(record: chatRoom.record, action: .None)
        
        if record == nil {
            record = CKRecord(recordType: tableName)
        }
        
        record!.setObject(text, forKey: MessageKey.Text.toRaw())
        record!.setObject(chatRoomRef, forKey: MessageKey.ChatRoom.toRaw())
        
        return record!
    }
}
