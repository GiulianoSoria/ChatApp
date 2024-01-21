//
//  UIImage+Extensions.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-04.
//

import UIKit

extension UIImage {
	static let checkbox           = UIImage(systemName: "checkmark.square")
	static let square             = UIImage(systemName: "square")
	
	static let crossCircle        = UIImage(systemName: "xmark.circle")
	static let alertCircle        = UIImage(systemName: "exclamationmark.circle")
	static let checkmarkCircle    = UIImage(systemName: "checkmark.circle")
	
	static let camera             = UIImage(systemName: "camera")
	static let gallery            = UIImage(systemName: "photo")
	static let sendMessage        = UIImage(systemName: "paperplane.circle.fill")
	static let chevronRight       = UIImage(systemName: "chevron.right")
	static let plus               = UIImage(systemName: "plus.circle.fill")
	static let personCircle       = UIImage(systemName: "person.crop.circle")
	static let map                = UIImage(systemName: "map")
	static let more               = UIImage(systemName: "ellipsis")
	static let leave              = UIImage(systemName: "rectangle.portrait.and.arrow.right")
	static let edit               = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
	
	static let signOut            = UIImage(systemName: "person.crop.circle.badge.xmark")
	
  func thumbnail(size: CGFloat) -> UIImage? {
    var thumbnail: UIImage?
    guard let imageData = self.pngData() else {
      return nil
    }
    
    let options = [
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceThumbnailMaxPixelSize: size] as CFDictionary
    
    imageData.withUnsafeBytes { ptr in
      if
        let bytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self),
        let cfData = CFDataCreate(kCFAllocatorDefault, bytes, imageData.count),
        let source = CGImageSourceCreateWithData(cfData, nil),
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) {
        thumbnail = UIImage(cgImage: imageReference)
      }
    }
    
    return thumbnail
  }
}

