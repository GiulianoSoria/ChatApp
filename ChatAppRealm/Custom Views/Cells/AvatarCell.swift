//
//  AvatarCell.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-06.
//

import UIKit

class AvatarCell: UICollectionViewCell {
  static let reuseID = "AvatarCell"
  
  var chatster: Chatster!
  
  var avatarView = ThumbnailView(frame: .zero)
  var statusView = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(chatster: Chatster, online: Bool) {
    self.chatster = chatster
    if let photo = chatster.avatarImage {
      avatarView.delegate = self
      avatarView.set(photo: photo)
    }
    configureStatusView(online: online)
  }
  
  private func configureStatusView(online: Bool) {
    contentView.addSubview(statusView)
    statusView.translatesAutoresizingMaskIntoConstraints = false
    statusView.layer.cornerRadius = 5
    statusView.layer.cornerCurve = .circular
    
    let padding: CGFloat = 2
    
    NSLayoutConstraint.activate([
      statusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      statusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
      statusView.heightAnchor.constraint(equalToConstant: 10),
      statusView.widthAnchor.constraint(equalTo: statusView.heightAnchor)
    ])
    
    if online {
      statusView.backgroundColor = .systemGreen
    } else {
      statusView.backgroundColor = .systemRed
    }
  }
  
  private func configure() {
    contentView.addSubview(avatarView)
    avatarView.pinToEdges(of: contentView)
  }
}

extension AvatarCell: ThumbnailViewDelegate {
  func thumbnailTapped() { }
}
