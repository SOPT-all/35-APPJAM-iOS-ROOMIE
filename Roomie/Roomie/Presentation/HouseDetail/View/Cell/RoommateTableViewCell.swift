//
//  RoommateTableViewCell.swift
//  Roomie
//
//  Created by 김승원 on 1/21/25.
//

import UIKit

import SnapKit
import Then

final class RoommateTableViewCell: BaseTableViewCell {
    
    // MARK: - UIComponent
    
    private let backView = UIView()
    
    private let profileImageView = UIImageView()
    
    private let ageLabel = UILabel()
    private let jobLabel = UILabel()
    
    private let mbtiBackView = UIView()
    private let mbtiLabel = UILabel()
    
    private let nameBackView = UIView()
    private let nameLabel = UILabel()
    
    private let sleepTimeTitleLabel = UILabel()
    private let sleepTimeLabel = UILabel()
    
    private let activityTimeTitleLabel = UILabel()
    private let activityTimeLabel = UILabel()
    
    // MARK: - UISetting
    
    override func setStyle() {
        backView.do {
            $0.layer.borderColor = UIColor.grayscale5.cgColor
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.clipsToBounds = true
        }
        
        profileImageView.do {
            $0.backgroundColor = .grayscale5
            $0.image = .imgProfile
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = Screen.width(65) / 2
            $0.clipsToBounds = true
        }
        
        ageLabel.do {
            $0.setText(style: .body2, color: .grayscale12)
        }
        
        jobLabel.do {
            $0.setText(style: .body2, color: .grayscale12)
        }
        
        mbtiBackView.do {
            $0.backgroundColor = .grayscale4
            $0.layer.cornerRadius = 2
            $0.clipsToBounds = true
        }
        
        mbtiLabel.do {
            $0.setText(style: .caption1, color: .grayscale8)
        }
        
        nameBackView.do {
            $0.backgroundColor = .grayscale4
            $0.layer.cornerRadius = 2
            $0.clipsToBounds = true
        }
        
        nameLabel.do {
            $0.setText(style: .caption1, color: .grayscale8)
        }
        
        sleepTimeTitleLabel.do {
            $0.setText("수면시간", style: .body6, color: .grayscale8)
        }
        
        sleepTimeLabel.do {
            $0.setText(style: .body4, color: .grayscale10)
        }
        
        activityTimeTitleLabel.do {
            $0.setText("활동시간", style: .body6, color: .grayscale8)
        }
        
        activityTimeLabel.do {
            $0.setText(style: .body4, color: .grayscale10)
        }
    }
    
    override func setUI() {
        addSubview(backView)
        
        backView.addSubviews(
            profileImageView,
            ageLabel,
            jobLabel,
            mbtiBackView,
            nameBackView,
            sleepTimeTitleLabel,
            sleepTimeLabel,
            activityTimeTitleLabel,
            activityTimeLabel
        )
        
        mbtiBackView.addSubview(mbtiLabel)
        
        nameBackView.addSubview(nameLabel)
    }
    
    override func setLayout() {
        backView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
        }
        
        profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(Screen.width(65))
        }
        
        ageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
        }
        
        jobLabel.snp.makeConstraints {
            $0.top.equalTo(ageLabel.snp.top)
            $0.leading.equalTo(ageLabel.snp.trailing).offset(Screen.width(2))
        }
        
        mbtiBackView.snp.makeConstraints {
            $0.leading.equalTo(jobLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(jobLabel.snp.centerY)
        }
        
        mbtiLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(2)
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
        
        nameBackView.snp.makeConstraints {
            $0.leading.equalTo(mbtiBackView.snp.trailing).offset(4)
            $0.centerY.equalTo(jobLabel.snp.centerY)
        }
        
        nameLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(2)
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
        
        sleepTimeTitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(activityTimeTitleLabel.snp.top).offset(-4)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
        }
        
        sleepTimeLabel.snp.makeConstraints {
            $0.bottom.equalTo(activityTimeTitleLabel.snp.top).offset(-4)
            $0.leading.equalTo(sleepTimeTitleLabel.snp.trailing).offset(4)
        }
        
        activityTimeTitleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
        }
        
        activityTimeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalTo(activityTimeTitleLabel.snp.trailing).offset(4)
        }
    }
}

// MARK: - Functions

extension RoommateTableViewCell {
    func dataBind(_ roommate: RoommateInfo) {
        ageLabel.updateText(roommate.age)
        jobLabel.updateText(roommate.job)
        mbtiLabel.updateText(roommate.mbti)
        nameLabel.updateText(roommate.name)
        sleepTimeLabel.updateText(roommate.sleepTime)
        activityTimeLabel.updateText(roommate.activityTime)
    }
}
