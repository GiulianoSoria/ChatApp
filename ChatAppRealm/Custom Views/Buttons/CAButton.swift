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
                  active: Bool = true) {
    setImage(active ? activeImage : inactiveImage, for: .normal)
    setTitle(title, for: .normal)
    layer.opacity = active ? Dimensions.activeOpacity : Dimensions.inactiveOpacity
  }
  
  private func configure() {
    translatesAutoresizingMaskIntoConstraints = false
    
    setTitleColor(.label, for: .normal)
    
    layer.cornerRadius = 10
    layer.cornerCurve = .circular
    backgroundColor = .systemBlue
    titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
  }
}
