//
//  ViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import RealmSwift
import UIKit

class ViewController: UIViewController {
  
  private var state: AppState!
  private var userRealm: Realm!
  var shouldRemindOnlineUser = false
  var onlineUserReminderHours = 8
  
  let updateUserProfile = Notification.Name(NotificationKeys.updateUserProfile)
  
  private var showingProfileView = false
  
  enum Section { case conversations }
  
  var collectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, Conversation>!
  
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
      if (state.user != nil) && !state.user!.isProfileSet || showingProfileView {
        createAvatarButton()
        showAccountSettingsScreen()
      } else {
        // Show conversations list
        createAvatarButton()
        configureCollectionView()
      }
    } else {
      showLoginScreen()
    }
  }
  
  private func createAvatarButton() {
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
  
  private func configureCollectionView() {
    if
      let conversationsList = state.user?.conversations {
      let collectionView = ConversationsView(state: state, conversations: Array(conversationsList))
      collectionView.delegate = self
      view.addSubview(collectionView)
      collectionView.pinToEdges(of: view)
    }
  }
  
  private func showLoginScreen() {
    let loginVC = LoginViewController(state: state)
    let navController = UINavigationController(rootViewController: loginVC)
    navController.modalPresentationStyle = .fullScreen
    navController.modalTransitionStyle = .crossDissolve
    self.show(navController, sender: self)
  }
  
  private func showAccountSettingsScreen() {
    let destVC = AccountSettingsViewController(state: state, userRealm: userRealm)
    let navController = UINavigationController(rootViewController: destVC)
    navController.isModalInPresentation = true
    self.show(navController, sender: self)
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
      if
        let realm = notification.object as? Realm {
        userRealm = realm
      }
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

extension ViewController: ConversationsViewDelegate {
  func pushConversationViewController(_ conversation: Conversation, chatsters: Results<Chatster>) {
    let destVC = ChatroomViewController(state: state, conversation: conversation, chatsters: chatsters)
    
    self.navigationController?.pushViewController(destVC, animated: true)
  }
}
