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
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    statusView.layer.borderColor = UIColor.systemGray3.cgColor
  }
  
  public func set(chatster: Chatster, cornerRadius: CGFloat, online: Bool) {
    self.chatster = chatster
    if let photo = chatster.avatarImage {
      avatarView.delegate = self
      avatarView.set(photo: photo, cornerRadius: cornerRadius)
    }
    configureStatusView(online: online)
  }
  
  private func configureStatusView(online: Bool) {
    contentView.addSubview(statusView)
    statusView.translatesAutoresizingMaskIntoConstraints = false
    statusView.layer.cornerRadius = 7.5
    statusView.layer.cornerCurve = .circular
    statusView.layer.borderColor = UIColor.systemGray3.cgColor
    statusView.layer.borderWidth = 1
    
    NSLayoutConstraint.activate([
      statusView.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor),
      statusView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor),
      statusView.heightAnchor.constraint(equalToConstant: 15),
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
