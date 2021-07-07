//
//  Chatster.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

@objcMembers class Chatster: Object {
  dynamic var _id = UUID().uuidString // This will match the _id of the associated user
  dynamic var partition = "all-users=all-the-users"
  dynamic var userName = ""
  dynamic var displayName: String?
  dynamic var avatarImage: Photo?
  dynamic var lastSeenAt: Date?
  dynamic var presence = "Off-Line"
  
  var presenceState: Presence {
    get { return Presence(rawValue: presence) ?? .hidden }
    set { presence = newValue.asString }
  }
  
  override class func primaryKey() -> String? {
    return "_id"
  }
}
