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
  
  private var unreadCountView = UIView()
  private var unreadCountLabel = CALabel(textAlignment: .center, fontSize: 12, weight: .semibold, textColor: .label)
  
  private var separatorView = UIView()
  private var chevronView = CAImageView(frame: .zero)
  
  private let padding: CGFloat = 10
  
  private lazy var unreadCount = 0 {
    didSet {
      unreadCountLabel.text = "\(unreadCount)"
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    configureDecorativeViews()
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
    self.unreadCount = conversation.unreadCount
    
    conversation.members.forEach {
      self.chatsters = chatsters.filter("userName = %@", $0.userName)
    }

    chatroomLabel.text = conversation.displayName
    configureAvatarsView()
    observeChatstersRealm()
    
    if self.unreadCount > 0 {
      configureUnreadCountView()
    } else if self.unreadCount == 0 && contentView.contains(unreadCountView) {
      unreadCountView.removeFromSuperview()
    }
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
  
  private func configureUnreadCountView() {
    contentView.addSubview(unreadCountView)
    unreadCountView.translatesAutoresizingMaskIntoConstraints = false
    unreadCountView.layer.cornerRadius = 15
    unreadCountView.layer.cornerCurve = .circular
    unreadCountView.backgroundColor = .systemBlue
    
    unreadCountView.addSubview(unreadCountLabel)
    
    NSLayoutConstraint.activate([
      unreadCountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      unreadCountLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -padding*2),
      unreadCountLabel.widthAnchor.constraint(equalToConstant: 20),
      unreadCountLabel.heightAnchor.constraint(equalToConstant: 14),
      
      unreadCountView.centerXAnchor.constraint(equalTo: unreadCountLabel.centerXAnchor),
      unreadCountView.centerYAnchor.constraint(equalTo: unreadCountLabel.centerYAnchor),
      unreadCountView.widthAnchor.constraint(equalTo: unreadCountLabel.widthAnchor, constant: padding),
      unreadCountView.heightAnchor.constraint(equalToConstant: 30)
    ])
  }
  
  private func configure() {
    contentView.addSubview(chatroomLabel)
  }
  
  private func configureDecorativeViews() {
    contentView.addSubviews(separatorView, chevronView)
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    separatorView.backgroundColor = .systemGray3
    
    chevronView.image = SFSymbols.chevronRight
    chevronView.backgroundColor = .clear
    chevronView.tintColor = .systemGray3
    chevronView.layer.cornerRadius = 0
    chevronView.contentMode = .scaleAspectFit
    
    NSLayoutConstraint.activate([
      separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      separatorView.heightAnchor.constraint(equalToConstant: 0.5),
      
      chevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding/2),
      chevronView.widthAnchor.constraint(equalToConstant: 15),
      chevronView.heightAnchor.constraint(equalTo: chevronView.widthAnchor)
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
