//
//  RealmManager.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import Combine
import Foundation
import RealmSwift

class AppState {
  public static let shared = AppState()
  public let app = RealmSwift.App(id: "chatapp-jfsse")
  
  public var error: String?
  public var busyCount = 0
  
  var user: User?
  
  var loginPublisher = PassthroughSubject<RealmSwift.User, Error>()
  var logoutPublisher = PassthroughSubject<Void, Error>()
  var userRealmPublisher = PassthroughSubject<Realm, Error>()
  var subscribers = Set<AnyCancellable>()
  
  let updateUserProfile = Notification.Name(NotificationKeys.updateUserProfile)
  
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
  
  var loggedIn: Bool { app.currentUser != nil && user != nil && app.currentUser?.state == .loggedIn }
  
  init() {
    _ = app.currentUser?.logOut()
    initLoginPublisher()
    initLogoutPublisher()
    initUserRealmPublisher()
  }
  
  func initLoginPublisher() {
    loginPublisher
      .receive(on: DispatchQueue.main)
      .flatMap { user -> RealmPublishers.AsyncOpenPublisher in
        self.shouldIndicateActivity = true
        let realmConfig = user.configuration(partitionValue: "user=\(user.id)")
        return Realm.asyncOpen(configuration: realmConfig)
      }
      .receive(on: DispatchQueue.main)
      .map { return $0 }
      .subscribe(userRealmPublisher)
      .store(in: &subscribers)
  }
  
  func initUserRealmPublisher() {
    userRealmPublisher
      .sink { result in
        if case let .failure(error) = result {
          self.error = "Failed to log in and open user realm: \(error.localizedDescription)"
        }
      } receiveValue: { realm in
        print("User Realm file location: \(realm.configuration.fileURL!.path)")
        self.user = realm.objects(User.self).first
        
        do {
          try realm.write {
            self.user?.presenceState = .onLine
          }
        } catch {
          self.error = "Unable to open Realm write transaction"
        }
        self.shouldIndicateActivity = false
        NotificationCenter.default.post(name: self.updateUserProfile, object: nil)
      }
      .store(in: &subscribers)
  }
  
  func initLogoutPublisher() {
    logoutPublisher
      .receive(on: DispatchQueue.main)
      .sink { _ in
      } receiveValue: { _ in
        self.user = nil
      }
      .store(in: &subscribers)
  }
}
