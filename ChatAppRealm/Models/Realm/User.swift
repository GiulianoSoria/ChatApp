//
//  User.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

class User: Object, ObjectKeyIdentifiable {
	@Persisted(primaryKey: true) var _id = UUID().uuidString
	@Persisted var userName = ""
	@Persisted var userPreferences: UserPreferences?
	@Persisted var lastSeenAt: Date?
	@Persisted var conversations = List<Conversation>()
	@Persisted var presence = "On-Line"
	
	var isProfileSet: Bool { !(userPreferences?.isEmpty ?? true) }
	var presenceState: Presence {
		get { return .init(rawValue: presence) ?? .hidden }
		set { presence = newValue.asString }
	}
	
	convenience init(userName: String, id: String) {
		self.init()
		self.userName = userName
		_id = id
		userPreferences = UserPreferences()
		userPreferences?.displayName = userName
		presence = "On-Line"
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
