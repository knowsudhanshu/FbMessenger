//
//  FriendsControllerHelper.swift
//  fbMessanger
//
//  Created by Sudhanshu Sudhanshu on 4/8/18.
//  Copyright © 2018 Sudhanshu. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController {
    
    func clearData () {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let persistentContainer = appDelegate?.persistentContainer {
            let context = persistentContainer.viewContext
            
            do {
               
                let entityNames = ["Friend", "Message"]
                for entityName in entityNames {
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
                    for object in objects! {
                        context.delete(object)
                    }

                }
                try context.save()
            }catch let err {
                print("clearDate err: \(err)")
            }
        }
    }
    func setupData() {
        clearData()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let persistentContainer = appDelegate?.persistentContainer {
            let context = persistentContainer.viewContext
            
            createSteveMessage(context)
            
            let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            donald.name = "Donald Trump"
            donald.profileImageName = "donald_trump_profile"
            _ = FriendsController.createMessate("You are fired", friend: donald, minutesAgo: 5, context: context)
            
            
            let gandhi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            gandhi.name = "Mahatma Gandhi"
            gandhi.profileImageName = "gandhi"
            _ = FriendsController.createMessate("Peace, love and joy", friend: gandhi, minutesAgo: 60 * 24, context: context)
            
            
            let hillary = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            hillary.name = "Hillary Clinton"
            hillary.profileImageName = "hillary_profile"
            _ = FriendsController.createMessate("Hi guys, please vote for me, as you voted for Billy.", friend: hillary, minutesAgo: 8 * 60 * 24, context: context)
            
            do {
                try context.save()
            }catch let err {
                print(err)
            }
            loadData()
        }
    }
    
    private func createSteveMessage(_ context: NSManagedObjectContext) {
        
        let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        _ = FriendsController.createMessate("Good morning", friend: steve, minutesAgo: 3, context: context)
        _ = FriendsController.createMessate("How are you?", friend: steve, minutesAgo: 2, context: context)
        _ = FriendsController.createMessate("Are you interested in buying an Apple product? Apple creates awesome iOS devices for you guys. Are you interested in buying an Apple product? Apple creates awesome iOS devices for you guys.", friend: steve, minutesAgo: 1, context: context)
        
        // response message
        _ = FriendsController.createMessate("Yes, I am looking forward for buying an iPhone.", friend: steve, minutesAgo: 1, context: context, isSender: true)
        
    }
    
    static func createMessate(_ text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender : Bool = false) -> Message {
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = Date().addingTimeInterval(-minutesAgo * 60)
        message.isSender = isSender
        friend.lastMessage = message
        
        return message
    }
    
    func loadData () {
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        if let persistentContainer = appDelegate?.persistentContainer {
//            let context = persistentContainer.viewContext
//            
//            if let friends = fetchFriends(context) {
//                messages = [Message]()
//                for friend in friends {
//                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
//                    fetchRequest.fetchLimit = 1
//                    do {
//                        let fetchedMessages = try context.fetch(fetchRequest) as? [Message]
//                        messages?.append(contentsOf: fetchedMessages!)
//                    }catch let err {
//                        print("fetchRequest err: \(err)")
//                    }
//                }
//                messages = messages?.sorted(by: {
//                    $0.date!.compare($1.date!) == .orderedDescending
//                })
//            }
//            
//        }
    }
    
    private func fetchFriends(_ context: NSManagedObjectContext) -> [Friend]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        do {
            return try context.fetch(fetchRequest) as? [Friend]
        }catch let err {
            print("fetchFriends -> \(err)")
        }
        return nil
    }
}
