//
//  CAButton.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-04.
//

import UIKit

class CAButton: UIButton {
  let action: () -> Void = {}
  var active = true
  var activeImage: UIImage!
  var inactiveImage: UIImage!
  var padding: CGFloat = 4
  
  private enum Dimensions {
    static let buttonSize: CGFloat = 60
    static let activeOpacity: Float = 0.8
    static let inactiveOpacity: Float = 0.2
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(activeImage: UIImage? = nil,
                  inactiveImage: UIImage? = nil,
                  title: String? = nil,
                  backgroundColor: UIColor? = nil,
                  active: Bool = true) {
    
    if #available(iOS 15.0, *) {
      var configuration = UIButton.Configuration.filled()
      configuration.title = title
      configuration.buttonSize = .large
      configuration.cornerStyle = .medium
      
      configuration.image = active ? activeImage : inactiveImage
      configuration.imagePlacement = .leading
      configuration.imagePadding = 5
      self.configuration = configuration
      self.configuration?.baseBackgroundColor = backgroundColor ?? .systemBlue
    } else {
      // Fallback on earlier versions
      titleLabel?.font = UIFont.rounded(ofSize: 16, weight: .semibold)
      self.backgroundColor = backgroundColor ?? .systemBlue
    }
    layer.opacity = active ? Dimensions.activeOpacity : Dimensions.inactiveOpacity
  }
  
  private func configure() {
    translatesAutoresizingMaskIntoConstraints = false
    
    if #available(iOS 15.0, *) {
      
    } else {
      setTitleColor(.label, for: .normal)
      
      layer.cornerRadius = 10
      layer.cornerCurve = .circular
      backgroundColor = .systemBlue
    }
  }
}
