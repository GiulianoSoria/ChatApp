//
//  RealmManager.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Combine
import Foundation
import RealmSwift

@MainActor
class AppState {
  public static let shared = AppState()
  public let app = RealmSwift.App(id: "chatapprealm-xqbxd")
	
	private let keychain = KeychainManager()
  
  public var error: String?
  public var busyCount = 0
  
  var user: User?
	var realm: Realm!
	var chatsters: Results<Chatster>!
  
//  var loginPublisher = PassthroughSubject<RealmSwift.User, Error>()
//  var logoutPublisher = PassthroughSubject<Void, Error>()
//  var userRealmPublisher = PassthroughSubject<Realm, Error>()
  var subscribers = Set<AnyCancellable>()
  
  var shouldIndicateActivity: Bool {
    get { return busyCount > 0 }
    
    set(newState) {
      if newState {
        busyCount += 1
      } else {
        if busyCount > 0 {
          busyCount -= 1
        } else {
          print("Attempted to decrement busy count below 1")
        }
      }
    }
  }
  
  var loggedIn: Bool { app.currentUser != nil && app.currentUser?.state == .loggedIn }
  
	init() {
		do {
			let isUserLoggedIn = try PersistenceManager.shared.retrieveUserPreference(
				ofType: .isUserLoggedIn
			) as? Bool ?? false
			
			if !isUserLoggedIn {
				Task {
					try await logout()
				}
			}
		} catch {
			Task {
				try await logout()
			}
		}
  }
	
	@discardableResult
	public func login(
		email: String,
		password: String
	) async throws -> RealmSwift.User {
		let user = try await app.login(
			credentials: .emailPassword(
				email: email,
				password: password
			)
		)
		
		try keychain.saveItems([
			(.email, email),
			(.password, password)
		])
		
		try await initializeUserRealm(forUser: user)
		try await initializeChatsterRealm()
		
		return user
	}
	
	public func automaticLogin() async throws {
		guard let email = try keychain.getItem(withKey: .email),
					let password = try keychain.getItem(withKey: .password) else {
			throw NSError(domain: "com.gcsoriap.ChatAppRealm", code: -2)
		}
		
		try await login(email: email, password: password)
	}
	
	public func logout() async throws {
		shouldIndicateActivity = true
		
		do {
			if let realm {
				try realm.write {
					user?.presenceState = .offLine
				}
			}
			
			try await app.currentUser?.logOut()
			
			try PersistenceManager.shared.updatePreferences(
				preference: .init(isUserLoggedIn: false),
				types: [.isUserLoggedIn]
			)
			
			user = nil
			shouldIndicateActivity = false
		} catch {
			shouldIndicateActivity = false
			self.error = "Unable to open Realm write transaction"
			throw error
		}
	}
	
	private func initializeUserRealm(
		forUser user: RealmSwift.User
	) async throws {
		let config = user.flexibleSyncConfiguration { subs in
			subs.append(QuerySubscription<User> {
				$0._id == user.id
			})
		}
		
		realm = try await Realm(
			configuration: config,
			downloadBeforeOpen: .always
		)
		
//		debugPrint("User Realm file location: \(userRealm.configuration.fileURL!.path)")
		self.user = realm.objects(User.self).first
		
		try realm.write {
			self.user?.presenceState = .onLine
		}
		
		shouldIndicateActivity = false
	}
	
	public func initializeChatsterRealm() async throws {
		let subs = realm.subscriptions
		
		try await subs.update {
			if let currentSubs = subs.first(named: "all-chatsters") {
				currentSubs.updateQuery(toType: Chatster.self) {
					$0.userName != ""
				}
			} else {
				subs.append(QuerySubscription<Chatster>(name: "all-chatsters") {
					$0.userName != ""
				})
			}
		}
		
		chatsters = realm.objects(Chatster.self)
	}
	
	public func getMessages(of conversation: Conversation) async throws -> Results<ChatMessage> {
		let subs = realm.subscriptions
		
		try await subs.update {
			if let currentSubs = subs.first(named: "conversation") {
				currentSubs.updateQuery(toType: ChatMessage.self) {
					$0.conversationID == conversation.id
				}
			} else {
				subs.append(QuerySubscription<ChatMessage>(name: "conversation") {
					$0.conversationID == conversation.id
				})
			}
		}
		
		return realm
			.objects(ChatMessage.self)
			.sorted(
				byKeyPath: "timestamp",
				ascending: true
			)
	}
	
	func fetchUsers() async throws -> Results<User> {
		let config = app.currentUser!.flexibleSyncConfiguration { subs in
			subs.append(QuerySubscription<User> {
				$0._id != ""
			})
		}
		
		let realm = try await Realm(
			configuration: config,
			downloadBeforeOpen: .always
		)
		
		let users = realm.objects(User.self)
		
		return users
	}
}
