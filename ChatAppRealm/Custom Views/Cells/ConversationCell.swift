//
//  ConversationCell.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import RealmSwift
import UIKit

protocol ConversationCellDelegate: AnyObject {
  func showChatsterViewController(chatster: Chatster)
}

class ConversationCell: UICollectionViewCell {
  public static let reuseID = "ConversationCell"
  
  private var state: AppState!
  private var conversation: Conversation!
  
  weak var delegate: ConversationCellDelegate!
  
  private var chatroomLabel = CALabel(textAlignment: .left, fontSize: 16, weight: .semibold, textColor: .label)
  private var avatarsView: AvatarsGridView!
  
  private var unreadCountView = UIView()
  private var unreadCountLabel = CALabel(textAlignment: .center, fontSize: 12, weight: .regular, textColor: .label)
  
  private var chevronView = CAImageView(frame: .zero)
  
  private var isCompact: Bool = true
  private let padding: CGFloat = 16
  
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
  
  public func set(
		state: AppState,
		conversation: Conversation,
		isCompact: Bool
	) {
    self.state = state
    self.conversation = conversation
//		self.chatstersRealm = state.realm
    self.unreadCount = conversation.unreadCount
    self.isCompact = isCompact

    chatroomLabel.text = conversation.displayName
    
		configureAvatarsView(chatsters: state.chatsters)
    
    if self.unreadCount > 0 {
      configureUnreadCountView()
    } else if self.unreadCount == 0 && contentView.contains(unreadCountView) {
      unreadCountView.removeFromSuperview()
    }
    
    contentView.backgroundColor = .secondarySystemBackground
  }
  
  private func configureAvatarsView(chatsters: Results<Chatster>) {
		avatarsView = .init(
			state: state,
			conversation: conversation,
			chatsters: chatsters,
			isCompact: self.isCompact
		)
    avatarsView.delegate = self
    contentView.addSubview(avatarsView)
    
    NSLayoutConstraint.activate([
      avatarsView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      avatarsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      avatarsView.widthAnchor.constraint(equalToConstant: 50),
      avatarsView.heightAnchor.constraint(equalToConstant: 40),
      
      chatroomLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
      chatroomLabel.leadingAnchor.constraint(equalTo: avatarsView.trailingAnchor, constant: padding/2),
      chatroomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding*2),
      chatroomLabel.heightAnchor.constraint(equalToConstant: 18)
    ])
  }
  
  private func configureUnreadCountView() {
    contentView.addSubview(unreadCountView)
    unreadCountView.translatesAutoresizingMaskIntoConstraints = false
    unreadCountView.layer.cornerRadius = 12
    unreadCountView.layer.cornerCurve = .circular
    unreadCountView.backgroundColor = .tintColor
    
    unreadCountView.addSubview(unreadCountLabel)
    
    NSLayoutConstraint.activate([
      unreadCountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      unreadCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding*2),
      unreadCountLabel.widthAnchor.constraint(equalToConstant: 20),
      unreadCountLabel.heightAnchor.constraint(equalToConstant: 14),
      
      unreadCountView.centerXAnchor.constraint(equalTo: unreadCountLabel.centerXAnchor),
      unreadCountView.centerYAnchor.constraint(equalTo: unreadCountLabel.centerYAnchor),
      unreadCountView.widthAnchor.constraint(equalTo: unreadCountLabel.widthAnchor, constant: padding/4),
			unreadCountView.heightAnchor.constraint(equalTo: unreadCountView.widthAnchor),
    ])
  }
  
  private func configure() {
    contentView.addSubview(chatroomLabel)
    contentView.backgroundColor = .secondarySystemBackground
    
    contentView.heightAnchor.constraint(equalToConstant: 60).isActive = true
  }
  
  private func configureDecorativeViews() {
    contentView.addSubviews(chevronView)

    chevronView.image = .chevronRight
    chevronView.backgroundColor = .clear
    chevronView.tintColor = .systemGray3
    chevronView.layer.cornerRadius = 0
    chevronView.contentMode = .scaleAspectFit

    NSLayoutConstraint.activate([
      chevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding/2),
      chevronView.widthAnchor.constraint(equalToConstant: 15),
      chevronView.heightAnchor.constraint(equalTo: chevronView.widthAnchor)
    ])
  }
}

extension ConversationCell: AvatarsGridViewDelegate {
  func showChatsterViewController(chatster: Chatster) {
    delegate.showChatsterViewController(chatster: chatster)
  }
}
