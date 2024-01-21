//
//  EmptyStateView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2024-01-20.
//

import UIKit

class EmptyStateView: UIView {
	var messageLabel = CALabel(
		textAlignment: .center,
		fontSize: 14,
		weight: .regular,
		textColor: .secondaryLabel
	)
	var imageView = CAImageView(frame: .zero)
	
	convenience init(message: String, imageName: String) {
		self.init(frame: .zero)
		configure()
		set(message: message, imageName: imageName)
	}
	
	private func set(message: String, imageName: String) {
		messageLabel.text = message
		imageView.image = .init(systemName: imageName)
	}
	
	private func configure() {
		addSubviews(messageLabel, imageView)
		
		imageView.tintColor = .secondaryLabel
		
		NSLayoutConstraint.activate([
			messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			messageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
			messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 16),
			
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
			imageView.widthAnchor.constraint(equalToConstant: 50),
			imageView.heightAnchor.constraint(equalToConstant: 50)
		])
	}
}
