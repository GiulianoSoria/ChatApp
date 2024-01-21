//
//  ConversationsListViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import RealmSwift
import UIKit

class ConversationsListViewController: UIViewController {
  private var state: AppState!

  private var users: Results<User>!
  private var userConversationsNotificationToken: NotificationToken!
  private var chatsters: Results<Chatster>!
  
  var shouldRemindOnlineUser = false
  var onlineUserReminderHours = 8
  
  private var showingProfileView = false
  public var isCompact: Bool = true
  
  enum Section { case conversations }
  
  var collectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, Conversation>!
  
	init(
		state: AppState,
		isCompact: Bool
	) {
    super.init(nibName: nil, bundle: nil)
    self.state = state
    self.isCompact = isCompact
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
  
  private func configureViewController() {
    title = "ChatAppRealm"
    view.backgroundColor = .systemBackground
  }
  
  private func checkUserState() {
		Task {
			do {
				let isUserLoggedIn = try PersistenceManager.shared.retrieveUserPreference(ofType: .isUserLoggedIn) as? Bool ?? false
				if isUserLoggedIn, state.loggedIn {
					if state.user == nil { try await state.automaticLogin() }
					if (state.user != nil) && !state.user!.isProfileSet || showingProfileView {
						createAvatarButton()
						createAddConversationButton()
						showAccountSettingsScreen()
					} else {
						createAvatarButton()
						createAddConversationButton()
						configureCollectionView()
					}
				} else {
					showLoginScreen()
				}
			} catch {
				showLoginScreen()
			}
		}
  }
  
  private func createAvatarButton() {
		let photo = state.user?.userPreferences?.avatarImage
		let imageView = ThumbnailView(
			photo: photo,
			cornerRadius: 15
		)
		imageView.delegate = self
		imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
		let avatarButton = UIBarButtonItem(customView: imageView)
		avatarButton.isEnabled = true
		navigationItem.setLeftBarButton(avatarButton, animated: true)
  }
  
  private func createAddConversationButton() {
    let addButton = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addButtonTapped)
		)
    
    navigationItem.rightBarButtonItem = addButton
  }
  
  @objc private func addButtonTapped() {
    let destVC = ChatroomCreationViewController(
			state: state,
			userRealm: state.realm
		)
    destVC.isModalInPresentation = true
    let navController = UINavigationController(rootViewController: destVC)
    present(navController, animated: true)
  }
  
  private func configureCollectionView() {
    let collectionView = ConversationsView(
			state: state,
			userRealm: state.realm,
			isCompact: isCompact
		)
    collectionView.delegate = self
    view.addSubview(collectionView)
    collectionView.pinToEdges(of: view)
  }
  
  internal func showLoginScreen() {
    let loginVC = LoginViewController(state: state)
    let navController = UINavigationController(rootViewController: loginVC)
    navController.modalPresentationStyle = .fullScreen
    navController.modalTransitionStyle = .crossDissolve
    present(navController, animated: true)
  }
  
  private func showAccountSettingsScreen() {
    let destVC = AccountSettingsViewController(
			state: state,
			userRealm: state.realm
		)
    destVC.delegate = self
    let navController = UINavigationController(rootViewController: destVC)
    navController.isModalInPresentation = true
    present(navController, animated: true)
  }
  
  private func createObservers() {
		let notifications: [Notification.Name] = [.updateUserProfile]
    
    notifications.forEach { NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleNotifications(_:)),
			name: $0,
			object: nil
		) }
  }
  
  @objc private func handleNotifications(_ notification: Notification) {
    switch notification.name {
		case .updateUserProfile:
//      if
//        let realm = notification.object as? Realm {
//        userRealm = realm
//      }
      checkUserState()
    default:
      break
    }
  }
}

// MARK: - Thumbnail View Delegate Methods
extension ConversationsListViewController: ThumbnailViewDelegate {
  func thumbnailTapped() {
    showAccountSettingsScreen()
  }
}

// MARK: - Conversations View Delegate Methods
extension ConversationsListViewController: ConversationsViewDelegate {
  func pushConversationViewController(
		_ conversation: Conversation,
		chatsters: Results<Chatster>
	) {
    let destVC = ChatroomViewController(
			state: state,
			userRealm: state.realm,
			conversation: conversation,
			chatsters: chatsters
		)
    
    if
      let splitViewController = self.splitViewController {
//      splitViewController.setViewController(destVC,
//                                            for: .secondary)
      splitViewController.showDetailViewController(
				destVC,
				sender: self
			)
    } else {
      navigationController?.pushViewController(
				destVC,
				animated: true
			)
    }
  }
  
  func showChatroomCreationViewController(
		for conversation: Conversation,
		chatsters: Results<Chatster>
	) {
    let destVC = ChatroomCreationViewController(
			state: state,
//			chatsters: chatsters,
			userRealm: state.realm
		)
    let members = conversation.members.map({ $0.userName })
    let chatstersInConversation = chatsters.filter({ members.contains($0.userName) })
    destVC.selected = Array(chatstersInConversation)
    destVC.conversation = conversation
    destVC.textField.text = conversation.displayName
    destVC.isUpdating = true
    destVC.isModalInPresentation = true
    let navController = UINavigationController(rootViewController: destVC)
    present(navController, animated: true)
  }
  
  func showChatsterViewController(chatster: Chatster) {
    let destVC = ChatsterViewController(chatster: chatster)
    let navController = UINavigationController(rootViewController: destVC)
    
    present(navController, animated: true)
  }
}

// MARK: - Account Settings View Controller Delegate Methods
extension ConversationsListViewController: AccountsSettingsViewControllerDelegate {
  func showLoginViewController() {
    view.subviews.forEach { $0.removeFromSuperview() }
    showLoginScreen()
  }
}
