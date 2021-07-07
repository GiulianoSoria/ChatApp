//
//  CASplitViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-07-06.
//

import RealmSwift
import UIKit

class CASplitViewController: UISplitViewController {
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  private func configureViewController() {
    view.backgroundColor = .systemBackground
//    setViewController(ConversationsListViewController(state: <#T##AppState#>,
//                                     isCompact: <#T##Bool#>),
//                      for: .primary)
//    setViewController(ChatroomViewController(state: <#T##AppState#>,
//                                             userRealm: <#T##Realm#>,
//                                             conversation: <#T##Conversation#>,
//                                             chatsters: <#T##Results<Chatster>#>),
//                      for: .secondary)
    
    maximumPrimaryColumnWidth = 400
    minimumPrimaryColumnWidth = 400
    
  }
}
