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
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}
