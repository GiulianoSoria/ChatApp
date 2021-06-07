//
//  ChatroomViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-06.
//

import RealmSwift
import UIKit

class ChatroomViewController: UIViewController {
  private var state: AppState!
  private var conversationRealm: Realm!
  private var conversation: Conversation!
  private var chatsters: [Chatster] = []
  private var messages: Results<ChatMessage>!
  private var realmChatNotificationToken: NotificationToken!
  
  enum Section { case main }
  
  private let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first
  private lazy var tabBarHeight = tabBarController?.tabBar.frame.height ?? 83
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, ChatMessage>!
  private var composerView: MessageComposerView!
  
  
  init(state: AppState, conversation: Conversation, chatsters: Results<Chatster>) {
    super.init(nibName: nil, bundle: nil)
    self.state = state
    self.conversation = conversation
    self.chatsters.append(contentsOf: chatsters)
    self.fetchConversation(conversation: conversation)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    closeConversation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
    configureCollectionView()
    configureDataSource()
    hideKeyboardWhenTappedAround()
    createKeyboardAppearanceNotification()
  }
  
  private func configureViewController() {
    title = conversation.displayName
    view.backgroundColor = .systemBackground
  }
  
  private func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    view.addSubview(collectionView)
    collectionView.pinToEdges(of: view)
    collectionView.backgroundColor = .systemBackground

    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
    collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
    
    collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseID)
  }
  
  private func createLayout() -> UICollectionViewCompositionalLayout {
    let estimatedHeight = CGFloat(100)
    let layoutSize = NSCollectionLayoutSize(widthDimension: .estimated(view.frame.width), heightDimension: .estimated(estimatedHeight))
    let item = NSCollectionLayoutItem(layoutSize: layoutSize)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitem: item, count: 1)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, ChatMessage>(collectionView: collectionView) { [weak self] collectionView, indexPath, message in
      guard let self = self else { return nil }
      guard
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCell.reuseID,
                                                      for: indexPath) as? MessageCell else { return nil }
      cell.set(chatster: self.chatsters.first(where: { $0.userName == message.author }),
               message: message,
               isMyMessage: message.author == self.state.user?.userName,
               isMediaShown: message.image != nil || !message.location.isEmpty ? true : false)
      return cell
    }
  }
  
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, ChatMessage>()
    snapshot.appendSections([.main])
    snapshot.appendItems(Array(messages))
    
    dataSource.apply(snapshot)
  }
  
  private func configureMessageComposerView() {
    composerView = MessageComposerView(state: state,
                                       conversationRealm: conversationRealm,
                                       conversation: conversation)
    view.addSubview(composerView)
    view.bringSubviewToFront(composerView)
    
    NSLayoutConstraint.activate([
      composerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      composerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      composerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      composerView.heightAnchor.constraint(greaterThanOrEqualToConstant: tabBarHeight)
    ])
  }
  
  private func scrollToBottom(animated: Bool) {
    collectionView.scrollToItem(at: IndexPath(item: messages.count - 1, section: 0),
                                at: .bottom,
                                animated: animated)
  }
  
  private func fetchConversation(conversation: Conversation) {
    let config = state.app.currentUser!.configuration(partitionValue: "conversation=\(conversation.id)")
    Realm.asyncOpen(configuration: config)
      .sink { completion in
        switch completion {
        case .failure(let error):
          print(error.localizedDescription)
        case .finished:
          break
        }
      } receiveValue: { realm in
        self.conversationRealm = realm
        let messages = realm.objects(ChatMessage.self).sorted(byKeyPath: "timestamp", ascending: true)
        self.messages = messages
        self.configureMessageComposerView()
        self.applySnapshot()
        self.scrollToBottom(animated: false)
        self.createObserver()
      }
      .store(in: &state.subscribers)
  }
  
  private func createObserver() {
     realmChatNotificationToken = messages.thaw()?.observe { [weak self] changes in
      guard let self = self else { return }
      switch changes {
      case .error(let error):
        print(error.localizedDescription)
      case .update(let messages, deletions: _, insertions: _, modifications: _):
        self.messages = messages
        self.applySnapshot()
        self.scrollToBottom(animated: true)
        break
      default:
        break
      }
    }
    
    
  }
  
  private func closeConversation() {
    if
      let token = realmChatNotificationToken {
      token.invalidate()
    }
  }
  
  private func createKeyboardAppearanceNotification() {
    let notifications = [UIResponder.keyboardWillChangeFrameNotification, UIResponder.keyboardWillHideNotification]
    notifications.forEach { NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: $0, object: nil) }
  }
  
  @objc private func adjustForKeyboard(_ notification: NSNotification) {
    guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    
    let bottomSafeAreaInset = keyWindow?.safeAreaInsets.bottom ?? 34
    let bottomInset = -keyboardRect.height + bottomSafeAreaInset
    let items = [view]
    
    if notification.name == UIResponder.keyboardWillShowNotification ||  notification.name == UIResponder.keyboardWillChangeFrameNotification {
      items.forEach { $0?.frame.origin.y = bottomInset }
    } else {
      items.forEach { $0?.frame.origin.y = 0 }
    }
  }
}
