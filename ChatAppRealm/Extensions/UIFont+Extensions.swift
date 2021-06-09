//
//  UIFont+Extensions.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-08.
//

import UIKit

extension UIFont {
  class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
    let font: UIFont
    
    if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
      font = UIFont(descriptor: descriptor, size: size)
    } else {
      font = systemFont
    }
    return font
  }
}

