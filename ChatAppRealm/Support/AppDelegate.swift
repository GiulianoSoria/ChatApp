//
//  AppDelegate.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import RealmSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  public static var isUserLoggedIn: Bool = false
  public static var isUserLocationShared: Bool = false
  public static var isPushNotificationsEnabled: Bool = false

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    retrieveUserDefaults()
    
    return true
  }
  
  func retrieveUserDefaults() {
    PersistenceManager.shared.retrieveUserPreferences { result in
      switch result {
      case .failure(let error):
        if
          let view = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController?.view {
          UIHelpers.autoDismissableSnackBar(title: error.rawValue,
                                            image: SFSymbols.crossCircle,
                                            backgroundColor: .systemRed,
                                            textColor: .white,
                                            view: view)
        } else {
          print(error.rawValue)
        }
      case .success(let preferences):
        AppDelegate.isUserLoggedIn = preferences.isUserLoggedIn ?? false
        AppDelegate.isUserLocationShared = preferences.isUserLocationShared ?? false
        AppDelegate.isPushNotificationsEnabled = preferences.isPushNotificationEnabled ?? false
      }
    }
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}
