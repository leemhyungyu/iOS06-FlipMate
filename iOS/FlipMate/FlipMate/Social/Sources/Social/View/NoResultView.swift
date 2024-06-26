//
//  NoResultView.swift
//
//
//  Created by 권승용 on 6/2/24.
//

import UIKit

final class NoResultView: UIView, FreindAddResultViewProtocol {
    private enum Constant {
        static let title = NSLocalizedString("noResult", comment: "")
        static let height: CGFloat = 100
    }
    
    // MARK: - UI Components
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.title
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    
    func height() -> CGFloat {
        return Constant.height
    }
}

// MARK: - Private Method
private extension NoResultView {
    // MARK: - Configure UI
    func configureUI() {
        addSubview(noResultLabel)
        
        NSLayoutConstraint.activate([
            noResultLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
