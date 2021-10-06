//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Леонид on 10.08.2021.
//

import UIKit

class FollowerListVC: GFDataLoadingVC {
    
    private var hasMoreFollowers = true
    
    private lazy var rootView: FollowerListRootView = FollowerListView()
    
    override func loadView() {
        view = rootView
        rootView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFollowers(username: title ?? .init(), page: 0)

        customizeNavBar()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func customizeNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtontapped))
        navigationItem.rightBarButtonItem = addButton
    }

    @objc func addButtontapped() {
        showLoadingView()

        guard let username = title else { return }
       
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let user):
                self.addUserToFavorites(user: user)
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }

    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        title               = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: - viewWillAppear "Loading next 100 followers after delay."
// TODO: add functional of smooth followers loading
    
    
    func addUserToFavorites(user: User) {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] error in
            guard let self = self else { return }
            
            guard let error = error else {
                self.presentGFAlertOnMainThread(title: "Success!", message: "You have successfully favorited this user 🎉", buttonTitle: "Hooray!")
                return
            }
            
            self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
        }
    }
}


extension FollowerListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            rootView.setUnfilteredState()
            return
        }
        
        rootView.setFilteredState(with: filter)
    }
}


extension FollowerListVC: FollowerListViewDelegate {
    
    func present(with username: String) {
        let destVC          = UserInfoVC(userName: username)
        destVC.delegate     = self
        let navController   = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
    
    func configureSearchController() {
        let searchController                                    = UISearchController()
        searchController.searchResultsUpdater                   = self
        searchController.searchBar.placeholder                  = "Search for username"
        searchController.obscuresBackgroundDuringPresentation   = true
        navigationItem.searchController                         = searchController
    }

    func showEmptyView() {
        let message = "This user doesn't have any followers. Go follow them 😀."
        DispatchQueue.main.async { self.showEmptyStateView(with: message, in: self.rootView) }
    }
    
    func getFollowers(username: String, page: Int) {
        showLoadingView()
        
//        rootView.isLoadingMoreFollowers = true
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let followers):
                if followers.count < 100 {
                    self.hasMoreFollowers = false
                    self.showEmptyView()
                } else {
                    self.rootView.updateUI(with: followers)
                }
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Bad Stuff Happened", message: error.rawValue, buttonTitle: "Ok")
            }
            
//            self.rootView.isLoadingMoreFollowers = false
        }
    }
}

extension FollowerListVC: UserInfoVCDelegate {
    
    func didRequestFollowers(for username: String) {
//        rootView.username        = username
//        title                    = username
//        rootView.page            = 1
//
//        rootView.followers.removeAll()
//        rootView.filteredFollowers.removeAll()
//        rootView.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
//
//        getFollowers(username: username, page: rootView.page)
    }
}
