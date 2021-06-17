//
//  MessageCell.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-06.
//

import UIKit

class MessageCell: UICollectionViewCell {
  static let reuseID = "MessageCell"
  
  var containerView = UIView()
  var authorLabel = CALabel()
  var avatarView = ThumbnailView(frame: .zero)
  var timeLabel = CALabel()
  
  var textLabel = CALabel()
  var imageView = CAImageView(frame: .zero)
  
  private var onReuse: () -> Void = {}
  
  private let padding: CGFloat = 10
  
  private var isMyMessage: Bool = false {
    didSet {
      containerView.backgroundColor = isMyMessage ? .systemBlue : .secondarySystemBackground
      containerViewLeadingAnchor.isActive = isMyMessage ? false : true
      containerViewTrailingAnchor.isActive = isMyMessage ? true : false
      yourTimeLabelTrailingAnchor.isActive = isMyMessage ? false : true
      myTimeLabelTrailingAnchor.isActive = isMyMessage ? true: false
      !isMyMessage ? containerView.addSubview(authorLabel) : authorLabel.removeFromSuperview()
      !isMyMessage ? NSLayoutConstraint.activate(authorLabelConstraints) : NSLayoutConstraint.deactivate(authorLabelConstraints)
      myTextLabelTopAnchor.isActive = !isMyMessage ? false : true
      yourTextLabelTopAnchor.isActive = !isMyMessage ? true : false
    }
  }
  
  private var isMediaShown: Bool = false {
    didSet {
      containerViewHeightAnchor.isActive = isMediaShown ? true : false
      containerViewWidthAnchor.isActive = isMediaShown ? true : false
    }
  }
  
  private var containerViewLeadingAnchor: NSLayoutConstraint!
  private var containerViewTrailingAnchor: NSLayoutConstraint!
  private var containerViewHeightAnchor: NSLayoutConstraint!
  private var containerViewWidthAnchor: NSLayoutConstraint!
  private var yourTimeLabelTrailingAnchor: NSLayoutConstraint!
  private var myTimeLabelTrailingAnchor: NSLayoutConstraint!
  
  private var myTextLabelTopAnchor: NSLayoutConstraint!
  private var yourTextLabelTopAnchor: NSLayoutConstraint!
  private var authorLabelConstraints: [NSLayoutConstraint] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    onReuse()
    avatarView.removeFromSuperview()
    imageView.removeFromSuperview()
    isMyMessage = false
  }
  
  public func set(chatster: Chatster? = nil, message: ChatMessage, isMyMessage: Bool, isMediaShown: Bool) {
    self.isMyMessage = isMyMessage
    self.isMediaShown = isMediaShown
    authorLabel.set(textAlignment: .left, fontSize: 13, fontWeight: .semibold, textColor: .secondaryLabel)
    authorLabel.text = isMyMessage ? "" : message.author
    
    timeLabel.set(textAlignment: .right, fontSize: 12, fontWeight: .regular, textColor: .secondaryLabel)
    let isLessThanADay = message.timestamp.timeIntervalSinceNow > -60 * 60 * 24
    timeLabel.text = isLessThanADay ? message.timestamp.convertToHourMinutsFormat() : message.timestamp.convertToMonthDayYearFormat()
    
    textLabel.set(textAlignment: .left, fontSize: 14, fontWeight: .regular, textColor: .label)
    textLabel.text = message.text
    textLabel.numberOfLines = 0
    
    if
      let image = message.image {
      configureImageView(image: image)
    }
    
    if !isMyMessage {
      if
        let chatster = chatster,
        let photo = chatster.avatarImage {
        configureAvatarView(photo: photo)
      }
    }
  }
  
  private func configureImageView(image: Photo) {
    if
      let imageData = image.picture {
      imageView.image = UIImage(data: imageData)
      containerView.addSubview(imageView)
      imageView.pinToEdges(of: containerView)
    }
  }
  
  private func configureAvatarView(photo: Photo) {
    avatarView.delegate = self
    avatarView.set(photo: photo,
                   cornerRadius: 10)
    contentView.addSubview(avatarView)
    avatarView.layer.cornerCurve = .circular
    
    NSLayoutConstraint.activate([
      avatarView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      avatarView.heightAnchor.constraint(equalToConstant: 20),
      avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
    ])
  }
  
  private func configure() {
    contentView.addSubviews(containerView, timeLabel)
    containerView.addSubviews(textLabel)
    configureContainerView()
    
    NSLayoutConstraint.activate([
      timeLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: padding/2),
      timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
      timeLabel.heightAnchor.constraint(equalToConstant: 14),
      
      textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
      textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
      textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding)
    ])
    
    myTextLabelTopAnchor = textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding)
    yourTextLabelTopAnchor = textLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: padding/2)
    
    authorLabelConstraints = [
      authorLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding/2),
      authorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
      authorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
      authorLabel.heightAnchor.constraint(equalToConstant: 14)
    ]
  }
  
  private func configureContainerView() {
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.layer.cornerRadius = 10
    containerView.layer.cornerCurve = .continuous
    
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding*2 - 14),
      containerView.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width * 0.8)
    ])
    
    containerViewLeadingAnchor = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*4)
    containerViewTrailingAnchor = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
    containerViewWidthAnchor = containerView.widthAnchor.constraint(equalToConstant: 250)
    containerViewHeightAnchor = containerView.heightAnchor.constraint(equalToConstant: 250)
    yourTimeLabelTrailingAnchor = timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
    myTimeLabelTrailingAnchor = timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
  }
}

extension MessageCell: ThumbnailViewDelegate {
  func thumbnailTapped() { }
}
