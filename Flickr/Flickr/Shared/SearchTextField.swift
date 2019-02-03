//
//  SearchTextField.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 2/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit

@objc
protocol SearchTextFieldDelegate: class {

    @objc
    optional func textDidChange(_ text: String?)
    func didPressCancel()

}

class SearchTextField: UIView {

    // MARK: - Constants

    private enum Strings {
        static let cancelTitle: String = NSLocalizedString("searchCancelTitle", value: "Cancel", comment: "Cancel button title.")
    }

    private enum Style {
        static let font: UIFont = UIFont.systemFont(ofSize: 12.0)
        static let animationDuration: TimeInterval = 0.2
        static let shadowOffset: CGSize = CGSize(width: 0.0, height: 8.0)
        static let shadowColor: CGColor = UIColor.black.cgColor
        static let shadowOpacity: Float = 0.2
        static let shadowRadius: CGFloat = 8.0
    }

    private enum Layout {
        static let fieldInset: CGFloat = 16.0
        static let cancelWidth: CGFloat = 100.0
    }

    // MARK: - Views

    private let containerView: UIView = {
        let result: UIView = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .white
        result.layer.shadowOffset = Style.shadowOffset
        result.layer.shadowColor = Style.shadowColor
        result.layer.shadowOpacity = Style.shadowOpacity
        result.layer.shadowRadius = Style.shadowRadius
        return result
    }()

    private lazy var textField: UITextField = {
        let result: UITextField = UITextField()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Style.font
        result.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        result.returnKeyType = .search
        return result
    }()

    private lazy var cancelButton: UIButton = {
        let result: UIButton = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .white
        result.alpha = 0.0
        result.layer.shadowOffset = Style.shadowOffset
        result.layer.shadowColor = Style.shadowColor
        result.layer.shadowOpacity = Style.shadowOpacity
        result.layer.shadowRadius = Style.shadowRadius
        result.setTitle(Strings.cancelTitle, for: .normal)
        result.titleLabel?.font = Style.font
        result.setTitleColor(.lightGray, for: .normal)
        result.addTarget(self, action: #selector(didPressCancel), for: .touchUpInside)
        return result
    }()

    // MARK: - Variables

    var placeholder: String? {
        didSet {
            textField.placeholder = placeholder
        }
    }

    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    private lazy var containerViewTrailingConstraint: NSLayoutConstraint = containerView.trailingAnchor.constraint(equalTo: trailingAnchor)

    weak var delegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }
    
    weak var searchTextFieldDelegate: SearchTextFieldDelegate?

    // MARK: - Overrides

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        animate(true)
        return textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        animate(false)
        return textField.resignFirstResponder()
    }

    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(containerView)
        containerView.addSubview(textField)
        addSubview(cancelButton)

        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerViewTrailingConstraint,
            textField.boxAnchor.constraints(equalTo: containerView.boxAnchor, insets: UIEdgeInsets(top: 0.0, left: Layout.fieldInset, bottom: 0.0, right: Layout.fieldInset)),
            cancelButton.topAnchor.constraint(equalTo: topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: Layout.fieldInset)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.layer.cornerRadius = frame.height / 2.0
        cancelButton.layer.cornerRadius = frame.height / 2.0
    }

    // MARK: - Class

    func animate(_ isFocusing: Bool) {
        if isFocusing {
            self.containerViewTrailingConstraint.constant = -Layout.cancelWidth
            UIView.animate(withDuration: Style.animationDuration) {
                self.layoutIfNeeded()
                self.cancelButton.alpha = 1.0
            }
        } else {
            self.containerViewTrailingConstraint.constant = 0.0
            UIView.animate(withDuration: Style.animationDuration) {
                self.layoutIfNeeded()
                self.cancelButton.alpha = 0.0
            }
        }
    }

    // MARK: - Actions

    @objc
    private func didPressCancel() {
        searchTextFieldDelegate?.didPressCancel()
    }

    @objc
    private func textDidChange() {
        searchTextFieldDelegate?.textDidChange?(textField.text)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
