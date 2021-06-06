//
//  AccountSettingsViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import UIKit

class AccountSettingsViewController: UIViewController {
  private var user: User!
  private var photo: Photo!
  private var isPhotoAdded: Bool = false
  
  private enum Section { case avatar, username }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
  
  init(user: User) {
    super.init(nibName: nil, bundle: nil)
    self.user = user
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
    title = "Account Settings"
    view.backgroundColor = .systemBackground
    
    let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
    navigationItem.leftBarButtonItem = closeButton
    
    let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
    navigationItem.rightBarButtonItem = saveButton
  }
  
  @objc private func closeButtonTapped() {
    self.dismiss(animated: true)
  }
  
  @objc private func saveButtonTapped() {
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
    collectionView.delegate = self
  }
  
  private func configureDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      var configuration = UIListContentConfiguration.cell()
      
      switch indexPath.section {
      case 0:
        if
          let image = self.user.userPreferences?.avatarImage,
          let imageData = image.picture {
          configuration.image = UIImage(data: imageData)
          configuration.imageProperties.maximumSize = CGSize(width: 100, height: 100)
          configuration.imageProperties.cornerRadius = 50
          configuration.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: self.view.frame.width/2 - 70, bottom: 20, trailing: 0)
        }
      case 1:
        guard
          let username = item as? String  else { return }
        configuration.text = username
      default:
        break
      }
      
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
      default:
        break
      }
      
      configuration.textProperties.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
      
      headerView.contentConfiguration = configuration
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { collectionView, indexPath, item in
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
    snapshot.appendSections([.avatar, .username])
    snapshot.appendItems([user.userPreferences?.avatarImage], toSection: .avatar)
    snapshot.appendItems([user.userName], toSection: .username)
    
    dataSource.apply(snapshot)
  }
  
  private func updateSnapshot() {
    let snapshot = dataSource.snapshot()    
  }
}

extension AccountSettingsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath.section == 0 {
      return CGSize(width: view.frame.width, height: 140)
    } else {
      return CGSize(width: view.frame.width, height: 40)
    }
  }
}

extension AccountSettingsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      PhotoCaptureController.show(source: .photoLibrary) { controller, photo in
        self.photo = photo
        self.isPhotoAdded = true
        controller.hide()
      }
    }
  }
}
