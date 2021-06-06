//
//  CAImageView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

class CAImageView: UIImageView {
  let activityIndicator = UIActivityIndicatorView(style: .medium)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configure() {
    layer.cornerRadius = 10
    
    contentMode = .scaleAspectFill
    clipsToBounds = true
    
    translatesAutoresizingMaskIntoConstraints = false
  }

  func downloadMediaImage(completed: ((UIImage?) -> Void)? = nil) {
    showLoadingIndicator()
//    NetworkManager.shared.downloadImage(width: width, path: path, mediaType: mediaType) { [weak self] image in
//      guard let self = self else { return }
//      DispatchQueue.main.async {
//        self.dismissLoadingIndicator()
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
//          guard let self = self else { return }
//          self.image = image
//          completed?(image)
//        }
//      }
//    }
  }
  
  func showLoadingIndicator() {
    activityIndicator.color = .label
    
    addSubview(activityIndicator)
    activityIndicator.pinToEdges(of: self)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.startAnimating()
  }
  
  func dismissLoadingIndicator() {
    DispatchQueue.main.async {
      self.activityIndicator.stopAnimating()
      self.activityIndicator.removeFromSuperview()
    }
  }
}
