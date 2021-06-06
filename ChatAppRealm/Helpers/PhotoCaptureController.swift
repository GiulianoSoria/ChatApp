//
//  PhotoCaptureController.swift
//  ChatApp
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import RealmSwift
import SwiftUI
import UIKit

class PhotoCaptureController: UIImagePickerController {
  private var photoTaken: ((PhotoCaptureController, Photo) -> Void)?
  private var photo = Photo()
  private let imageSizeThumbnails: CGFloat = 102
  private let maximumImageSize = 1024 * 1024 // 1 MB
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
  
  static func show(source: UIImagePickerController.SourceType,
                   photoToEdit: Photo = Photo(),
                   photoTaken: ((PhotoCaptureController, Photo) -> Void)? = nil) {
    let picker = PhotoCaptureController()
    picker.photo = photoToEdit
    picker.setup(source)
    picker.photoTaken = photoTaken
    picker.present()
  }
  
  func setup(_ requestedSource: UIImagePickerController.SourceType) {
    if PhotoCaptureController.isSourceTypeAvailable(.camera) && requestedSource == .camera {
      sourceType = .camera
    } else {
      print("Camera not found - using photo library instead")
      sourceType = .photoLibrary
    }
    allowsEditing = true
    delegate = self
  }
  
  func present() {
    var topMostViewController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController
    
    while let presentedViewController = topMostViewController?.presentedViewController {
      topMostViewController = presentedViewController
    }
    
    topMostViewController?.present(self, animated: true)
  }
  
  func hide() {
    photoTaken = nil
    dismiss(animated: true)
  }
  
  private func compressImageIfNeeded(image: UIImage) -> UIImage? {
    let resultImage = image
    
    if let data = resultImage.jpegData(compressionQuality: 1) {
      if
        data.count > maximumImageSize {
        let neededQuality = CGFloat(maximumImageSize) / CGFloat(data.count)
        if
          let resized = resultImage.jpegData(compressionQuality: neededQuality),
          let resultImage = UIImage(data: resized) {
          return resultImage
        } else {
          print("Failed to resize image")
        }
      }
    }
    
    return resultImage
  }
}

extension PhotoCaptureController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard
      let editedImage = info[.editedImage] as? UIImage,
      let result = compressImageIfNeeded(image: editedImage) else {
      print("Could not get the camera/library image")
      return
    }
    
    photo.date = Date()
    photo.picture = result.jpegData(compressionQuality: 0.8)
    photo.thumbNail = result.thumbnail(size: imageSizeThumbnails)?.jpegData(compressionQuality: 0.8)
    photoTaken?(self, photo)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    hide()
  }
}
