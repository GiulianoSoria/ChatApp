//
//  ConversationsCollectionView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import RealmSwift
import UIKit

protocol ConversationsViewDelegate: AnyObject {
  func pushConversationViewController(_ conversation: Conversation, chatsters: Results<Chatster>)
}

class ConversationsView: UIView {
  private var state: AppState!
  private var chatstersRealm: Realm!
  private var conversations: Results<Conversation>!
  private var chatsters: Results<Chatster>!
  private var users: Results<User>!
  private var user: User!
  private var userConversationsNotificationToken: NotificationToken!
  
  weak var delegate: ConversationsViewDelegate!
  
  private var sortDescriptor = [
    SortDescriptor(keyPath: "unreadCount", ascending: false),
    SortDescriptor(keyPath: "displayName", ascending: true)
  ]
  
  enum Section { case conversations }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, Conversation>!
  
  
  init(state: AppState) {
    super.init(frame: .zero)
    self.state = state
    fetchUsers()
    configureView()
    configureCollectionView()
    configureDataSource()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureView() {
    backgroundColor = .systemBackground
  }
  
  private func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    addSubview(collectionView)
    collectionView.pinToEdges(of: self)
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    
    collectionView.register(ConversationCell.self, forCellWithReuseIdentifier: ConversationCell.reuseID)
  }
  
  private func createLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Conversation>(collectionView: collectionView) { [weak self] collectionView, indexPath, conversation in
      guard
        let self = self,
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConversationCell.reuseID,
                                                      for: indexPath) as? ConversationCell else {
        return nil
      }
      
      cell.set(state: self.state,
               conversation: conversation,
               chatstersRealm: self.chatstersRealm,
               chatsters: self.chatsters)
      
      return cell
    }
  }
  
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Conversation>()
    snapshot.appendSections([.conversations])
    snapshot.appendItems(Array(conversations))
    
    dataSource.apply(snapshot)
  }
  
  public func reloadCollectionView() {
    var snapshot = self.dataSource.snapshot()
    snapshot.deleteAllItems()
    
    snapshot.appendSections([.conversations])
    let conversations = Array(self.conversations.sorted(by: sortDescriptor))
    snapshot.appendItems(conversations)
    
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func fetchChatsters() {
    let config = state.app.currentUser!.configuration(partitionValue: "all-users=all-the-users")
    Realm.asyncOpen(configuration: config)
      .sink { completion in
        switch completion {
        case .failure(let error):
          print(error.localizedDescription)
        case .finished:
          break
        }
      } receiveValue: { [weak self] realm in
        guard let self = self else { return }
        self.chatstersRealm = realm
        self.chatsters = realm.objects(Chatster.self)
        self.applySnapshot()
      }
      .store(in: &state.subscribers)
  }
  
  private func fetchUsers() {
    let config = state.app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")")
    Realm.asyncOpen(configuration: config)
      .sink { _ in
      } receiveValue: { [weak self] realm in
        guard let self = self else { return }
        self.users = realm.objects(User.self)
        self.conversations = self.users[0].conversations.sorted(by: self.sortDescriptor)
        self.fetchChatsters()
        self.observeUserConversations()
      }
      .store(in: &state.subscribers)
  }
  
  private func observeUserConversations() {
    userConversationsNotificationToken = users.thaw()?.observe { result in
      switch result {
      case .error(let error):
        print(error.localizedDescription)
      case .update(let users, deletions: _, insertions: _, modifications: _):
        self.users = users
        self.reloadCollectionView()
      default:
        break
      }
    }
  }
}

extension ConversationsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let conversation = self.conversations[indexPath.item]
    delegate.pushConversationViewController(conversation, chatsters: self.chatsters)
  }
}
