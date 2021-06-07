//
//  AvatarsGridView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-06.
//

import UIKit

class AvatarsGridView: UIView {
  
  enum Section { case main }
  
  var collectionView: UICollectionView!
  var dataSource: UICollectionViewDiffableDataSource<Section, Chatster>!
  
  var chatsters: [Chatster] = []
  
  convenience init(chatsters: [Chatster]) {
    self.init(frame: .zero)
    self.chatsters = chatsters
    configure()
    configureCollectionView()
    configureDataSource()
    applySnapshot()
  }
  
  private func configure() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .systemBackground
  }
  
  private func configureCollectionView() {
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    addSubview(collectionView)
    collectionView.pinToEdges(of: self)
    collectionView.backgroundColor = .systemBackground
    
    collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: AvatarCell.reuseID)
  }
  
  private func createLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(40), heightDimension: .absolute(40))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.interGroupSpacing = 10
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
  private func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Chatster>(collectionView: collectionView, cellProvider: { collectionView, indexPath, chatster in
      guard
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCell.reuseID,
                                                      for: indexPath) as? AvatarCell else { return nil }
      cell.set(chatster: chatster, online: chatster.presenceState == .onLine ? true : false)
      
      return cell
    })
  }
  
  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Chatster>()
    snapshot.appendSections([.main])
    snapshot.appendItems(chatsters)
    
    dataSource.apply(snapshot)
  }
}
