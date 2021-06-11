//
//  Constants.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

struct SFSymbols {
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
  static let leave              = UIImage(systemName: "rectangle.portrait.and.arrow.right")
  static let edit               = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
  
  static let signOut            = UIImage(systemName: "person.crop.circle.badge.xmark")
}

struct NotificationKeys {
  static let updateUserProfile  = "com.gcsoriap.ChatAppRealm.updateUserProfile"
}
