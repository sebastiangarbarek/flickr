//
//  PhotoViewController.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 2/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit
import Alamofire

class PhotoViewController: UIViewController {

    // MARK: - Constants

    private enum Style {
        static let titleFont: UIFont = UIFont.systemFont(ofSize: 12.0, weight: .light)
        static let titleColor: UIColor = .white
        static let nameFont: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        static let nameColor: UIColor = .white
        static let progressColor: UIColor = .white
        static let backgroundColor: UIColor = .black
    }

    private enum Layout {
        static let progressViewHeight: CGFloat = 2.0
        static let titleSpacing: CGFloat = 16.0
        static let nameSpacing: CGFloat = 16.0
    }

    // MARK: - Variables

    private let photo: Photo
    private let thumbnail: UIImage?
    private let image: UIImage?

    private lazy var animatableProgressConstraint: NSLayoutConstraint = progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)

    // MARK: - Views

    let backgroundView: UIView = {
        let result: UIView = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Style.backgroundColor
        return result
    }()

    private lazy var imageView: UIImageView = {
        let result: UIImageView = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.image = thumbnail
        result.contentMode = .scaleAspectFit
        return result
    }()

    private let visualEffectView: UIVisualEffectView = {
        let result: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private let progressView: UIView = {
        let result: UIView = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Style.progressColor
        result.isHidden = true
        return result
    }()

    private let nameLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Style.nameFont
        result.textColor = Style.nameColor
        return result
    }()

    private let titleLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Style.titleFont
        result.textColor = Style.titleColor
        return result
    }()

    // MARK: - Overrides

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Lifecycle

    init(photo: Photo, thumbnail: UIImage?, image: UIImage?) {
        self.photo = photo
        self.thumbnail = thumbnail
        self.image = image

        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = self
        modalPresentationStyle = .overFullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(backgroundView)
        view.addSubview(imageView)
        view.addSubview(visualEffectView)
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(nameLabel)

        activateConstraints()
        loadPhoto()
        addGestureRecognizers()

        setNeedsStatusBarAppearanceUpdate()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.boxAnchor.constraints(equalTo: view.boxAnchor),
            imageView.boxAnchor.constraints(equalTo: view.boxAnchor),
            visualEffectView.boxAnchor.constraints(equalTo: view.boxAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: Layout.progressViewHeight),
            animatableProgressConstraint,
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.titleSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.titleSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.titleSpacing),
            titleLabel.heightAnchor.constraint(equalToConstant: Style.titleFont.lineHeight),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.nameSpacing),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.titleSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.titleSpacing),
            nameLabel.heightAnchor.constraint(equalToConstant: Style.nameFont.lineHeight)
        ])
    }

    private func addGestureRecognizers() {
        [UISwipeGestureRecognizer.Direction.left, UISwipeGestureRecognizer.Direction.right, UISwipeGestureRecognizer.Direction.up, UISwipeGestureRecognizer.Direction.down].forEach { direction in
            let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didGestureView))
            gestureRecognizer.direction = direction
            view.addGestureRecognizer(gestureRecognizer)
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didGestureView)))
    }

    // MARK: - Class

    private func loadPhoto() {
        guard let url: URL = photo.largeUrl else {
            return
        }

        titleLabel.text = photo.title

        let availableImage: UIImage?

        if let image = self.image {
            availableImage = image
        } else if let thumbnail = self.thumbnail {
            availableImage = thumbnail
        } else {
            availableImage = nil
        }

        if let availableImage = availableImage, self.image != nil {
            imageView.image = availableImage
            stopLoading()
        } else {
            AF.download(url).downloadProgress { [weak self] progress in
                guard let self = self else {
                    return
                }

                self.updateLoadingProgress(progress)
            }.responseData { [weak self] response in
                guard let self = self, let data = response.result.value else {
                    return
                }

                self.stopLoading()
                self.imageView.image = UIImage(data: data)
            }
        }

        APIClient.getUser(id: photo.owner) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let data):
                var name: String = ""

                if let firstName = data.profile.firstName {
                    name.append(firstName)
                }

                if let lastName = data.profile.lastName {
                    if name.isEmpty {
                        name.append(lastName)
                    } else {
                        name.append(" \(lastName)")
                    }
                }

                self.nameLabel.text = name

            case .failure:
                break
            }
        }
    }

    private func stopLoading() {
        visualEffectView.isHidden = true
        progressView.isHidden = true
    }

    private func updateLoadingProgress(_ progress: Progress) {
        if progress.fractionCompleted > 0.0 {
            progressView.isHidden = false
        }

        let percentProgress: CGFloat = 1.0 - CGFloat(progress.fractionCompleted)
        let widthProgress: CGFloat = view.frame.width * percentProgress
        animatableProgressConstraint.constant = -widthProgress

        view.layoutIfNeeded()
    }

    // MARK: - Actions

    @objc
    private func didGestureView() {
        dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - UIViewControllerTransitioningDelegate
extension PhotoViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoAnimatedTransitioning(.push)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PhotoAnimatedTransitioning(.pop)
    }

}
