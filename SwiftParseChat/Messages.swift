//
//  Messages.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/21/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class Messages {
    class func startPrivateChat(user1: PFUser, user2: PFUser) -> String {
        let id1 = user1.objectId
        let id2 = user2.objectId
        
        let roomId = (id1 < id2) ? "\(id1)\(id2)" : "\(id2)\(id1)"
        
        createMessageItem(user1, roomId: roomId, description: user2[PF_USER_FULLNAME] as String)
        createMessageItem(user2, roomId: roomId, description: user1[PF_USER_FULLNAME] as String)
        
        return roomId
    }

    class func createMessageItem(user: PFUser, roomId: String, description: String) {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_USER, equalTo: user)
        query.whereKey(PF_MESSAGES_ROOMID, equalTo: roomId)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if objects.count == 0 {
                    var message = PFObject(className: PF_MESSAGES_CLASS_NAME)
                    message[PF_MESSAGES_USER] = user;
                    message[PF_MESSAGES_ROOMID] = roomId;
                    message[PF_MESSAGES_DESCRIPTION] = description;
                    message[PF_MESSAGES_LASTUSER] = PFUser.currentUser()
                    message[PF_MESSAGES_LASTMESSAGE] = "";
                    message[PF_MESSAGES_COUNTER] = 0
                    message[PF_MESSAGES_UPDATEDACTION] = NSDate()
                    message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                        if (error != nil) {
                            println("Messages.createMessageItem save error.")
                            println(error)
                        }
                    })
                }
            } else {
                println("Messages.createMessageItem save error.")
                println(error)
            }
        }
    }
    
    class func deleteMessageItem(message: PFObject) {
        message.deleteInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                println("UpdateMessageCounter save error.")
                println(error)
            }
        }
    }
    
    class func updateMessageCounter(roomId: String, lastMessage: String) {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_ROOMID, equalTo: roomId)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for message in objects as [PFObject]! {
                    var user = message[PF_MESSAGES_USER] as PFUser
                    if user.objectId == PFUser.currentUser().objectId {
                        message.incrementKey(PF_MESSAGES_COUNTER) // Increment by 1
                        message[PF_MESSAGES_LASTUSER] = PFUser.currentUser()
                        message[PF_MESSAGES_LASTMESSAGE] = lastMessage
                        message[PF_MESSAGES_UPDATEDACTION] = NSDate()
                        message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                            if error != nil {
                                println("UpdateMessageCounter save error.")
                                println(error)
                            }
                        })
                    }
                }
            } else {
                println("UpdateMessageCounter save error.")
                println(error)
            }
        }
    }
    
    class func clearMessageCounter(roomId: String) {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        
    }
//    //-------------------------------------------------------------------------------------------------------------------------------------------------
//    void ClearMessageCounter(NSString *roomId)
//    //-------------------------------------------------------------------------------------------------------------------------------------------------
//    {
//    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
//    [query whereKey:PF_MESSAGES_ROOMID equalTo:roomId];
//    [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//    {
//    if (error == nil)
//    {
//    for (PFObject *message in objects)
//    {
//				message[PF_MESSAGES_COUNTER] = @0;
//				[message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//				{
//    if (error != nil) NSLog(@"ClearMessageCounter save error.");
//				}];
//    }
//    }
//    else NSLog(@"ClearMessageCounter query error.");
//    }];
//    }

}
