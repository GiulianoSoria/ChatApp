//
//  Chatster.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

class Chatster: Object, ObjectKeyIdentifiable {
	@Persisted(primaryKey: true) var _id = UUID().uuidString // This will match the _id of the associated User
	@Persisted var userName = ""
	@Persisted var displayName: String?
	@Persisted var avatarImage: Photo?
	@Persisted var lastSeenAt: Date?
	@Persisted var presence = "Off-Line"
	
	var presenceState: Presence {
		get { return .init(rawValue: presence) ?? .hidden }
		set { presence = newValue.asString }
	}
}
