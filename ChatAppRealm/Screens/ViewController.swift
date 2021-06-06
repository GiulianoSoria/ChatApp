//
//  ViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import UIKit

class ViewController: UIViewController {
  
  private var state: AppState!
  var shouldRemindOnlineUser = false
  var onlineUserReminderHours = 8
  
  let updateUserProfile = Notification.Name(NotificationKeys.updateUserProfile)
  
  private var showingProfileView = false
  
  init(state: AppState) {
    super.init(nibName: nil, bundle: nil)
    self.state = state
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createObservers()
    checkUserState()
    configureViewController()
  }
  
  func configureViewController() {
    title = "ChatAppRealm"
    view.backgroundColor = .systemBackground
  }
  
  private func checkUserState() {
    if state.loggedIn {
      if (state.user != nil) && state.user!.isProfileSet || showingProfileView {
        // Show setup profile view
        createAvatarButton()
        showAccountSettingsScreen()
      } else {
        // Show conversations list
        createAvatarButton()
      }
    } else {
      // Show login screen
      let loginVC = LoginViewController(state: state)
      let navController = UINavigationController(rootViewController: loginVC)
      navController.modalPresentationStyle = .fullScreen
      navController.modalTransitionStyle = .crossDissolve
      self.show(navController, sender: self)
    }
  }
  
  func createAvatarButton() {
    if
      let photo = state.user?.userPreferences?.avatarImage {
      let imageView = ThumbnailView(frame: .zero)
      imageView.delegate = self
      imageView.set(photo: photo)
      imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
      imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
      let avatarButton = UIBarButtonItem(customView: imageView)
      avatarButton.isEnabled = true
      navigationItem.setRightBarButton(avatarButton, animated: true)
    }
  }
  
  func showAccountSettingsScreen() {
    let destVC = AccountSettingsViewController(user: state.user!)
    let navController = UINavigationController(rootViewController: destVC)
    navController.isModalInPresentation = true
    self.show(navController, sender: self)
  }
  
  func addNotification(timeInHours: Int) {
    let center = UNUserNotificationCenter.current()
    
    let addRequest = { [self] in
      let content = UNMutableNotificationContent()
      content.title = "Still logged in"
      content.subtitle = "You have been offline in the background for " + "\(onlineUserReminderHours) \(onlineUserReminderHours == 1 ? "hour" : "hours")"
      content.sound = .default
      
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(onlineUserReminderHours * 3600), repeats: false)
      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
      
      center.add(request)
    }
    
    center.getNotificationSettings { settings in
      if settings.authorizationStatus == .authorized {
        addRequest()
      } else {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
          if success {
            addRequest()
          }
        }
      }
    }
  }
  
  func clearNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllDeliveredNotifications()
    center.removeAllPendingNotificationRequests()
  }
  
  private func createObservers() {
    let notifications = [updateUserProfile]
    
    notifications.forEach { NotificationCenter.default.addObserver(self,
                                                                   selector: #selector(handleNotifications(_:)),
                                                                   name: $0,
                                                                   object: nil) }
  }
  
  @objc private func handleNotifications(_ notification: Notification) {
    switch notification.name {
    case updateUserProfile:
      checkUserState()
    default:
      break
    }
  }
}

extension ViewController: ThumbnailViewDelegate {
  func thumbnailTapped() {
    showAccountSettingsScreen()
  }
}
