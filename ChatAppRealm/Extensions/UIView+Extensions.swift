//
//  UIView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

extension UIView {
  func addSubviews(_ views: UIView...) {
    views.forEach { self.addSubview($0) }
  }
  
  func pinToEdges(of superview: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: superview.topAnchor),
      leadingAnchor.constraint(equalTo: superview.leadingAnchor),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor),
      bottomAnchor.constraint(equalTo: superview.bottomAnchor)
    ])
  }
  
  func pinToSafeEdges(of superview: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
      leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
      trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor),
      bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
}
