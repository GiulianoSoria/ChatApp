//
//  Preferences.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-19.
//

import Foundation

struct Preferences: Codable, Hashable {
  var isUserLoggedIn                : Bool?
  var isUserLocationShared          : Bool?
  var isPushNotificationEnabled     : Bool?
}
