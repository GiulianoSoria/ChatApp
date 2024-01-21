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
  func showChatroomCreationViewController(for conversation: Conversation, chatsters: Results<Chatster>)
  func showChatsterViewController(chatster: Chatster)
}

class ConversationsView: UIView {
  private var state: AppState!
  private var userRealm: Realm!

  private var conversations: Results<Conversation>!
  private var users: Results<User>!
  private var userConversationsNotificationToken: NotificationToken!
  
  weak var delegate: ConversationsViewDelegate!
  
  private var sortDescriptor = [
    SortDescriptor(keyPath: "unreadCount", ascending: false),
    SortDescriptor(keyPath: "displayName", ascending: true)
  ]
  
  private enum Section { case conversations }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, Conversation>!
  
  public var isCompact: Bool = true
  
  init(state: AppState, userRealm: Realm, isCompact: Bool) {
    super.init(frame: .zero)
    self.state = state
    self.userRealm = userRealm
    self.isCompact = isCompact
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
    var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    configuration.backgroundColor = .systemBackground
    configuration.leadingSwipeActionsConfigurationProvider = { indexPath -> UISwipeActionsConfiguration? in
      let editActionHandler: UIContextualAction.Handler = { [weak self] action, view, completed in
        guard let self = self else { return }
        let conversation = self.conversations[indexPath.item]
        self.delegate.showChatroomCreationViewController(
					for: conversation,
					chatsters: self.state.chatsters
				)
        completed(true)
      }
      let editAction = UIContextualAction(style: .normal,
                                          title: "Edit",
                                          handler: editActionHandler)
      editAction.backgroundColor = .systemBlue
      editAction.image = .edit
      let configuration = UISwipeActionsConfiguration(actions: [editAction])
      
      return configuration
    }
    
    configuration.trailingSwipeActionsConfigurationProvider = { indexPath -> UISwipeActionsConfiguration? in
      let leaveActionHandler: UIContextualAction.Handler = { [weak self] action, view, completed in
        guard let self = self else { return }
        let conversation = self.conversations[indexPath.item]
        self.leaveConversation(conversation,
                               indexPath: indexPath)
        completed(true)
      }
      
      let leaveAction = UIContextualAction(style: .destructive,
                                           title: "Leave",
                                           handler: leaveActionHandler)
      leaveAction.image = .leave
      let configuration = UISwipeActionsConfiguration(actions: [leaveAction])
      
      return configuration
    }
    
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    
		collectionView = .init(
			frame: .zero,
			collectionViewLayout: layout
		)
    addSubview(collectionView)
    collectionView.pinToEdges(of: self)
    collectionView.backgroundColor = .systemBackground
		collectionView.backgroundView = EmptyStateView(
			message: "No conversations",
			imageName: "bubble"
		)
		collectionView.backgroundView?.isHidden = true
		
    collectionView.delegate = self
    
    collectionView.register(ConversationCell.self,
                            forCellWithReuseIdentifier: ConversationCell.reuseID)
  }
  
  private func createLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                           heightDimension: .estimated(70))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                 subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Conversation>(
			collectionView: collectionView
		) { [weak self] collectionView, indexPath, conversation in
      guard
        let self = self,
        let cell = collectionView.dequeueReusableCell(
					withReuseIdentifier: ConversationCell.reuseID,
					for: indexPath
				) as? ConversationCell else {
        return nil
      }

      cell.set(
				state: self.state,
				conversation: conversation,
				isCompact: self.isCompact
			)
      cell.delegate = self
      
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
  
  private func fetchUsers() {
		Task {
			do {
				users = try await state.fetchUsers()
				
				if !users.isEmpty {
					conversations = users.first?.conversations.sorted(by: sortDescriptor)
					conversations.forEach({ print($0.displayName) })
				}
				
				if conversations.isEmpty {
					collectionView.backgroundView?.isHidden = false
				} else {
					applySnapshot()
				}
				observeUserConversations()
			} catch {
				print(error.localizedDescription)
			}
		}
  }
  
  private func observeUserConversations() {
    userConversationsNotificationToken = users
			.thaw()?
			.observe { [weak self] result in
      guard let self = self else { return }
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
  
  private func leaveConversation(
		_ conversation: Conversation,
		indexPath: IndexPath
	) {
    state.error = nil
    state.shouldIndicateActivity = true
    do {
      try userRealm.write {
        if
          let conversationToDelete = state.user?
						.conversations.filter("id = %@", conversation.id)
						.first {
          print(conversationToDelete)
          userRealm.delete(conversationToDelete)
        }
      }
    } catch {
      print("Unable to leave conversation")
      state.shouldIndicateActivity = false
      UIHelpers.autoDismissableSnackBar(
				title: "Unable to leave \(conversation.displayName)",
				image: .crossCircle,
				backgroundColor: .systemRed,
				textColor: .white,
				view: self.superview ?? self
			)
    }
    state.shouldIndicateActivity = false
  }
}

extension ConversationsView: UICollectionViewDelegate {
  func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
    let conversation = conversations[indexPath.item]
    delegate.pushConversationViewController(
			conversation,
			chatsters: state.chatsters
		)
  }
}

extension ConversationsView: ConversationCellDelegate {
  func showChatsterViewController(chatster: Chatster) {
    delegate.showChatsterViewController(chatster: chatster)
  }
}
