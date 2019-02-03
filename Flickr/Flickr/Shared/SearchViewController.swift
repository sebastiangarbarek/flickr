//
//  SearchViewController.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 3/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit
import DeepDiff

class SearchViewController: UIViewController {

    // MARK: - Constants

    enum Style {
        static let fieldAnimationDuration: TimeInterval = 0.2
        static let gradientAlpha: CGFloat = 0.5
    }

    enum Layout {
        static let gridSpacing: CGFloat = 8.0
        static let fieldSpacing: CGFloat = 16.0
        static let fieldHeight: CGFloat = 44.0
    }

    private enum Strings {
        static let searchPlaceholder: String = NSLocalizedString("homeSearchPlaceholder", value: "Search", comment: "Search placeholder.")
    }

    // MARK: - Views

    let loadingView: LoadingView = {
        let result: LoadingView = LoadingView()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    let searchTextField: SearchTextField = {
        let result: SearchTextField = SearchTextField()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.placeholder = Strings.searchPlaceholder
        return result
    }()

    lazy var collectionView: UICollectionView = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = Layout.gridSpacing
        flowLayout.minimumInteritemSpacing = Layout.gridSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: Layout.gridSpacing, left: Layout.gridSpacing, bottom: Layout.gridSpacing, right: Layout.gridSpacing)

        let result: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.delegate = self
        result.dataSource = self
        result.register(PhotoCell.self, forCellWithReuseIdentifier: String(describing: PhotoCell.self))
        result.backgroundColor = .clear
        result.contentInsetAdjustmentBehavior = .never
        return result
    }()

    private var whiteView: UIView = {
        let result: UIView = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.alpha = Style.gradientAlpha
        result.backgroundColor = .white
        return result
    }()

    private var gradientLayer: CAGradientLayer = {
        let result = CAGradientLayer()
        result.colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.0).cgColor]
        return result
    }()

    private lazy var gradientView: UIView = {
        let result: UIView = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.alpha = Style.gradientAlpha
        result.layer.addSublayer(gradientLayer)
        result.isUserInteractionEnabled = false
        return result
    }()

    // MARK: - Variables

    var page: Int = 1
    var isLastPage: Bool = false

    private var _photos: [Photo] = []
    var photos: [Photo] = [] {
        willSet {
            loadingView.isHidden = true

            let oldPhotos = photos
            let changes = diff(old: oldPhotos, new: newValue)

            collectionView.reload(changes: changes, section: 0, updateData: {
                _photos = newValue
            }, completion: nil)
        }
    }

    private var lastContentOffset: CGFloat = 0.0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        view.addSubview(whiteView)
        view.addSubview(gradientView)
        view.addSubview(searchTextField)
        view.addSubview(loadingView)

        activateConstraints()
        dismissKeyboardOnTap()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.fieldSpacing),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.fieldSpacing),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.fieldSpacing),
            searchTextField.heightAnchor.constraint(equalToConstant: Layout.fieldHeight),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            whiteView.topAnchor.constraint(equalTo: view.topAnchor),
            whiteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            whiteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            whiteView.bottomAnchor.constraint(equalTo: gradientView.topAnchor),
            gradientView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.heightAnchor.constraint(equalTo: searchTextField.heightAnchor, constant: Layout.fieldSpacing * 2.0),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.sizeAnchor.constraints(equalTo: CGSize(width: 24.0, height: 24.0))
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientLayer.frame = gradientView.bounds
    }

    @discardableResult
    func dismissKeyboardOnTap(_ view: UIView? = nil) -> UITapGestureRecognizer {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapToDismissKeyboard))
        tapGestureRecognizer.delegate = self
        let targetView: UIView = view ?? self.view
        targetView.addGestureRecognizer(tapGestureRecognizer)
        return tapGestureRecognizer
    }

    // MARK: - Actions

    @objc
    func didTapToDismissKeyboard() -> Bool {
        return view.endEditing(true)
    }
    
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCell.self), for: indexPath) as! PhotoCell

        cell.photo = _photos[indexPath.row]

        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidthPadding: CGFloat = Layout.gridSpacing * 3.0
        let width: CGFloat = collectionView.frame.width - totalWidthPadding
        let totalHeightPadding: CGFloat = Layout.gridSpacing * 3.0
        let height: CGFloat = collectionView.frame.height - totalHeightPadding
        return CGSize(width: width / 2.0, height: height / 2.0)
    }

}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: PhotoCell = collectionView.cellForItem(at: indexPath) as? PhotoCell, cell.thumbnail != nil || cell.image != nil else {
            return
        }

        let viewController: PhotoViewController = PhotoViewController(photo: _photos[indexPath.row], thumbnail: cell.thumbnail, image: cell.image)

        navigationController?.present(viewController, animated: true, completion: nil)
    }

}

// MARK: - UIGestureRecognizerDelegate
extension SearchViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if searchTextField.isFirstResponder {
            return true
        }

        return false
    }

}

// MARK: - UIScrollViewDelegate
extension SearchViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if lastContentOffset > scrollView.contentOffset.y
            && lastContentOffset < scrollView.contentSize.height - scrollView.frame.height {
            UIView.animate(withDuration: SearchViewController.Style.fieldAnimationDuration) {
                self.searchTextField.alpha = 1.0
            }
        }

        if lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y > 0 {
            UIView.animate(withDuration: SearchViewController.Style.fieldAnimationDuration) {
                self.searchTextField.alpha = 0.0
            }
        }

        lastContentOffset = scrollView.contentOffset.y
    }

}
