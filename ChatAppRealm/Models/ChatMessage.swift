//
//  ChatMessage.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

@objcMembers class ChatMessage: Object, ObjectKeyIdentifiable {
  dynamic var _id = UUID().uuidString
  dynamic var partition = "" // "conversation=<conversation-id>"
  dynamic var author: String? // username
  dynamic var text = ""
  dynamic var image: Photo?
  let location = List<Double>()
  dynamic var timestamp = Date()
  
  override class func primaryKey() -> String? {
    return "_id"
  }
  
  convenience init(author: String, text: String, image: Photo?, location: [Double] = []) {
    self.init()
    self.author = author
    self.text = text
    self.image = image
    location.forEach { coord in
      self.location.append(coord)
    }
  }
  
  var conversationId: String {
    get { partition.components(separatedBy: "=")[1] }
    set(conversationId) { partition = "conversation=\(conversationId)" }
  }
}

extension ChatMessage: Identifiable {
  var id: String { _id }
}
