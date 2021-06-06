//
//  CALabel.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

class CALabel: UILabel {
//  let fontChanged = Notification.Name(NotificationKeys.fontChangedNotificationKey)
  
  private var fontSize: CGFloat! = 14
  private var weight: UIFont.Weight! = .regular
  
  override init(frame: CGRect) {
    super.init(frame: frame)
//    createObserver()
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  convenience init(textAlignment: NSTextAlignment, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor) {
    self.init(frame: .zero)
    self.fontSize = fontSize
    self.weight = weight
    self.textAlignment = textAlignment
    self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
    self.textColor = textColor
  }
  
  func set(textAlignment: NSTextAlignment, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) {
    self.fontSize = fontSize
    self.weight = fontWeight
    self.textAlignment = textAlignment
    self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
    self.textColor = textColor
  }
  
  func configure() {
    adjustsFontSizeToFitWidth = true
    adjustsFontForContentSizeCategory = true
    minimumScaleFactor = 0.75
    lineBreakMode = .byWordWrapping
    translatesAutoresizingMaskIntoConstraints = false
  }
  
//  func createObserver() {
//    NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: fontChanged, object: nil)
//  }
//
//  @objc func handleNotification(_ notification: Notification) {
//    if notification.name == fontChanged {
//      self.font = AppDelegate.isFontRound ? UIFont.rounded(ofSize: fontSize, weight: weight) : UIFont.systemFont(ofSize: fontSize, weight: weight)
//    }
//  }
}
