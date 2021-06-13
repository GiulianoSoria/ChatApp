//
//  ChatroomCreationViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-08.
//

import Combine
import RealmSwift
import UIKit

class ChatroomCreationViewController: UIViewController {
  private var state: AppState!
  private var userRealm: Realm!
  private var conversationRealm: Realm!
  public var conversation: Conversation!
  private var chatsters: Results<Chatster>!
  
  private enum Section { case title, selected, all }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
  private var doneButton: UIBarButtonItem!
  
  lazy public var textField: CATextField = {
    let textField = CATextField(frame: .zero)
    textField.translatesAutoresizingMaskIntoConstraints = true
    textField.borderStyle = .none
    textField.placeholder = "Start typing..."
    textField.returnKeyType = .done
    
    textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    textField.delegate = self
    return textField
  }()
  
  public var selected: [Chatster] = []
  private var all: [Chatster] = []
  
  private var isDoneButtonEnabled: Bool = false {
    didSet {
      doneButton?.isEnabled = isDoneButtonEnabled
    }
  }
  
  public var isUpdating: Bool = false
  
  init(state: AppState, chatsters: Results<Chatster>, userRealm: Realm) {
    super.init(nibName: nil, bundle: nil)
    self.state = state
    self.chatsters = chatsters
    self.userRealm = userRealm
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
    configureCollectionView()
    configureDataSource()
    if isUpdating { fetchConversationRealm(conversation: conversation) }
    fetchChatsters()
    applySnapshot()
  }
  
  private func configureViewController() {
    title = isUpdating ? "Update Chatroom" : "New Chatroom"
    view.backgroundColor = .systemBackground
    
    if
      let conversation = conversation {
      isDoneButtonEnabled = !conversation.displayName.isEmpty && !selected.isEmpty
    }
    
    let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                      target: self,
                                      action: #selector(closeButtonTapped))
    navigationItem.leftBarButtonItem = closeButton
    
    doneButton = UIBarButtonItem(title: isUpdating ? "Update" : "Create",
                                 style: .done,
                                 target: self,
                                 action: #selector(doneButtonTapped))
    doneButton.isEnabled = isDoneButtonEnabled
    navigationItem.rightBarButtonItem = doneButton
  }
  
  @objc private func closeButtonTapped() {
    self.dismiss(animated: true)
  }
  
  @objc private func doneButtonTapped() {
    isUpdating ? updateConversation() : saveConversation()
  }
  
  private func configureCollectionView() {
    var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    configuration.backgroundColor = .systemBackground
    configuration.headerMode = .supplementary
    configuration.trailingSwipeActionsConfigurationProvider = { indexPath -> UISwipeActionsConfiguration? in
      if indexPath.section == 1 && !self.isUpdating {
        let chatster = self.selected[indexPath.item]
        let deleteHandler: UIContextualAction.Handler = { action, view, completed in
          self.deleteButtonTapped(chatster: chatster)
          completed(true)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: deleteHandler)
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
      } else {
        return nil
      }
    }
    
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.addSubview(collectionView)
    collectionView.pinToEdges(of: view)
    collectionView.backgroundColor = .systemBackground
    collectionView.keyboardDismissMode = .interactive
    collectionView.delegate = self
  }
  
  private func configureDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      var configuration = UIListContentConfiguration.cell()
      switch indexPath.section {
      case 0:
        configuration.text = ""
        cell.accessories = [.customView(configuration: self.configureTextField(in: cell))]
      case 1:
        let chatster = self.selected[indexPath.item]
        configuration.text = chatster.userName
        cell.accessories = []
      case 2:
        let chatster = self.all[indexPath.item]
        configuration.text = chatster.userName
        cell.accessories = [.insert(displayed: .always, actionHandler: { self.addChatsterToRoom(chatster) })]
      default:
        break
      }
      
      cell.contentConfiguration = configuration
      cell.backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
      cell.backgroundColor = .secondarySystemBackground
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
      var configuration: UIListContentConfiguration!
      
      if #available(iOS 15.0, *) {
        configuration = UIListContentConfiguration.prominentInsetGroupedHeader()
      } else {
        configuration = UIListContentConfiguration.sidebarHeader()
      }
      
      switch indexPath.section {
      case 0:
        configuration.text = "Chatroom Title"
      case 1:
        configuration.text = "Selected Users"
      case 2:
        configuration.text = "Available users"
      default:
        break
      }
      
