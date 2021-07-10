//
//  Constants.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

struct Keys {
  static let appKey             = "chatapp-jfsse"
}

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
  static let map                = UIImage(systemName: "map")
  static let more               = UIImage(systemName: "ellipsis")
  static let leave              = UIImage(systemName: "rectangle.portrait.and.arrow.right")
  static let edit               = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
  
  static let signOut            = UIImage(systemName: "person.crop.circle.badge.xmark")
}

struct NotificationKeys {
  static let updateUserProfile  = "com.gcsoriap.ChatAppRealm.updateUserProfile"
}

enum ScreenSize {
  static let width                  = UIScreen.main.bounds.size.width
  static let height                 = UIScreen.main.bounds.size.height
  static let maxLength              = max(ScreenSize.width, ScreenSize.height)
  static let minLength              = min(ScreenSize.width, ScreenSize.height)
}

enum DeviceType {
  private static let idiom          = UIDevice.current.userInterfaceIdiom
  static let nativeScale            = UIScreen.main.nativeScale
  static let scale                  = UIScreen.main.scale
  
  static let isiPhoneSE             = idiom == .phone && ScreenSize.maxLength == 568.0
  static let isiPhone8Standard      = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
  static let isiPhone8Zoomed        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
  static let isiPhone8PlusStandard  = idiom == .phone && ScreenSize.maxLength == 736.0
  static let isiPhone8PlusZoomed    = idiom == .phone && ScreenSize.maxLength == 568.0 && nativeScale < scale
  
  static let isiPhoneX              = idiom == .phone && ScreenSize.maxLength == 812.0
  static let isiPhoneXsMaxAndXr     = idiom == .phone && ScreenSize.maxLength == 896.0
  static let isiPhone12Mini         = idiom == .phone && ScreenSize.maxLength == 812.0
  static let isiPhone12And12Pro     = idiom == .phone && ScreenSize.maxLength == 844.0
  static let isiPhone12ProMax       = idiom == .phone && ScreenSize.maxLength == 926.0
  static let isiPad                 = idiom == .pad
  static let isiPad8Gen             = idiom == .pad && ScreenSize.maxLength == 1080.0
  static let isMac                  = idiom == .mac
  
  static func isiPhoneXAspectRatio() -> Bool {
    return isiPhoneX || isiPhoneXsMaxAndXr || isiPhone12Mini || isiPhone12And12Pro || isiPhone12ProMax
  }
  
  static func isiPhoneWithHomeButton() -> Bool {
    return isiPhoneSE || isiPhone8Standard || isiPhone8Zoomed || isiPhone8PlusStandard || isiPhone8PlusZoomed
  }
}
