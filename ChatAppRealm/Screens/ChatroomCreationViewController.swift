//
//  ChatroomCreationViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-08.
//

import UIKit

class ChatroomCreationViewController: UIViewController {
  private enum Section { case title, selected, all }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
  
  private var selected: [Chatster] = []
  private var all: [Chatster] = []
  
  init(chatsters: [Chatster]) {
    super.init(nibName: nil, bundle: nil)
    self.all = chatsters
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
    title = "New Chatroom"
    view.backgroundColor = .systemBackground
    
    let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
    navigationItem.leftBarButtonItem = closeButton
    
    let doneButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(doneButtonTapped))
    navigationItem.rightBarButtonItem = doneButton
  }
  
  @objc private func closeButtonTapped() {
    self.dismiss(animated: true)
  }
  
  @objc private func doneButtonTapped() {
    print(#function)
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
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyHashable> { cell, indexPath, item in
      var configuration = UIListContentConfiguration.cell()
      switch indexPath.section {
      case 0:
        configuration.text = ""
      case 1:
        let chatster = self.selected[indexPath.item]
        configuration.text = chatster.userName
      case 2:
        let chatster = self.all[indexPath.item]
        configuration.text = chatster.userName
      default:
        break
      }
      
      cell.contentConfiguration = configuration
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
      var configuration: UIListContentConfiguration!
      
      if #available(iOS 15.0, *) {
        configuration = UIListContentConfiguration.prominentInsetGroupedHeader()
      } else {
        configuration = UIListContentConfiguration.sidebarHeader()
      }
      
      switch indexPath.section {
      case 0:
        configuration.text = "Chatroom Title"
      case 1:
        configuration.text = "Selected Users"
      case 2:
        configuration.text = "Available users"
      default:
        break
      }
      
      headerView.contentConfiguration = configuration
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { collectionView, indexPath, item in
      switch indexPath.section {
      case 0:
        break
      case 1:
        break
      case 2:
        break
      default:
        break
      }
      
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
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
    var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
    snapshot.appendSections([.title, .selected, .all])
    snapshot.appendItems([""], toSection: .title)
    snapshot.appendItems(selected, toSection: .selected)
    snapshot.appendItems(all, toSection: .all)
    
    dataSource.apply(snapshot)
  }
}
