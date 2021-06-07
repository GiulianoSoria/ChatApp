//
//  ConversationCell.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import RealmSwift
import UIKit

class ConversationCell: UICollectionViewCell {
  static let reuseID = "ConversationCell"
  
  var state: AppState!
  var chatsters: [Chatster] = []
  
  var chatroomLabel = CALabel(textAlignment: .left, fontSize: 16, weight: .semibold, textColor: .label)
  var avatarsView: AvatarsGridView!
  
  var separatorView = UIView()
  
  let padding: CGFloat = 10
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    configureSeparatorView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(state: AppState, conversation: Conversation, chatsters: Results<Chatster>) {
    self.state = state
    chatroomLabel.text = conversation.displayName
    self.chatsters = Array(chatsters)
    let chatstersInConversation = conversation.members.map({ $0.userName })
    self.chatsters.removeAll(where: { !chatstersInConversation.contains($0.userName) })
    configureAvatarsView()
  }
  
  private func configureAvatarsView() {
    avatarsView = AvatarsGridView(chatsters: self.chatsters)
    contentView.addSubview(avatarsView)
    
    NSLayoutConstraint.activate([
      avatarsView.topAnchor.constraint(equalTo: chatroomLabel.topAnchor),
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
    
    NSLayoutConstraint.activate([
      
    ])
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
}
