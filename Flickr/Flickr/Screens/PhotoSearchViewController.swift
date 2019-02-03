//
//  PhotoSearchViewController.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 3/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit

class PhotoSearchViewController: SearchViewController {

    // MARK: - Constants

    private enum Strings {
        private static let resultsTextFormat: String = NSLocalizedString("searchResultsText", value: "%@ results.", comment: "Results text.")

        static func resultsText(count: Int64) -> String {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let numberString = numberFormatter.string(from: NSNumber(value: count))
            return String(format: resultsTextFormat, numberString ?? "0")
        }
    }

    private enum Style {
        static let resultFont: UIFont = UIFont.systemFont(ofSize: 12.0, weight: .light)
        static let resultColor: UIColor = .lightGray
    }

    private enum Layout {
        static let resultsSpacing: CGFloat = 16.0
    }

    // MARK: - Variables

    private var currentSearch: String?
    private var total: Int64?

    // MARK: - Views

    private let resultLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textColor = Style.resultColor
        result.font = Style.resultFont
        return result
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(resultLabel)

        loadingView.isHidden = true

        searchTextField.delegate = self
        searchTextField.searchTextFieldDelegate = self

        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: Layout.resultsSpacing),
            resultLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.resultsSpacing),
            resultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.resultsSpacing),
            resultLabel.heightAnchor.constraint(equalToConstant: Style.resultFont.lineHeight)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.contentInset.top = view.safeAreaInsets.top
            + SearchViewController.Layout.fieldSpacing
            + SearchViewController.Layout.fieldHeight
            + SearchViewController.Layout.fieldSpacing
            + Layout.resultsSpacing
            + Style.resultFont.lineHeight

        collectionView.scrollIndicatorInsets.top = view.safeAreaInsets.top
    }

    private func search() {
        if let text = searchTextField.text, text != currentSearch {
            photos.removeAll()
            currentSearch = text

            if photos.count == 0 {
                loadingView.isHidden = false
            }

            APIClient.search(page: page, text: text) { [weak self] result in
                guard let self = self else {
                    return
                }

                self.loadingView.isHidden = true

                switch result {
                case .success(let data):
                    self.photos.append(contentsOf: data.photos?.photo ?? [])

                    if let totalString = data.photos?.total, let total: Int64 = Int64(totalString) {
                        self.updateResultsLabel(count: total)
                    } else {
                        self.updateResultsLabel(count: nil)
                    }

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
    }

    private func updateResultsLabel(count: Int64?) {
        if let count = count {
            resultLabel.text = Strings.resultsText(count: count)
        } else {
            resultLabel.text = nil
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        if scrollView.contentOffset.y <= 0.0 - scrollView.contentInset.top {
            UIView.animate(withDuration: SearchViewController.Style.fieldAnimationDuration) {
                self.resultLabel.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: SearchViewController.Style.fieldAnimationDuration) {
                self.resultLabel.alpha = 0.0
            }
        }
    }

}

// MARK: - UITextFieldDelegate
extension PhotoSearchViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        search()
        return false
    }

}

// MARK: - SearchTextFieldDelegate
extension PhotoSearchViewController: SearchTextFieldDelegate {

    func didPressCancel() {
        navigationController?.popViewController(animated: true)
    }

}
