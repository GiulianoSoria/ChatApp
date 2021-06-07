//
//  VGTextView.swift
//  VideoGamesTracker
//
//  Created by Giuliano Soria Pazos on 2020-09-23.
//

import UIKit

class CATextView: UITextView {

  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    backgroundColor = .tertiarySystemBackground
    tintColor = .systemBlue
    layer.cornerRadius = 5
    
    autocorrectionType = .default
    clipsToBounds = true
    sizeToFit()
    isScrollEnabled = false
    translatesAutoresizingMaskIntoConstraints = true
    adjustsFontForContentSizeCategory = true
    autocapitalizationType = .sentences
    font = UIFont.systemFont(ofSize: 14, weight: .regular)
    dataDetectorTypes = .all
    returnKeyType = .default
  }
}
