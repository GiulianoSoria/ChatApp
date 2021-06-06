//
//  ThumbnailView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

protocol ThumbnailViewDelegate: AnyObject {
  func thumbnailTapped()
}

class ThumbnailView: CAImageView {
  var photo: Photo!
  
  weak var delegate: ThumbnailViewDelegate!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(photo: Photo) {
    if
      let imageData = photo.picture {
      image = UIImage(data: imageData)
    }
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
    addGestureRecognizer(tap)
  }
  
  @objc func imageTapped() {
    delegate.thumbnailTapped()
  }
  
  private func configure() {
    layer.cornerRadius = 20
    layer.cornerCurve = .circular
    layer.backgroundColor = .none
    isUserInteractionEnabled = true
  }
}
