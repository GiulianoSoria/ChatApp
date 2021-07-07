//
//  Conversation.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

@objcMembers class Conversation: EmbeddedObject, ObjectKeyIdentifiable {
  dynamic var id = UUID().uuidString
  dynamic var displayName = ""
  dynamic var unreadCount = 0
  let members = List<Member>()
}
