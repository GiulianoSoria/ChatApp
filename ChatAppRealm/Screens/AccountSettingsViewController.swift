//
//  AccountSettingsViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-05.
//

import RealmSwift
import UIKit

protocol AccountsSettingsViewControllerDelegate: AnyObject {
  func showLoginViewController()
}

class AccountSettingsViewController: UIViewController {
  private var state: AppState!
  private var userRealm: Realm!
  
  weak var delegate: AccountsSettingsViewControllerDelegate!
  
  private var displayName = ""
  private var photo: Photo!
  private var isPhotoAdded: Bool = false
  
  private enum Section { case avatar, username, logOut }
  
  private var collectionView: UICollectionView!
  private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
  private var textField: CATextField!
  private var logOutButton: CAButton!
  
  init(state: AppState, userRealm: Realm) {
    super.init(nibName: nil, bundle: nil)
    self.state = state
    self.photo = state.user?.userPreferences?.avatarImage
    self.displayName = state.user?.userPreferences?.displayName ?? ""
    self.userRealm = userRealm
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
    
    let closeButton = UIBarButtonItem(barButtonSystemItem: .close,
                                      target: self,
                                      action: #selector(closeButtonTapped))
    closeButton.isEnabled = state.user?.userPreferences?.displayName != "" && state.user?.userPreferences?.avatarImage != nil
    navigationItem.leftBarButtonItem = closeButton
    
    let saveButton = UIBarButtonItem(title: "Save",
                                     style: .done,
                                     target: self,
                                     action: #selector(saveButtonTapped))
    navigationItem.rightBarButtonItem = saveButton
  }
  
  @objc private func closeButtonTapped() {
    self.dismiss(animated: true)
  }
  
  @objc private func saveButtonTapped() {
    state.shouldIndicateActivity = true
    do {
      try userRealm.write {
        state.user?.userPreferences?.displayName = displayName
        if isPhotoAdded {
          guard
            let newPhoto = photo else {
              print("Missing Photo")
              state.shouldIndicateActivity = false
              return
            }
          
          state.user?.userPreferences?.avatarImage = newPhoto
          let info = ["photo": newPhoto]
					NotificationCenter.default.post(
						name: .updateUserProfile,
						object: nil,
						userInfo: info
					)
        }
        state.user?.presenceState = .onLine
      }
      self.dismiss(animated: true)
    } catch {
      state.error = "Unable to open Realm write transaction"
    }
    state.shouldIndicateActivity = false
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
    collectionView.keyboardDismissMode = .onDrag
    collectionView.delegate = self
  }
  
  private func configureDataSource() {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      var configuration = UIListContentConfiguration.cell()
      
      switch indexPath.section {
      case 0:
        let imageView: ThumbnailView!
        if
          let image = self.photo {
					imageView = .init(
						photo: image,
						cornerRadius: DeviceType.isiPad || DeviceType.isMac ? 100 : 50
					)
        } else {
					imageView = .init(cornerRadius: DeviceType.isiPad || DeviceType.isMac ? 100 : 50)
        }
        imageView.delegate = self
        
        configuration.image = imageView.image
				let width = DeviceType.isiPad || DeviceType.isMac ? 200 : 100
				configuration.imageProperties.maximumSize = .init(width: width, height: width)
				configuration.imageProperties.cornerRadius = DeviceType.isiPad || DeviceType.isMac ? 100 : 50
				configuration.directionalLayoutMargins = .init(
					top: 20,
					leading: self.view.frame.width/2 - 70,
					bottom: 20,
					trailing: 0
				)
        cell.accessories = []
      case 1:
        cell.accessories = [.customView(configuration: self.configureTextField(in: cell))]
      case 2:
        cell.accessories = [.customView(configuration: self.configureLogOutButton(in: cell))]
      default:
        break
      }
      
      cell.contentConfiguration = configuration
      cell.backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
      cell.backgroundColor = indexPath.section == 0 
			? .systemBackground
			: (indexPath.section == 1 ? .secondarySystemBackground : .systemRed)
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
			elementKind: UICollectionView.elementKindSectionHeader
		) { headerView, elementKind, indexPath in
      var configuration = UIListContentConfiguration.groupedHeader()
      switch indexPath.section {
      case 0:
        configuration.text = "Avatar Image"
      case 1:
        configuration.text = "Display Name"
      default:
        break
      }
      
      configuration.textProperties.font = UIFont.rounded(ofSize: 13, weight: .semibold)
      
      headerView.contentConfiguration = configuration
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(
			collectionView: collectionView
		) { collectionView, indexPath, item in
      return collectionView.dequeueConfiguredReusableCell(
				using: cellRegistration,
				for: indexPath,
				item: item
			)
    }
    
    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath -> UICollectionReusableView? in
      if elementKind == UICollectionView.elementKindSectionHeader {
        return collectionView.dequeueConfiguredReusableSupplementary(
					using: headerRegistration,
					for: indexPath
				)
      } else {
        return nil
      }
    }
  }
  
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
    snapshot.appendSections([.avatar, .username, .logOut])
    snapshot.appendItems([photo], toSection: .avatar)
    snapshot.appendItems([""], toSection: .username)
    snapshot.appendItems(["Log Out"], toSection: .logOut)
    
    dataSource.apply(snapshot)
  }
  
