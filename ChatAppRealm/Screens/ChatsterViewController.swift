//
//  ChatsterViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-11.
//

import RealmSwift
import UIKit

class ChatsterViewController: UIViewController {
  private enum Section { case avatar, username, lastSeenAt, conversations }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, String>!
  
  var chatster: Chatster!
  
  init(chatster: Chatster) {
    super.init(nibName: nil, bundle: nil)
    self.chatster = chatster
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
    configureCollectionView()
    configureDataSource()
    applySnapshot()
  }
  
  private func configureViewController() {
    view.backgroundColor = .systemBackground
    
    let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                      target: self,
                                      action: #selector(closeButtonTapped))
    navigationItem.leftBarButtonItem = closeButton
  }
  
  @objc private func closeButtonTapped() {
    self.dismiss(animated: true)
  }
  
  private func configureCollectionView() {
    var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    configuration.backgroundColor = .systemBackground
    configuration.headerMode = .supplementary
    
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.addSubview(collectionView)
    collectionView.pinToEdges(of: view)
    collectionView.backgroundColor = .systemBackground
  }
  
  private func configureDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { [weak self] cell, indexPath, itemIdentifier in
      guard
        let self = self,
        let chatster = self.chatster else { return }
      
      var configuration = UIListContentConfiguration.cell()
      switch indexPath.section {
      case 0:
        if let imageData = chatster.avatarImage?.picture {
          configuration.image = UIImage(data: imageData)
        } else {
          configuration.image = SFSymbols.personCircle
          configuration.imageProperties.preferredSymbolConfiguration = .init(pointSize: 100)
        }
        
        let width = DeviceType.isiPad ? 200 : 100
        configuration.imageProperties.maximumSize = CGSize(width: width, height: width)
        configuration.imageProperties.cornerRadius = 50
        configuration.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20,
                                                                         leading: self.view.frame.width/2 - 70,
                                                                         bottom: 20,
                                                                         trailing: 0)
        
      case 1:
        configuration.text = chatster.displayName
      case 2:
        configuration.text = chatster.lastSeenAt?.convertToFullDateFormat() ?? "N/A"
      default:
        break
      }
      
      configuration.textProperties.font = UIFont.rounded(ofSize: 16, weight: .regular)
      cell.contentConfiguration = configuration
      cell.backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
      cell.backgroundColor = indexPath.section == 0 ? .systemBackground : .secondarySystemBackground
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
      var configuration = UIListContentConfiguration.groupedHeader()
      
      switch indexPath.section {
      case 0:
        configuration.text = "Avatar Image"
      case 1:
        configuration.text = "Username"
      case 2:
        configuration.text = "Last Activity"
      default:
        break
      }
      
      configuration.textProperties.font = UIFont.rounded(ofSize: 13, weight: .semibold)
      headerView.contentConfiguration = configuration
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) { collectionView, indexPath, user in
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: user)
    }
    
    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath -> UICollectionReusableView? in
      if elementKind == UICollectionView.elementKindSectionHeader {
        return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
      } else {
        return nil
      }
    }
  }
  
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
    snapshot.appendSections([.avatar, .username, .lastSeenAt])
    snapshot.appendItems([UUID().uuidString], toSection: .avatar)
    snapshot.appendItems([UUID().uuidString], toSection: .username)
    snapshot.appendItems([UUID().uuidString], toSection: .lastSeenAt)
    
    dataSource.apply(snapshot)
  }
}

