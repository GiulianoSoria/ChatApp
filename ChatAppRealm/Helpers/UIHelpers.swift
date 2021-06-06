//
//  UIHelpers.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

struct UIHelpers {
  public static func showSnackBar(title: String,
                                  image: UIImage? = nil,
                                  backgroundColor: UIColor,
                                  textColor: UIColor = .label,
                                  view: UIView) {
    DispatchQueue.main.async {
      let snackBar = SnackBarView(title: title,
                                  image: image,
                                  backgroundColor: backgroundColor,
                                  textColor: textColor)
      UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(snackBar)
      
      let textWidth = title.estimateFrameFor(width: 200, fontSize: 13, fontWeight: .semibold).width
      let width = textWidth + 80
      snackBar.frame = CGRect(
        x: (view.frame.size.width - width)/2,
        y: -40,
        width: width,
        height: 40)
      
      DispatchQueue.main.async {
        UIView.animate(withDuration: 0.5) {
          snackBar.frame = CGRect(
            x: (view.frame.size.width - width)/2,
            y: 60,
            width: width,
            height: 40)
        }
      }
    }
  }
  
  public static func hideSnackBar(title: String,
                                  image: UIImage? = nil,
                                  backgroundColor: UIColor,
                                  textColor: UIColor = .label,
                                  view: UIView) {
    DispatchQueue.main.async {
      if
        let snackBar = UIApplication.shared.windows
          .first(where: { $0.isKeyWindow })?.subviews
          .first(where: { $0.backgroundColor == .secondarySystemBackground }) {
        UIView.animate(withDuration: 0.5, animations: {
          snackBar.frame = CGRect(x: (view.frame.size.width - snackBar.frame.width)/2,
                                  y: -40,
                                  width: snackBar.frame.width,
                                  height: 40)
        }) { finished in
          if finished {
            snackBar.removeFromSuperview()
          }
        }
      }
    }
  }
  
  public static func autoDismissableSnackBar(title: String,
                                             image: UIImage? = nil,
                                             backgroundColor: UIColor,
                                             textColor: UIColor = .label,
                                             view: UIView) {
    DispatchQueue.main.async {
      let snackBar = SnackBarView(title: title,
                                  image: image,
                                  backgroundColor: backgroundColor,
                                  textColor: textColor)
      UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(snackBar)
      
      let textWidth = title.estimateFrameFor(width: 200, fontSize: 13, fontWeight: .semibold).width
      let width = textWidth + 80
      snackBar.frame = CGRect(
        x: (view.frame.size.width - width)/2,
        y: -40,
        width: width,
        height: 40)
      
      UIView.animate(withDuration: 0.5, animations: {
        snackBar.frame = CGRect(
          x: (view.frame.size.width - width)/2,
          y: 60,
          width: width,
          height: 40)
      }) { done in
        if done {
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: {
              snackBar.frame = CGRect(
                x: (view.frame.size.width - width)/2,
                y: -40,
                width: width,
                height: 40)
            }) { finished in
              if finished {
                snackBar.removeFromSuperview()
              }
            }
          }
        }
      }
    }
  }
}
