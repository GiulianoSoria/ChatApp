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
  
  convenience init(photo: Photo? = nil, cornerRadius: CGFloat) {
    self.init(frame:. zero)
    configure()
    self.set(photo: photo, cornerRadius: cornerRadius)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(photo: Photo? = nil, cornerRadius: CGFloat) {
    if
      let photo = photo,
      let imageData = photo.picture {
      image = UIImage(data: imageData)
    } else {
      let configuration = UIImage.SymbolConfiguration(pointSize: 150)
      image = UIImage(systemName: "person.crop.circle",
                      withConfiguration: configuration)
    }
    layer.cornerRadius = cornerRadius
  }
  
  @objc func imageTapped() {
    delegate.thumbnailTapped()
  }
  
  private func configure() {
    layer.cornerCurve = .circular
    layer.backgroundColor = .none
    isUserInteractionEnabled = true
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
    addGestureRecognizer(tap)
  }
}
