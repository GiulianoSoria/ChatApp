//
//  Conversation.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

class Conversation: EmbeddedObject, ObjectKeyIdentifiable {
	@Persisted var id = UUID().uuidString
	@Persisted var displayName = ""
	@Persisted var unreadCount = 0
	@Persisted var members = List<Member>()
}
