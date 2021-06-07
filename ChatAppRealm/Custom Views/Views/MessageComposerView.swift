//
//  MessageComposerView.swift
//  VideoGamesTracker
//
//  Created by Giuliano Soria Pazos on 2020-09-19.
//

import RealmSwift
import UIKit

class MessageComposerView: UIView {
  private var state: AppState!
  private var conversationRealm: Realm!
  
  private var photo: Photo!
  private var location: [Double] = []
  private var isPhotoAdded: Bool = false
  
  private var cameraButton = CAButton()
  private var galleryButton = CAButton()
  private var messageTextView = CATextView()
  private var sendButton = CAButton()
  
  private var isSendButtonActive: Bool = false {
    didSet {
      sendButton.isEnabled = isSendButtonActive
      sendButton.tintColor = sendButton.isEnabled ? .systemBlue : .systemGray
    }
  }
  
  convenience init(state: AppState, conversationRealm: Realm) {
    self.init(frame: .zero)
    self.state = state
    self.conversationRealm = conversationRealm
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
    
    cameraButton.setBackgroundImage(SFSymbols.camera!, for: .normal)
    cameraButton.tintColor = .systemBlue
    galleryButton.setBackgroundImage(SFSymbols.gallery!, for: .normal)
    galleryButton.tintColor = .systemBlue
    
    sendButton.layer.cornerRadius = sendButton.frame.size.height / 2
    sendButton.setBackgroundImage(SFSymbols.sendMessage, for: .normal)
    
    cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
    galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
    sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
  }
  
  private func attachPhoto(_ photo: Photo) {
    if let imageData = photo.picture {
      var attributedString: NSMutableAttributedString!
      attributedString = NSMutableAttributedString(string: self.messageTextView.text)
      
      let textAttachment = NSTextAttachment()
      let originalRange = NSMakeRange(0, attributedString.length)
      let attributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
        NSAttributedString.Key.foregroundColor: UIColor.label
      ]
      attributedString.setAttributes(attributes, range: originalRange)
      
      textAttachment.image = UIImage(data: imageData)
      
      let oldWidth = textAttachment.image!.size.width
      let scaleFactor = oldWidth / (messageTextView.frame.size.width - 10)
      textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
      attributedString.append(NSAttributedString(attachment: textAttachment))
      messageTextView.attributedText = attributedString
    }
  }
  
  @objc private func sendMessage() {
    guard
      messageTextView.text != "" ||
      photo != nil ||
      !location.isEmpty else {
      UIHelpers.autoDismissableSnackBar(title: "Message is empty",
                                        image: SFSymbols.alertCircle,
                                        backgroundColor: .systemYellow,
                                        textColor: .black,
                                        view: self.superview ?? self)
      return
    }
    
    isSendButtonActive = true
    let message = ChatMessage(author: state.user?.userName ?? "Unknown",
                              text: messageTextView.text,
                              image: photo,
                              location: location)
    
    do {
      try conversationRealm.write {
        conversationRealm.add(message)
        UIHelpers.autoDismissableSnackBar(title: "Message Sent",
                                          image: SFSymbols.sendMessage,
                                          backgroundColor: .secondarySystemBackground,
                                          textColor: .label,
                                          view: self.superview ?? self)
        messageTextView.text = ""
      }
    } catch {
      UIHelpers.autoDismissableSnackBar(title: error.localizedDescription,
                                        image: SFSymbols.crossCircle,
                                        backgroundColor: .systemRed,
                                        textColor: .label,
                                        view: self.superview ?? self)
      state.error = error.localizedDescription
    }
  }
  
  @objc private func cameraButtonTapped() {
    PhotoCaptureController.show(source: .camera) { [weak self] controller, photo in
      guard let self = self else { return }
      self.photo = photo
      self.isPhotoAdded = true
      self.attachPhoto(self.photo)
      controller.hide()
    }
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
    let buttons = [cameraButton, galleryButton, sendButton]
    buttons.forEach { button in
      button.backgroundColor = .clear
      addSubview(button)
    }

    addSubview(messageTextView)
    messageTextView.translatesAutoresizingMaskIntoConstraints = false
    
    let padding: CGFloat = 20
    
    NSLayoutConstraint.activate([
      cameraButton.topAnchor.constraint(equalTo: messageTextView.topAnchor),
      cameraButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
      cameraButton.widthAnchor.constraint(equalToConstant: 30),
      cameraButton.heightAnchor.constraint(equalToConstant: 25),
      
      galleryButton.topAnchor.constraint(equalTo: messageTextView.topAnchor),
      galleryButton.leadingAnchor.constraint(equalTo: cameraButton.trailingAnchor, constant: 10),
      galleryButton.widthAnchor.constraint(equalToConstant: 30),
      galleryButton.heightAnchor.constraint(equalToConstant: 25),
      
      messageTextView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      messageTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
      messageTextView.leadingAnchor.constraint(equalTo: galleryButton.trailingAnchor, constant: padding),
      messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding - 10 - 30),
      messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
      
      sendButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
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
