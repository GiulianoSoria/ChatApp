//
//  Photo.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Foundation
import RealmSwift

@objcMembers class Photo: EmbeddedObject, ObjectKeyIdentifiable {
  dynamic var _id = UUID().uuidString
  dynamic var thumbNail: Data?
  dynamic var picture: Data?
  dynamic var date = Date()
}
