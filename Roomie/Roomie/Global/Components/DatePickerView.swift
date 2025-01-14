//
//  DatePickerView.swift
//  Roomie
//
//  Created by 김승원 on 1/12/25.
//

import UIKit
import Combine

import CombineCocoa
import SnapKit
import Then

final class DatePickerView: UIView {
    
    // MARK: - Property
    
    static let defaultHeight: CGFloat = Screen.height(54)
    
    private let cancelBag = CancelBag()
    
    // MARK: - UIComponent
    
    private let dateLabel = UILabel()
    private let calendarIcon = UIImageView()
    private let pickerButton = UIButton()
    
    private let alertController = UIAlertController(
        title: nil,
        message: nil,
        preferredStyle: .actionSheet
    )
    private let datePicker = UIDatePicker()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
        
        setPickerView()
        setAction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setStyle()
        setUI()
        setLayout()
        
        setPickerView()
        setAction()
    }
    
    // MARK: - UISetting
    
    private func setStyle() {
        self.do {
            $0.backgroundColor = .grayscale2
            $0.layer.borderColor = UIColor.grayscale5.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
        
        dateLabel.do {
            $0.setText(dateFormat(date: Date()), style: .body1, color: .grayscale6)
        }
        
        calendarIcon.do {
            $0.image = .icnCalender24
            $0.tintColor = .grayscale6
        }
        
        datePicker.do {
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .inline
            $0.locale = Locale(identifier: "ko_KR")
            $0.minimumDate = Date()
        }
    }
    
    private func setUI() {
        addSubviews(dateLabel, calendarIcon, pickerButton)
        alertController.view.addSubview(datePicker)
    }
    
    private func setLayout() {
        dateLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        calendarIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(Screen.height(26))
        }
        
        pickerButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func setAction() {
        pickerButton.tapPublisher
            .sink { [weak self] in
                guard let alertController = self?.alertController else { return }
                if let parentViewController = self?.findViewController() {
                    parentViewController.present(alertController, animated: true)
                }
            }
            .store(in: cancelBag)
    }
}

// MARK: - Functions

private extension DatePickerView {
    func setPickerView() {
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            dateLabel.setText(dateFormat(date: datePicker.date), style: .body1, color: .grayscale11)
        }
        alertController.addAction(confirmAction)
    }
    
    func findViewController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        while let responder = nextResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            nextResponder = responder.next
        }
        return nil
    }
    
    func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        return formatter.string(from: date)
    }
}
