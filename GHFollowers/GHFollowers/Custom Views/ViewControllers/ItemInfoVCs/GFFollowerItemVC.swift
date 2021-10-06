//
//  GFFollowerItemVC.swift
//  GHFollowers
//
//  Created by Леонид on 29.09.2021.
//

import UIKit

protocol GFFollowersItemVCDelegate: AnyObject {
    func didTapGetFollowers(for user: User)
}


class GFFollowerItemVC: GFItemInfoVC {
    
    weak var delegate: GFFollowersItemVCDelegate!
    

    init(user: User, delegate: GFFollowersItemVCDelegate) {
        super.init(user: user)
        self.delegate = delegate
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewTwo.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(backgroundColor: .systemGreen, title: "Get Followers")
    }
    
    
    override func actionButtonTapped() {
        delegate.didTapGetFollowers(for: user)
    }
}


extension GFFollowerItemVC {
    
}
