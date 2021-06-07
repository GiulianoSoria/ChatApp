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
  private var chatsters: Results<Chatster>!
  
  weak var delegate: ConversationsViewDelegate!
  
  enum Section { case conversations }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, Conversation>!
  
  private var user: User!
  private var conversations: [Conversation] = []
  
  private var sortDescriptor = [
    SortDescriptor(keyPath: "unreadCount", ascending: false),
    SortDescriptor(keyPath: "displayName", ascending: true)
  ]
  
  init(state: AppState, conversations: [Conversation]) {
    super.init(frame: .zero)
    self.state = state
    self.conversations = conversations
    fetchChatsters()
    configureCollectionView()
    configureDataSource()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configure() {
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
               chatsters: self.chatsters)
      
      return cell
    }
  }
  
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Conversation>()
    snapshot.appendSections([.conversations])
    snapshot.appendItems(conversations)
    
    dataSource.apply(snapshot)
  }
  
  private func fetchChatsters() {
    UIHelpers.showSnackBar(title: "Fetching Conversations",
                           backgroundColor: .secondarySystemBackground,
                           view: self)
    let config = state.app.currentUser!.configuration(partitionValue: "all-users=all-the-users")
    Realm.asyncOpen(configuration: config)
      .sink { completion in
        switch completion {
        case .failure(let error):
          UIHelpers.hideSnackBar(title: "Fetching Conversations",
                                 backgroundColor: .secondarySystemBackground,
                                 view: self)
          print(error.localizedDescription)
        case .finished:
          break
        }
      } receiveValue: { realm in
        self.chatsters = realm.objects(Chatster.self)
        self.applySnapshot()
        UIHelpers.hideSnackBar(title: "Fetching Conversations",
                               backgroundColor: .secondarySystemBackground,
                               view: self)
      }
      .store(in: &state.subscribers)
  }
}

extension ConversationsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let conversation = self.conversations[indexPath.item]
    delegate.pushConversationViewController(conversation, chatsters: self.chatsters)
  }
}
