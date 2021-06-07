//
//  UIViewController+Extensions.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-06.
//

import UIKit

extension UIViewController {
  public func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  public func hideKeyboardWhenSwipedDownAround() {
    let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    swipe.direction = .down
    swipe.cancelsTouchesInView = false
    view.addGestureRecognizer(swipe)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}
