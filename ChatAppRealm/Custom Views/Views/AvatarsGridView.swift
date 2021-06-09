//
//  AvatarsGridView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-06.
//

import RealmSwift
import UIKit

class AvatarsGridView: UIView {
  private var chatstersRealmNotificationToken: NotificationToken!
  private var conversation: Conversation!
  private var chatsters: Results<Chatster>!
  private var chatstersArray: [Chatster] = []
  
  enum Section { case main }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, Chatster>!
  
  convenience init(conversation: Conversation, chatsters: Results<Chatster>) {
    self.init(frame: .zero)
    self.chatsters = chatsters
    self.conversation = conversation
    self.chatstersArray = getChatsters(chatsters)
    
    configure()
    observeChatstersRealm()
    configureCollectionView()
    configureDataSource()
    applySnapshot()
  }
  
  private func configure() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .systemBackground
  }
  
  private func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    addSubview(collectionView)
    collectionView.pinToEdges(of: self)
    collectionView.backgroundColor = .systemBackground
    
    collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: AvatarCell.reuseID)
  }
  
  private func createLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(40), heightDimension: .absolute(40))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.interGroupSpacing = 10
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Chatster>(collectionView: collectionView, cellProvider: { collectionView, indexPath, chatster in
      guard
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCell.reuseID,
                                                      for: indexPath) as? AvatarCell else { return nil }
      cell.set(chatster: chatster, cornerRadius: 20, online: chatster.presenceState == .onLine ? true : false)
      
      return cell
    })
  }
  
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Chatster>()
    snapshot.appendSections([.main])
    snapshot.appendItems(chatstersArray)
    
    dataSource.apply(snapshot)
  }
  
  public func reloadCollectionView(with chatsters: Results<Chatster>) {
    var snapshot = self.dataSource.snapshot()
    snapshot.reloadSections([.main])
    snapshot.reloadItems(getChatstersToReload(oldChatsters: self.chatsters,
                                              newChatsters: chatsters))
    
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func getChatsters(_ chatsters: Results<Chatster>) -> [Chatster] {
    var array = Array(chatsters)
    let names = conversation.members.map({ $0.userName })
    array.removeAll(where: { !names.contains($0.userName) })
    return array
  }
  
  private func getChatstersToReload(oldChatsters: Results<Chatster>,
                                    newChatsters: Results<Chatster>) -> [Chatster] {
    var index = 0
    var array: [Chatster] = []
    
    while index < oldChatsters.count {
      if oldChatsters[index] != newChatsters[index] {
        array.append(oldChatsters[index])
      }
      index += 1
    }
    
    self.chatsters = newChatsters
    return array
  }
  
  private func observeChatstersRealm() {
    chatstersRealmNotificationToken = chatsters.thaw()?.observe { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .error(let error):
        print(error.localizedDescription)
      case .update(let chatsters, deletions: _, insertions: _, modifications: _):
        self.reloadCollectionView(with: chatsters)
      default:
        break
      }
    }
  }
}
