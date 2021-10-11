//
//  FollowerListView.swift
//  GHFollowers
//
//  Created by Леонид on 01.10.2021.
//

import UIKit

protocol FollowerListViewDelegate: AnyObject {
    func configureSearchController()
    func present(with username: String)
    func load()
}

protocol FollowerListRootView: UIView {
    var delegate: FollowerListViewDelegate? { get set }
    
    func updateData(on followers: [Follower])
    func setFilteredState(with query: String)
    func setUnfilteredState()
    func updateUI(with followers: [Follower])
}

class FollowerListView: UIView {

    weak var delegate: FollowerListViewDelegate?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: self))
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
        
        return collectionView
    }()

    private enum Section { case main }

    private var isSearching                     = false
    private var followers: [Follower]           = []
    private var filteredFollowers: [Follower]   = []

    private var dataSource: UICollectionViewDiffableDataSource<Section, Follower>?
    
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.configure()
            cell.set(follower: follower)
            return cell
        })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        configureDataSource()
        snapshot.appendSections([.main])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FollowerListView: FollowerListRootView {
    func setFilteredState(with query: String) {
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(query.lowercased()) }
        updateData(on: filteredFollowers)
    }
    
    func setUnfilteredState() {
        filteredFollowers.removeAll()
        updateData(on: followers)
        isSearching = false
    }
    
    func updateUI(with followers: [Follower]) {
        self.followers.append(contentsOf: followers)
        updateData(on: followers)
    }
    
    func updateData(on followers: [Follower]) {
        snapshot.appendItems(followers)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataSource?.apply(self.snapshot, animatingDifferences: true)
        }
    }
}


extension FollowerListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray     = isSearching ? filteredFollowers : followers
        let follower        = activeArray[indexPath.item]
        delegate?.present(with: follower.login)
    }
}

extension FollowerListView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard indexPaths.contains(where: isLastElement) else {
            return
        }
        
        delegate?.load()
    }
    
    private func isLastElement(indexPath: IndexPath) -> Bool {
        snapshot.numberOfItems(inSection: .main) == indexPath.row + 1
    }
}
