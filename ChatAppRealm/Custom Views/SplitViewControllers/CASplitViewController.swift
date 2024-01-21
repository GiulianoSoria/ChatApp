//
//  CASplitViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-07-06.
//

import RealmSwift
import UIKit

class CASplitViewController: UISplitViewController {
  private var state: AppState!
  
	init(state: AppState) {
    super.init(style: .doubleColumn)
    self.state = state
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
  }
  
  private func configureViewController() {
    view.backgroundColor = .systemBackground
    primaryBackgroundStyle = .sidebar
    preferredDisplayMode = .automatic
    preferredSplitBehavior = .displace
    
    setViewController(createConversationsListViewController(isCompact: true),
                      for: .compact)
    setViewController(createConversationsListViewController(isCompact: false),
                      for: .primary)
    
    maximumPrimaryColumnWidth = 400
    minimumPrimaryColumnWidth = 400
    
    viewControllers = [createConversationsListViewController(isCompact: false), UIViewController()]
  }
  
  private func createConversationsListViewController(isCompact: Bool) -> UINavigationController {
    let conversationsListVC = ConversationsListViewController(
			state: state,
			isCompact: isCompact
		)
    
    let navController = UINavigationController(rootViewController: conversationsListVC)
    
    return navController
  }
}
