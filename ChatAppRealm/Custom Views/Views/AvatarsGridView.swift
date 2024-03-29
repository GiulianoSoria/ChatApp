//
//  AvatarsGridView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-06.
//

import RealmSwift
import UIKit

protocol AvatarsGridViewDelegate: AnyObject {
  func showChatsterViewController(chatster: Chatster)
}

class AvatarsGridView: UIView {
	private var state: AppState!
  private var chatstersRealmNotificationToken: NotificationToken!
  private var conversation: Conversation!
  private var chatsters: Results<Chatster>!
  private var chatstersArray: [Chatster] = []
  
  weak var delegate: AvatarsGridViewDelegate!
  
  enum Section { case main }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, Chatster>!
  
  private var isCompact: Bool = true
  
  convenience init(
		state: AppState,
		conversation: Conversation,
		chatsters: Results<Chatster>,
		isCompact: Bool
	) {
    self.init(frame: .zero)
		self.state = state
    self.chatsters = chatsters
    self.conversation = conversation
    self.chatstersArray = getChatsters(chatsters)
    self.isCompact = isCompact
    
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
    collectionView.backgroundColor = .secondarySystemBackground // : .systemBackground
    collectionView.showsHorizontalScrollIndicator = false
    
    collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: AvatarCell.reuseID)
//    collectionView.delegate = self
  }
  
  private func createLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(40), heightDimension: .absolute(40))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.interGroupSpacing = 10
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Chatster>(
			collectionView: collectionView
		) { collectionView, indexPath, chatster in
      guard
        let cell = collectionView.dequeueReusableCell(
					withReuseIdentifier: AvatarCell.reuseID,
					for: indexPath
				) as? AvatarCell else { return nil }
      cell.set(
				chatster: chatster,
				cornerRadius: 20,
				online: chatster.presenceState == .onLine ? true : false
			)
      cell.delegate = self
      
      return cell
    }
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
    let chatstersToReload = getChatstersToReload(oldChatsters: self.chatsters,
                                                 newChatsters: chatsters)
    snapshot.reloadItems(chatstersToReload)

    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func getChatsters(_ chatsters: Results<Chatster>) -> [Chatster] {
    var array = Array(chatsters)
		let names = conversation.members.map({ $0.userName })
		array.removeAll(where: { !names.contains($0.userName) })
		array.removeAll(where: { $0.userName == state.user!.userName })
		
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
    chatstersRealmNotificationToken = chatsters
			.thaw()?
			.observe { [weak self] result in
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

extension AvatarsGridView: AvatarCellDelegate {
  func showChatsterViewController(chatster: Chatster) {
    delegate.showChatsterViewController(chatster: chatster)
  }
}
