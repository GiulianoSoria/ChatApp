//
//  PersistenceManager.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-19.
//

import Foundation

class PersistenceManager {
  public static let shared = PersistenceManager()
  
  private var defaults = UserDefaults.standard
  
  enum Keys { static let preferences = "preferences" }
  
  public func retrieveUserPreferences(completed: @escaping (Result<Preferences, CAError>) -> Void) {
    guard
      let preferencesData = defaults.object(forKey: Keys.preferences) as? Data else {
        completed(
          .success(
            Preferences(
              isUserLoggedIn: false,
              isUserLocationShared: false,
              isPushNotificationEnabled: false)
          )
        )
      return
    }
    
    do {
      let decoder = JSONDecoder()
      let preferences = try decoder.decode(Preferences.self, from: preferencesData)
      completed(.success(preferences))
    } catch {
      completed(.failure(.unableToRetrievePreferences))
    }
  }
  
  public func save(_ preferences: Preferences) -> CAError? {
    do {
      let encoder = JSONEncoder()
      let encodedPreferences = try encoder.encode(preferences)
      defaults.set(encodedPreferences, forKey: Keys.preferences)
      return nil
    } catch {
      return .unableToSavePreferences
    }
  }
  
  public func updatePreferences(preference: Preferences,
                                types: [PersistenceActionType],
                                completed: @escaping (CAError?) -> Void) {
    retrieveUserPreferences { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completed(error)
      case .success(var preferences):
        types.forEach { type in
          switch type {
          case .isuserLoggedIn:
            preferences.isUserLoggedIn = preference.isUserLoggedIn
          case .isUserLocationShared:
            preferences.isUserLocationShared = preference.isUserLocationShared
          case .isPushNotificationsEnabled:
            preferences.isPushNotificationEnabled = preference.isPushNotificationEnabled
          }          
        }
        
        completed(self.save(preferences))
      }
    }
  }
}

enum PersistenceActionType: String {
  case isuserLoggedIn = "isUserLoggedIn"
  case isUserLocationShared = "isUserLocationShared"
  case isPushNotificationsEnabled = "isPushNotificationsEnabled"
}