      headerView.contentConfiguration = configuration
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { collectionView, indexPath, item in
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
    
    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath -> UICollectionReusableView? in
      if elementKind == UICollectionView.elementKindSectionHeader {
        return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
      } else {
        return nil
      }
    }
  }
  
  private func configureTextField(in cell: UICollectionViewListCell) -> UICellAccessory.CustomViewConfiguration {
    textField.frame = CGRect(x: 0,
                             y: 0,
                             width: cell.contentView.frame.width - 40,
                             height: cell.contentView.frame.height)
    
    let placement = UICellAccessory.Placement.leading(displayed: .always,
                                                      at: UICellAccessory.Placement.position(before: .disclosureIndicator()))
    let width = UICellAccessory.LayoutDimension.actual
    let configuration = UICellAccessory.CustomViewConfiguration(customView: textField,
                                                                placement: placement,
                                                                isHidden: false,
                                                                reservedLayoutWidth: width,
                                                                tintColor: .systemBlue,
                                                                maintainsFixedSize: true)
    
    return configuration
  }
  
  private func applySnapshot(animatingDifferences: Bool = false) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
    snapshot.appendSections([.title, .selected, .all])
    snapshot.appendItems([""], toSection: .title)
    snapshot.appendItems(selected, toSection: .selected)
    snapshot.appendItems(all, toSection: .all)
    
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }
  
  @objc private func textFieldDidChange(_ textField: UITextField) {
    if
      let text = textField.text {
      if !text.isEmpty && text != "" && !selected.isEmpty {
        isDoneButtonEnabled = true
      } else {
        isDoneButtonEnabled = false
      }
    } else {
      isDoneButtonEnabled = false
    }
  }
  
  private func addButtonTapped(chatster: Chatster) {
    if
      let chatster = all.first(where: { $0 == chatster }) {
      addChatsterToRoom(chatster)
    }
  }
  
  private func deleteButtonTapped(chatster: Chatster) {
    if
      let chatster = selected.first(where: { $0 == chatster }) {
      removeChatsterToRoom(chatster)
    }
  }
  
  private func addChatsterToRoom(_ chatster: Chatster) {
    self.selected.append(chatster)
    self.all.removeAll(where: { $0 == chatster })
    self.applySnapshot(animatingDifferences: true)
    self.textFieldDidChange(self.textField)
  }
  
  private func removeChatsterToRoom(_ chatster: Chatster) {
    self.selected.removeAll(where: { $0 == chatster })
    self.all.append(chatster)
    self.applySnapshot(animatingDifferences: true)
    self.textFieldDidChange(self.textField)
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
        let chatsters = realm.objects(Chatster.self)
        
        self.all = chatsters.filter({ $0.userName != self.state.user!.userName })
        self.all = self.all.filter({ !self.selected.contains($0) })
        
        var snapshot = self.dataSource.snapshot()
        snapshot.appendItems(self.all, toSection: .all)
        self.dataSource.apply(snapshot, animatingDifferences: true)
      }
      .store(in: &state.subscribers)
  }
  
  private func saveConversation() {
    state.error = nil
    doneButton.isEnabled = false
    let conversation = Conversation()
    conversation.displayName = textField.text ?? "Chat"
    guard
      let userName = state.user?.userName else {
        doneButton.isEnabled = true
      state.error = "Current user is not set"
      return
    }
    
    let members = selected.map({ $0.userName })
    conversation.members.append(Member(userName: userName, state: .active))
    conversation.members.append(objectsIn: members.map { Member($0) })
    state.shouldIndicateActivity = true
    do {
      try userRealm.write {
        state.user?.conversations.append(conversation)
      }
    } catch {
      state.error = "Unable to open Realm write transaction"
      state.shouldIndicateActivity = false
      doneButton.isEnabled = true
      return
    }
    UIHelpers.autoDismissableSnackBar(title: "\(conversation.displayName) created",
                                      image: SFSymbols.checkmarkCircle,
                                      backgroundColor: .systemBlue,
                                      textColor: .label,
                                      view: self.view)
    closeButtonTapped()
    state.shouldIndicateActivity = false
    doneButton.isEnabled = true
  }
  
  private func updateConversation() {
    state.error = nil
    doneButton.isEnabled = false
    if
      let conversation = state.user?.conversations.filter("id = %@", conversation.id).first {
      state.shouldIndicateActivity = true
      
      UIHelpers.showSnackBar(title: "Updating Conversation",
                             backgroundColor: .systemBlue,
                             view: self.view)
      
      let membersUsernames = selected.map({ $0.userName })
      let membersUsernamesInConversation = conversation.members.map { $0.userName }
      let membersUsernamesToAdd = membersUsernames.filter({ !membersUsernamesInConversation.contains($0) })
      print(membersUsernamesToAdd)
      
      //Find a way to update every user's copy of the conversation
      state.app.currentUser!.functions.chatNameChange([AnyBSON(stringLiteral: "update"),
                                                       AnyBSON(stringLiteral: "conversation=\(conversation.id)"),
                                                       AnyBSON(stringLiteral: textField.text ?? "Chat")])
        .receive(on: DispatchQueue.main, options: .none)
        .sink { [weak self] completion in
          guard let self = self else { return }
          switch completion {
          case .failure(let error):
            print(error.localizedDescription)
            UIHelpers.hideSnackBar(title: "Updating conversation",
                                   backgroundColor: .systemBlue,
                                   view: self.view)
            self.state.shouldIndicateActivity = false
            self.doneButton.isEnabled = true
          case .finished:
            break
          }
        } receiveValue: { [weak self] result in
          guard let self = self else { return }
          UIHelpers.hideSnackBar(title: "Updating conversation",
                                 backgroundColor: .systemBlue,
                                 view: self.view)
          if
            let doc = result.documentValue,
            let value = doc.values.first,
            let completed = value?.boolValue, completed {
            self.closeButtonTapped()
          } else {
            UIHelpers.autoDismissableSnackBar(title: "Error updating conversation title",
                                              image: SFSymbols.crossCircle,
                                              backgroundColor: .systemRed,
                                              textColor: .white,
                                              view: self.view)
          }
          
          self.state.shouldIndicateActivity = false
          self.doneButton.isEnabled = true
        }
        .store(in: &state.subscribers)
    }
  }
  
  private func fetchConversationRealm(conversation: Conversation) {
    let config = state.app.currentUser!.configuration(partitionValue: "conversation=\(conversation.id)")
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
        self.conversationRealm = realm
      }
      .store(in: &state.subscribers)
  }
}

extension ChatroomCreationViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    switch indexPath.section {
    case 2:
      let chatster = self.all[indexPath.item]
      addButtonTapped(chatster: chatster)
    default:
      break
    }
  }
}

extension ChatroomCreationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if
      let text = textField.text,
      !text.isEmpty {
      doneButtonTapped()
      return true
    }
    
    return false
  }
}
