//
//  String+Extensions.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

extension String {
  func estimateFrameFor(width: CGFloat, fontSize: CGFloat, fontWeight: UIFont.Weight) -> CGRect {
    let size = CGSize(width: width, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight)]
    
    return NSString(string: self).boundingRect(with: size, options: options, attributes: attributes, context: nil)
  }
}
