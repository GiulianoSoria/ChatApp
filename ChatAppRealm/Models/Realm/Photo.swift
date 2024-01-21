//
//  Photo.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

//@objcMembers 
class Photo: EmbeddedObject, ObjectKeyIdentifiable {
	@Persisted var _id = UUID().uuidString
	@Persisted var thumbNail: Data?
	@Persisted var picture: Data?
	@Persisted var date = Date()
}
