//
//  TourCheckView.swift
//  Roomie
//
//  Created by 김승원 on 1/11/25.
//

import UIKit

import SnapKit
import Then

final class TourCheckView: BaseView {
    
    // MARK: - UIComponent
    
    let titleLabel = UILabel()
    
    private let houseTitleLabel = UILabel()
    let houseNameLabel = UILabel()
    
    private let roomTitleLabel = UILabel()
    let roomNameLabel = UILabel()
        
    
    // MARK: - UISetting
    
    override func setStyle() {
        titleLabel.do {
            $0.setText("선택하신 방이 맞는지\n확인해주세요", style: .heading2, color: .grayscale12)
            $0.textAlignment = .left
        }
        
        houseTitleLabel.do {
            $0.setText("신청지점", style: .body2, color: .grayscale7)
        }
        
        houseNameLabel.do {
            $0.setText("해피쉐어 100호점 (건대점)", style: .body1, color: .grayscale12)
        }
        
        roomTitleLabel.do {
            $0.setText("대상", style: .body2, color: .grayscale7)
        }
        
        roomNameLabel.do {
            $0.setText("1A (싱글침대)", style: .body1, color: .grayscale12)
        }
    }
    
    override func setUI() {
        backgroundColor = .grayscale1 // TODO: 화면 연결 후 삭제
        addSubviews(
            titleLabel,
            houseTitleLabel,
            houseNameLabel,
            roomTitleLabel,
            roomNameLabel
        )
    }
    
    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        houseTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(52)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(52)
        }
        
        houseNameLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(52)
            $0.leading.equalTo(houseTitleLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        roomTitleLabel.snp.makeConstraints {
            $0.top.equalTo(houseTitleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(52)
        }
        
        roomNameLabel.snp.makeConstraints {
            $0.top.equalTo(houseNameLabel.snp.bottom).offset(16)
            $0.leading.equalTo(roomTitleLabel.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
