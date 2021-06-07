//
//  SnackBarView.swift
//  CouchPal
//
//  Created by Giuliano Soria Pazos on 2021-02-24.
//

import UIKit

class SnackBarView: UIView {
  
  var stackView = UIStackView()
  var titleLabel = CALabel(textAlignment: .left, fontSize: 13, weight: .semibold, textColor: .label)
  var imageView = CAImageView(frame: .zero)
  var loadingView = UIActivityIndicatorView(style: .medium)
  
  var title: String!
  var image: UIImage!
  
  init(title: String, image: UIImage? = nil, backgroundColor: UIColor, textColor: UIColor = .label) {
    super.init(frame: .zero)
    self.title = title
    self.image = image
    self.backgroundColor = backgroundColor
    self.titleLabel.textColor = textColor
    self.imageView.tintColor = textColor
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configure() {
    clipsToBounds = true
    layer.cornerRadius = 20
    layer.cornerCurve = .circular
    layer.masksToBounds = true
    tag = -1
    
    addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fillProportionally
    stackView.spacing = 10
    stackView.insetsLayoutMarginsFromSafeArea = true
    
    if let image = image {
      imageView.contentMode = .scaleAspectFit
      imageView.layer.cornerRadius = 0
      imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
      imageView.image = image
      stackView.addArrangedSubview(imageView)
    } else {
      loadingView.translatesAutoresizingMaskIntoConstraints = false
      loadingView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
      loadingView.color = self.imageView.tintColor
      loadingView.widthAnchor.constraint(equalToConstant: 25).isActive = true
      loadingView.startAnimating()
      stackView.addArrangedSubview(loadingView)
    }
    
    titleLabel.text = title
    titleLabel.numberOfLines = 0
    stackView.addArrangedSubview(titleLabel)
  }
}
