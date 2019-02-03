//
//  HomeViewController.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 2/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: SearchViewController {

    // MARK: Constants

    private enum Style {
        static let backgroundColor: UIColor = .white
    }

    // MARK: Views

    private lazy var searchButton: UIButton = {
        let result: UIButton = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.addTarget(self, action: #selector(didPressSearchButton), for: .touchUpInside)
        return result
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.delegate = self

        view.backgroundColor = Style.backgroundColor
        
        view.addSubview(searchButton)

        activateConstraints()
        paginate(page: page)
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            searchButton.boxAnchor.constraints(equalTo: searchTextField.boxAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.contentInset.top = view.safeAreaInsets.top
            + SearchViewController.Layout.fieldSpacing
            + SearchViewController.Layout.fieldHeight
            + SearchViewController.Layout.fieldSpacing

        collectionView.scrollIndicatorInsets.top = view.safeAreaInsets.top
    }

    // MARK: - Class

    private func paginate(page: Int) {
        APIClient.getRecentPhotos(page: page) { [weak self] (result: Result<PagedRecentPhotos>) in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let data):
                self.photos.append(contentsOf: data.photos?.photo ?? [])

                if data.photos?.isLastPage == true {
                    self.isLastPage = true
                } else {
                    self.page += 1
                }

            case .failure:
                break
            }
        }
    }

    // MARK: - Actions

    @objc
    private func didPressSearchButton() {
        navigationController?.pushViewController(PhotoSearchViewController(), animated: true)
    }

}

// MARK: - UINavigationControllerDelegate
extension HomeViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoSearchAnimatedTransitioning(operation)
    }

}
