//
//  ConversationCell.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import RealmSwift
import UIKit

class ConversationCell: UICollectionViewCell {
  public static let reuseID = "ConversationCell"
  
  private var state: AppState!
  private var chatstersRealm: Realm!
  private var chatstersRealmNotificationToken: NotificationToken!
  private var chatsters: Results<Chatster>!
  
  private var chatroomLabel = CALabel(textAlignment: .left, fontSize: 16, weight: .semibold, textColor: .label)
  private var avatarsView: AvatarsGridView!
  
  private var separatorView = UIView()
  
  private let padding: CGFloat = 10
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    configureSeparatorView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(state: AppState,
                  conversation: Conversation,
                  chatstersRealm: Realm,
                  chatsters: Results<Chatster>) {
    self.state = state
    self.chatstersRealm = chatstersRealm

    
    conversation.members.forEach {
      self.chatsters = chatsters.filter("userName = %@", $0.userName)
    }

    chatroomLabel.text = conversation.displayName
    configureAvatarsView()
    observeChatstersRealm()
  }
  
  private func configureAvatarsView() {
    avatarsView = AvatarsGridView(chatsters: Array(self.chatsters))
    if contentView.contains(avatarsView) { avatarsView.removeFromSuperview() }
    contentView.addSubview(avatarsView)
    
    NSLayoutConstraint.activate([
      avatarsView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      avatarsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2*padding),
      avatarsView.widthAnchor.constraint(equalToConstant: chatsters.count < 4 ? CGFloat(chatsters.count * 50) : CGFloat(3 * 50)),
      avatarsView.heightAnchor.constraint(equalToConstant: 40),
      
      chatroomLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
      chatroomLabel.leadingAnchor.constraint(equalTo: avatarsView.trailingAnchor, constant: padding),
      chatroomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      chatroomLabel.heightAnchor.constraint(equalToConstant: 18)
    ])
  }
  
  private func configure() {
    contentView.addSubview(chatroomLabel)
  }
  
  private func configureSeparatorView() {
    contentView.addSubview(separatorView)
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    separatorView.backgroundColor = .systemGray3
    
    NSLayoutConstraint.activate([
      separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      separatorView.heightAnchor.constraint(equalToConstant: 0.5)
    ])
  }
  
  private func observeChatstersRealm() {
    chatstersRealmNotificationToken = chatsters.thaw()?.observe { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .error(let error):
        print(error.localizedDescription)
      case .update(let chatsters, deletions: _, insertions: _, modifications: _):
        self.chatsters = chatsters
        self.configureAvatarsView()
      default:
        break
      }
    }
  }
}
