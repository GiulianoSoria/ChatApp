//
//  CATextField.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-04.
//

import UIKit

class CATextField: UITextField {
  var title: String!
  var showingSecureField = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(placeholder: String, showingSecureField: Bool) {
    self.placeholder = placeholder
    isSecureTextEntry = showingSecureField ? true : false
  }
  
  private func configure() {
    translatesAutoresizingMaskIntoConstraints = false
    
    font = UIFont.rounded(ofSize: 16, weight: .regular)
    borderStyle = .roundedRect
    backgroundColor = .secondarySystemBackground
  }
}
