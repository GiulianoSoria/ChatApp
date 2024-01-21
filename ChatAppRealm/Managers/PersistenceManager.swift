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
  
	private init() {}
	
	public func retreiveUserPreferences() throws -> Preferences {
		guard let data = defaults.object(forKey: Keys.preferences) as? Data else {
			return .init(
				isUserLoggedIn: false,
				isUserLocationShared: false,
				isPushNotificationEnabled: false
			)
		}
		
		do {
			let decoder = JSONDecoder()
			let preferences = try decoder.decode(Preferences.self, from: data)
			return preferences
		} catch let error as NSError {
			throw error
		}
	}
	
	public func retrieveUserPreference(ofType type: PersistenceActionType) throws -> Any {
		guard let data = defaults.object(forKey: Keys.preferences) as? Data else {
			throw NSError(domain: "com.gcsoriap.ChatAppRealm", code: -1)
		}
		
		do {
			let decoder = JSONDecoder()
			let preferences = try decoder.decode(Preferences.self, from: data)
			
			switch type {
			case .isUserLoggedIn:
				return preferences.isUserLoggedIn ?? false
			case .isUserLocationShared:
				return preferences.isUserLocationShared ?? false
			case .isPushNotificationsEnabled:
				return preferences.isPushNotificationEnabled ?? false
			}
		} catch {
			throw error
		}
	}
  
	@discardableResult
  private func save(_ preferences: Preferences) throws -> CAError? {
    do {
      let encoder = JSONEncoder()
      let encodedPreferences = try encoder.encode(preferences)
      defaults.set(encodedPreferences, forKey: Keys.preferences)
      return nil
    } catch {
      throw error
    }
  }
	
	public func updatePreferences(
		preference: Preferences,
		types: [PersistenceActionType]
	) throws {
		do {
			var preferences = try retreiveUserPreferences()
			
			types.forEach { type in
				switch type {
				case .isUserLoggedIn:
					preferences.isUserLoggedIn = preference.isUserLoggedIn
				case .isUserLocationShared:
					preferences.isUserLocationShared = preference.isUserLocationShared
				case .isPushNotificationsEnabled:
					preferences.isPushNotificationEnabled = preference.isPushNotificationEnabled
				}
			}
			
			try save(preferences)
		} catch {
			throw error
		}
	}
  
//  public func updatePreferences(preference: Preferences,
//                                types: [PersistenceActionType],
//                                completed: @escaping (CAError?) -> Void) {
//    retrieveUserPreferences { [weak self] result in
//      guard let self = self else { return }
//      switch result {
//      case .failure(let error):
//        completed(error)
//      case .success(var preferences):
//        types.forEach { type in
//          switch type {
//          case .isuserLoggedIn:
//            preferences.isUserLoggedIn = preference.isUserLoggedIn
//          case .isUserLocationShared:
//            preferences.isUserLocationShared = preference.isUserLocationShared
//          case .isPushNotificationsEnabled:
//            preferences.isPushNotificationEnabled = preference.isPushNotificationEnabled
//          }          
//        }
//        
//        completed(self.save(preferences))
//      }
//    }
//  }
}

enum PersistenceActionType: String {
  case isUserLoggedIn = "isUserLoggedIn"
  case isUserLocationShared = "isUserLocationShared"
  case isPushNotificationsEnabled = "isPushNotificationsEnabled"
}
