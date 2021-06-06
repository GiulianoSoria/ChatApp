//
//  User.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

@objcMembers class User: Object, ObjectKeyIdentifiable {
  dynamic var _id = UUID().uuidString
  dynamic var partition = "" // "user=_id"
  dynamic var userName = ""
  dynamic var userPreferences: UserPreferences?
  dynamic var lastSeenAt: Date?
  let conversations = List<Conversation>()
  dynamic var presence = "Off-Line"
  
  var isProfileSet: Bool { !(userPreferences?.isEmpty ?? true) }
  var presenceState: Presence {
    get { return Presence(rawValue: presence) ?? .hidden }
    set { presence = newValue.asString }
  }
  
  override class func primaryKey() -> String? {
    return "_id"
  }
}

enum Presence: String {
  case onLine = "On-Line"
  case offLine = "Off-Line"
  case hidden = "Hidden"
  
  var asString: String {
    self.rawValue
  }
}
