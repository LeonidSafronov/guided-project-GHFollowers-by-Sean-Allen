//
//  SearchView.swift
//  GHFollowers
//
//  Created by Леонид on 01.10.2021.
//

import UIKit

protocol SearchViewDelegate: AnyObject {
    func goToFollowerList(with name: String)
    func showError()
}

class SearchView: UIView {

    weak var delegate: SearchViewDelegate?
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Images.ghLogo
        return imageView
    }()

    private lazy var usernameTextField: GFTextField = {
        let textField = GFTextField()
        textField.delegate = self
        return textField
    }()

    private lazy var callToActionButton: GFButton = {
        let button = GFButton()
        button.set(backgroundColor: .systemGreen, title: "Get Followers")
        button.addTarget(self, action: #selector(pushFollowerListVC), for: .touchUpInside)
        return button
    }()
    
    
    @objc func pushFollowerListVC() {
        guard let name = usernameTextField.text, !name.isEmpty else {
            delegate?.showError()
            return
        }

        usernameTextField.resignFirstResponder()
        
        delegate?.goToFollowerList(with: name)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        addSubviews(logoImageView, usernameTextField, callToActionButton)

        configureLogoImageView()
        configureTextField()
        configureCallToActionButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func clearTextField() {
        usernameTextField.text = nil
    }

    
    private func configureLogoImageView() {
        let topConstraintConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? 20 : 80
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: topConstraintConstant),
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    
    private func configureTextField() {
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 48),
            usernameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    private func configureCallToActionButton() {
        NSLayoutConstraint.activate([
            callToActionButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            callToActionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            callToActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}


extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFollowerListVC()
        return true
    }
}
