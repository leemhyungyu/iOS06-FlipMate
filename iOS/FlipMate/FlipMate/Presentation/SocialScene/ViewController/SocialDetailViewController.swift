//
//  SocialDetailViewController.swift
//  FlipMate
//
//  Created by 신민규 on 11/28/23.
//

import UIKit
import SwiftUI

final class SocialDetailViewController: BaseViewController {
    private enum ComponentConstant {
        static let nicknameLabel = "닉네임"
        static let dailyStudyLog = "오늘 학습 시간"
        static let weeklyStudyLog = "주간 학습 시간"
        static let monthlyStudyLog = "월간 학습 시간"
        static let unfollow = "팔로우 취소"
        static let profileImage = "person.crop.circle.fill"
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let spacing1: CGFloat = 1
        static let spacing2: CGFloat = 12
    }
    
    private enum LayoutConstant {
        static let profileImageTop: CGFloat = 36
        static let profileImageLeading: CGFloat = 15
        static let profileImageHeight: CGFloat = 50
        static let profileImageWidth: CGFloat = 50
        
        static let nicknameLabelLeading: CGFloat = 8
        static let nicknameLabelWidth: CGFloat = 80
        static let nicknameLabelHeight: CGFloat = 25
        
        static let unfollowButtonTrailing: CGFloat = -20
        static let unfollowButtonWidth: CGFloat = 96
        static let unfollowButtonHeight: CGFloat = 34
        
        static let dividerTop: CGFloat = 16
        static let dividerHeight: CGFloat = 1
        
        static let studyLogTop: CGFloat = 32
        static let studyLogLeading: CGFloat = 30
        static let stduyLogHeight: CGFloat = 120
        
        static let studyTimeTrailing: CGFloat = -30
        static let studyTimeHeight: CGFloat = 120
        
        static let chartTop: CGFloat = 40
        static let chartLeading: CGFloat = 30
        static let chartTrailing: CGFloat = -30
        static let chartBottom: CGFloat = -20
    }
    // MARK: - UI Components
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: ComponentConstant.profileImage)
        imageView.tintColor = FlipMateColor.darkBlue.color
        
        return imageView
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        
        label.text = ComponentConstant.nicknameLabel
        label.font = FlipMateFont.mediumBold.font
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var unfollowButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(ComponentConstant.unfollow, for: .normal)
        button.backgroundColor = FlipMateColor.darkBlue.color
        button.titleLabel?.font = FlipMateFont.mediumBold.font
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = FlipMateColor.gray2.color?.cgColor
        button.layer.borderWidth = ComponentConstant.borderWidth
        button.layer.cornerRadius = ComponentConstant.cornerRadius
        // button.addTarget(self, action: #selector(unfollowButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .gray
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        return divider
    }()
    
    private lazy var dailyStudyLogLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FlipMateFont.mediumRegular.font
        label.textColor = .label
        label.textAlignment = .center
        label.text = ComponentConstant.dailyStudyLog
        
        return label
    }()
    
    private lazy var weeklyStudyLogLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FlipMateFont.mediumRegular.font
        label.textColor = .label
        label.textAlignment = .center
        label.text = ComponentConstant.weeklyStudyLog
        
        return label
    }()
    
    private lazy var monthlyStudyLogLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FlipMateFont.mediumRegular.font
        label.textColor = .label
        label.textAlignment = .center
        label.text = ComponentConstant.monthlyStudyLog
        
        return label
    }()
    
    private lazy var studyLogStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = ComponentConstant.spacing1
        
        return stackView
    }()
    
    private lazy var dailyStudyTimeLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FlipMateFont.mediumBold.font
        label.textColor = FlipMateColor.gray2.color
        label.textAlignment = .right
        label.text = "9H 12m"
        
        return label
    }()
    
    private lazy var weeklyStudyTimeLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FlipMateFont.mediumRegular.font
        label.textColor = FlipMateColor.gray2.color
        label.textAlignment = .right
        label.text = "45H 36m"
        
        return label
    }()
    
    private lazy var monthlyStudyTimeLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FlipMateFont.mediumRegular.font
        label.textColor = FlipMateColor.gray2.color
        label.textAlignment = .right
        label.text = "175H"
        
        return label
    }()
    
    private lazy var studyTimeStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = ComponentConstant.spacing2
        
        return stackView
    }()
    
    private var chartView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    // MARK: - View Life Cycles
    override func configureUI() {
        setStudyLogStackView()
        setStudyTimeStackView()
        setChart()
        
        [profileImageView, nickNameLabel, unfollowButton, divider, studyLogStackView, studyTimeStackView].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstant.profileImageTop),
            profileImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, 
                                                      constant: LayoutConstant.profileImageLeading),
            profileImageView.heightAnchor.constraint(equalToConstant: LayoutConstant.profileImageHeight),
            profileImageView.widthAnchor.constraint(equalToConstant: LayoutConstant.profileImageWidth),
            
            nickNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nickNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: LayoutConstant.nicknameLabelLeading),
            nickNameLabel.widthAnchor.constraint(equalToConstant: LayoutConstant.nicknameLabelWidth),
            nickNameLabel.heightAnchor.constraint(equalToConstant: LayoutConstant.nicknameLabelHeight),
            
            unfollowButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            unfollowButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, 
                                                     constant: LayoutConstant.unfollowButtonTrailing),
            unfollowButton.widthAnchor.constraint(equalToConstant: LayoutConstant.unfollowButtonWidth),
            unfollowButton.heightAnchor.constraint(equalToConstant: LayoutConstant.unfollowButtonHeight)
        ])
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: LayoutConstant.dividerTop),
            divider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: LayoutConstant.dividerHeight)
        ])
        
        NSLayoutConstraint.activate([
            studyLogStackView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: LayoutConstant.studyLogTop),
            studyLogStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, 
                                                       constant: LayoutConstant.studyLogLeading),
            studyLogStackView.heightAnchor.constraint(equalToConstant: LayoutConstant.stduyLogHeight),
            
            studyTimeStackView.topAnchor.constraint(equalTo: studyLogStackView.topAnchor),
            studyTimeStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, 
                                                         constant: LayoutConstant.studyTimeTrailing),
            studyTimeStackView.heightAnchor.constraint(equalToConstant: LayoutConstant.studyTimeHeight)
        ])
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: studyLogStackView.bottomAnchor, constant: LayoutConstant.chartTop),
            chartView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: LayoutConstant.chartLeading),
            chartView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: LayoutConstant.chartTrailing),
            chartView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: LayoutConstant.chartBottom)
        ])
    }
}

private extension SocialDetailViewController {
    func setStudyLogStackView() {
        [dailyStudyLogLabel, weeklyStudyLogLabel, monthlyStudyLogLabel].forEach {
            studyLogStackView.addArrangedSubview($0)
        }
    }
    
    func setStudyTimeStackView() {
        [dailyStudyTimeLabel, weeklyStudyTimeLabel, monthlyStudyTimeLabel].forEach {
            studyTimeStackView.addArrangedSubview($0)
        }
    }
    
    func setChart() {
        let socialChartView = SocialChartView()
        let hostingController = UIHostingController(rootView: socialChartView)
        addChild(hostingController)
        guard let newChartView = hostingController.view else { return }
        self.chartView = newChartView
        self.view.addSubview(newChartView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.didMove(toParent: self)
    }
}

@available(iOS 17.0, *)
#Preview {
    SocialDetailViewController()
}