  private func updateSnapshot() {
    var snapshot = dataSource.snapshot()
    let section = snapshot.sectionIdentifiers[0]
    snapshot.reloadSections([section])
    
    dataSource.apply(snapshot)
  }
  
  private func configureTextField(in cell: UICollectionViewListCell) -> UICellAccessory.CustomViewConfiguration {
    textField = CATextField(frame: .zero)
    textField.translatesAutoresizingMaskIntoConstraints = true
    textField.borderStyle = .none
    textField.placeholder = "Enter display name"
    textField.text = displayName
    textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
		textField.frame = .init(
			x: 0,
			y: 0,
			width: cell.contentView.frame.width - 40,
			height: cell.contentView.frame.height
		)
		
		let placement = UICellAccessory.Placement.leading(
			displayed: .always,
			at: UICellAccessory.Placement.position(before: .disclosureIndicator())
		)
		let width = UICellAccessory.LayoutDimension.actual
		let configuration = UICellAccessory.CustomViewConfiguration(
			customView: textField,
			placement: placement,
			isHidden: false,
			reservedLayoutWidth: width,
			tintColor: .tintColor,
			maintainsFixedSize: false
		)
    
    return configuration
  }
  
  @objc private func textFieldDidChange(_ textField: UITextField) {
    if
      let text = textField.text {
      displayName = text
      navigationItem.leftBarButtonItem?.isEnabled = state.user?.userPreferences?.displayName != "" && state.user?.userPreferences?.avatarImage != nil
    } else {
      navigationItem.leftBarButtonItem?.isEnabled = false
    }
  }
  
  private func configureLogOutButton(in cell: UICollectionViewListCell) -> UICellAccessory.CustomViewConfiguration {
    logOutButton = CAButton()
    logOutButton.translatesAutoresizingMaskIntoConstraints = true
		logOutButton.frame = .init(
			x: 0,
			y: 0,
			width: cell.contentView.frame.width - 40,
			height: cell.contentView.frame.height
		)
    logOutButton.set(
			activeImage: .signOut,
			inactiveImage: .signOut,
			title: "Log Out",
			backgroundColor: .systemRed,
			active: true
		)
    logOutButton.titleLabel?.textAlignment = .center
    logOutButton.titleLabel?.font = UIFont.rounded(ofSize: 16, weight: .semibold)
    logOutButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    
    let width = UICellAccessory.LayoutDimension.actual
    let placement = UICellAccessory.Placement.leading(
			displayed: .always,
			at: UICellAccessory.Placement.position(before: .disclosureIndicator())
		)

		let configuration = UICellAccessory.CustomViewConfiguration(
			customView: logOutButton,
			placement: placement,
			reservedLayoutWidth: width,
			tintColor: .white,
			maintainsFixedSize: true
		)
    
    return configuration
  }
  
  @objc private func logOut() {
		Task {
			do {
				try await state.logout()
				
				dismiss(animated: true) {
					self.delegate.showLoginViewController()
				}
			} catch {
				print(error.localizedDescription)
			}
		}
//    state.shouldIndicateActivity = true
//    do {
//      try userRealm.write {
//        state.user?.presenceState = .offLine
//      }
//    } catch {
//      state.error = "Unable to open Realm write transaction"
//    }
//    
//		Task {
//			do {
//				try await state.app.currentUser?.logOut()
//				self.savePreferences()
//			} catch {
//				print(error.localizedDescription)
//			}
//		}
//    state.app.currentUser?.logOut()
//      .receive(on: DispatchQueue.main)
//      .sink(receiveCompletion: { _ in
//      }, receiveValue: { [weak self] value in
//        guard let self = self else { return }
//        self.state.shouldIndicateActivity = false
//        self.state.logoutPublisher.send(value)
//      })
//      .store(in: &state.subscribers)
  }
  
//  private func savePreferences() {
//    let preference = Preferences(isUserLoggedIn: false)
//		
//		do {
//			try PersistenceManager.shared.updatePreferences(
//				preference: preference,
//				types: [.isUserLoggedIn]
//			)
//			
//		} catch {
//			print(error.localizedDescription)
//		}
//  }
}

extension AccountSettingsViewController: UICollectionViewDelegate {
  func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
    switch indexPath.section {
    case 0:
      thumbnailTapped()
    case 2:
      logOut()
    default:
      break
    }
  }
}

extension AccountSettingsViewController: ThumbnailViewDelegate {
  func thumbnailTapped() {
    PhotoCaptureController.show(source: .photoLibrary) { [weak self] controller, photo in
      guard let self = self else { return }
      self.photo = photo
      self.isPhotoAdded = true
      self.updateSnapshot()
      self.textFieldDidChange(self.textField)
      controller.hide()
    }
  }
}
