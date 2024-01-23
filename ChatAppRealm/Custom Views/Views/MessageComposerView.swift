//
//  MessageComposerView.swift
//  VideoGamesTracker
//
//  Created by Giuliano Soria Pazos on 2020-09-19.
//

import MapKit
import RealmSwift
import UIKit

class MessageComposerView: UIView {
  private var state: AppState!
  private var conversationRealm: Realm!
  private var conversation: Conversation!
  
  weak var chatroomViewController: ChatroomViewController!
  
  private var photo: Photo!
  private var mapView: CAMapView!
  private var location: [Double] = []
  private var isPhotoAdded: Bool = false
  
  private var galleryButton = CAButton()
  private var moreButton = CAButton()
  private var messageTextView = CATextView()
  private var sendButton = CAButton()
  
  private var isSendButtonActive: Bool = false {
    didSet {
      sendButton.isEnabled = isSendButtonActive
      sendButton.tintColor = sendButton.isEnabled ? .tintColor : .systemGray
    }
  }
  
  convenience init(state: AppState, conversationRealm: Realm, conversation: Conversation) {
    self.init(frame: .zero)
    self.state = state
    self.conversationRealm = conversationRealm
    self.conversation = conversation
    layoutUI()
    configure()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func configure() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .secondarySystemBackground
    
    messageTextView.delegate = self
    
    moreButton.setBackgroundImage(.more, for: .normal)
    moreButton.tintColor = .tintColor
    moreButton.menu = moreMenu()
    moreButton.showsMenuAsPrimaryAction = true
    
//    cameraButton.setBackgroundImage(SFSymbols.camera, for: .normal)
//    cameraButton.tintColor = .tintColor
    galleryButton.setBackgroundImage(.gallery, for: .normal)
    galleryButton.tintColor = .tintColor
    
    sendButton.layer.cornerRadius = sendButton.frame.size.height / 2
    sendButton.setBackgroundImage(.sendMessage, for: .normal)
    
//    cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
    galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
    sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
  }
  
  private func attachPhoto(_ photo: Photo) {
    if let imageData = photo.picture {
      var attributedString: NSMutableAttributedString!
      attributedString = NSMutableAttributedString(string: self.messageTextView.text)
      
      let textAttachment = NSTextAttachment()
      let originalRange = NSMakeRange(0, attributedString.length)
      let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 14),
                                                        .foregroundColor: UIColor.label]
      attributedString.setAttributes(attributes, range: originalRange)
      
      textAttachment.image = UIImage(data: imageData)
      
      let oldWidth = textAttachment.image!.size.width
      let scaleFactor = oldWidth / (messageTextView.frame.size.width - 10)
      textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!,
                                     scale: scaleFactor,
                                     orientation: .up)
      attributedString.append(NSAttributedString(attachment: textAttachment))
      messageTextView.attributedText = attributedString
    }
  }
  
  private func attachLocation(_ location: CLLocationCoordinate2D) {
    var attributedString: NSMutableAttributedString!
    attributedString = NSMutableAttributedString(string: self.messageTextView.text)
    
    let textAttachment = NSTextAttachment()
    let originalRange = NSMakeRange(0, attributedString.length)
    let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 14),
                                                      .foregroundColor: UIColor.label]
    attributedString.setAttributes(attributes, range: originalRange)
    
//    textAttachment.image = UIImage(data: <#T##Data#>)
    
    let oldWidth = textAttachment.image!.size.width
    let scaleFactor = oldWidth / (messageTextView.frame.size.width - 10)
    textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!,
                                   scale: scaleFactor,
                                   orientation: .up)
    attributedString.append(NSAttributedString(attachment: textAttachment))
    messageTextView.attributedText = attributedString
  }
  
  @objc private func sendMessage() {
    guard
      messageTextView.text != "" ||
      photo != nil ||
      !location.isEmpty else {
      UIHelpers.autoDismissableSnackBar(
				title: "Message is empty",
				image: .alertCircle,
				backgroundColor: .systemYellow,
				textColor: .black,
				view: self.superview ?? self
			)
      return
    }
    
    isSendButtonActive = true
    let message = ChatMessage(
			author: state.user?.userName ?? "Unknown",
			authorID: state.user!._id,
			text: messageTextView.text,
			image: photo,
			location: location
		)
    message.conversationID = conversation.id
    
    do {
      try conversationRealm.write {
        conversationRealm.add(message)
        messageTextView.text = ""
      }
    } catch {
      UIHelpers.autoDismissableSnackBar(
				title: error.localizedDescription,
				image: .crossCircle,
				backgroundColor: .systemRed,
				textColor: .label,
				view: self.superview ?? self
			)
      state.error = error.localizedDescription
    }
  }
  
  private func moreMenu() -> UIMenu {
    let cameraAction = UIAction(title: "Camera", image: .camera) { [weak self] _ in
      guard let self = self else { return }
      PhotoCaptureController.show(source: .camera) { [weak self] controller, photo in
        guard let self = self else { return }
        self.photo = photo
        self.isPhotoAdded = true
        self.attachPhoto(self.photo)
        controller.hide()
      }
    }
    
    let mapAction = UIAction(title: "Location", image: .map) { [weak self] _ in
      guard let self = self else { return }
      let destVC = MapViewController()
      self.chatroomViewController.navigationController?.pushViewController(destVC, animated: true)
      
    }
    
    let menu = UIMenu(
			title: "More Options",
			options: .displayInline,
			children: [cameraAction, mapAction]
		)
    
    return menu
  }
  
  @objc private func cameraButtonTapped() {
    
  }
  
  @objc private func galleryButtonTapped() {
    PhotoCaptureController.show(source: .photoLibrary) { [weak self] controller, photo in
      guard let self = self else { return }
      self.photo = photo
      self.isPhotoAdded = true
      self.attachPhoto(self.photo)
      controller.hide()
    }
  }
  
  private func layoutUI() {
    let buttons = [moreButton, galleryButton, sendButton]
    buttons.forEach { button in
      button.backgroundColor = .clear
      addSubview(button)
    }

    addSubview(messageTextView)
    messageTextView.translatesAutoresizingMaskIntoConstraints = false
    
    let padding: CGFloat = 20
    
    NSLayoutConstraint.activate([
      moreButton.topAnchor.constraint(equalTo: messageTextView.topAnchor),
      moreButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
      moreButton.widthAnchor.constraint(equalToConstant: 30),
      moreButton.heightAnchor.constraint(equalToConstant: 22),
      
      galleryButton.topAnchor.constraint(equalTo: messageTextView.topAnchor),
      galleryButton.leadingAnchor.constraint(equalTo: moreButton.trailingAnchor, constant: padding/2),
      galleryButton.widthAnchor.constraint(equalToConstant: 30),
      galleryButton.heightAnchor.constraint(equalToConstant: 25),
      
      messageTextView.topAnchor.constraint(equalTo: topAnchor, constant: padding/2),
      messageTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
      messageTextView.leadingAnchor.constraint(equalTo: galleryButton.trailingAnchor, constant: padding),
      messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding - 40),
      messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
      
      sendButton.topAnchor.constraint(equalTo: topAnchor, constant: padding/2),
      sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
      sendButton.heightAnchor.constraint(equalToConstant: 30),
      sendButton.widthAnchor.constraint(equalTo: sendButton.heightAnchor)
    ])
  }
}

extension MessageComposerView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let fixedWidth = textView.frame.size.width
    textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    var newFrame = textView.frame
    newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    textView.frame = newFrame
  }
}
