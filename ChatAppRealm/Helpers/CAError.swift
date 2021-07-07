//
//  CAError.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-19.
//

import Foundation

enum CAError: String, Error {
  case unableToRetrievePreferences = "There was an error trying to retrieve your preferences. Please try again."
  case unableToSavePreferences = "There was an error trying to save your preferences. Please try again."
}
