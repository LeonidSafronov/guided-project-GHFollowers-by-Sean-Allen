//
//  SearchVC.swift
//  GHFollowers
//
//  Created by Леонид on 08.08.2021.
//

import UIKit

class SearchVC: UIViewController {
    
    private lazy var rootView = SearchView()
    
    override func loadView() {
        view = rootView
        rootView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootView.clearTextField()
    }
}


extension SearchVC: SearchViewDelegate {
    func goToFollowerList(with name: String) {
        
        let followerListVC = FollowerListVC(username: name)
        navigationController?.pushViewController(followerListVC, animated: true)
    }
    
    func showError() {
        presentGFAlertOnMainThread(title: "Empty Username", message: "Please enter a username. We need to know who to look for 😀.", buttonTitle: "Ok")
    }
}
