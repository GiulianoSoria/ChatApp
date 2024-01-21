//
//  UserPreferences.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

//@objcMembers 
class UserPreferences: EmbeddedObject, ObjectKeyIdentifiable {
	@Persisted var displayName: String?
	@Persisted var avatarImage: Photo?
	
	var isEmpty: Bool { displayName == nil || displayName == "" }
//  dynamic var displayName: String?
//  dynamic var avatarImage: Photo?
//  
//  var isEmpty: Bool { displayName == nil || displayName == "" }
}
