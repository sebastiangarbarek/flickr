//
//  PhotoCell.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 2/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit
import Alamofire

class PhotoCell: UICollectionViewCell {

    // MARK: - Variables

    var photo: Photo? {
        didSet {
            guard let thumbUrl: URL = photo?.thumbnailUrl, let largeUrl: URL = photo?.largeUrl else {
                return
            }

            startLoading()

            if let cachedImage = APIClient.shared.imageCache.object(forKey: largeUrl.absoluteString as NSString) {
                image = cachedImage
                stopLoading()
            } else {
                thumbnailDownloadRequest?.cancel()
                thumbnailDownloadRequest = AF.download(thumbUrl).responseData { [weak self] response in
                    guard let self = self, self.photo?.thumbnailUrl == thumbUrl, let data = response.result.value else {
                        return
                    }

                    self.thumbnail = UIImage(data: data)
                }

                imageDownloadRequest?.cancel()
                imageDownloadRequest = AF.download(largeUrl).downloadProgress { [weak self] progress in
                    self?.updateLoadingProgress(progress.fractionCompleted)
                }.responseData { [weak self] response in
                    guard let self = self else {
                        return
                    }

                    guard self.photo?.largeUrl == largeUrl, let data = response.result.value, let image = UIImage(data: data) else {
                        self.stopLoading()
                        return
                    }

                    APIClient.shared.imageCache.setObject(image, forKey: largeUrl.absoluteString as NSString)

                    self.stopLoading()
                    self.image = image
                }
            }
        }
    }

    var thumbnailDownloadRequest: DownloadRequest?
    var imageDownloadRequest: DownloadRequest?

    var thumbnail: UIImage? {
        didSet {
            if image == nil {
                animateImageChange(thumbnail)
            }
        }
    }

    var image: UIImage? {
        didSet {
            animateImageChange(image)
        }
    }

    private lazy var animatableProgressConstraint: NSLayoutConstraint = progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)

    // MARK: - Views

    private let loadingGradientView: LoadingGradientView = {
        let result: LoadingGradientView = LoadingGradientView()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private let imageView: UIImageView = {
        let result: UIImageView = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.contentMode = .scaleAspectFill
        result.clipsToBounds = true
        result.backgroundColor = .clear
        return result
    }()

    private let progressView: UIView = {
        let result: UIView = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .white
        result.isHidden = true
        return result
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(loadingGradientView)
        contentView.addSubview(imageView)
        contentView.addSubview(progressView)

        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            loadingGradientView.boxAnchor.constraints(equalTo: contentView.boxAnchor),
            imageView.boxAnchor.constraints(equalTo: contentView.boxAnchor),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.0),
            animatableProgressConstraint
        ])
    }

    // MARK: - Class

    private func startLoading() {
        thumbnail = nil
        image = nil
        imageView.image = nil
        progressView.isHidden = true
        updateLoadingProgress(0.0)
    }

    private func stopLoading() {
        progressView.isHidden = true
    }

    private func updateLoadingProgress(_ progress: Double) {
        if progress > 0.0 {
            progressView.isHidden = false
        }

        let percentProgress: CGFloat = 1.0 - CGFloat(progress)
        let widthProgress: CGFloat = contentView.frame.width * percentProgress
        animatableProgressConstraint.constant = -widthProgress

        contentView.layoutIfNeeded()
    }

    private func animateImageChange(_ image: UIImage?) {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageView.image = image
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
