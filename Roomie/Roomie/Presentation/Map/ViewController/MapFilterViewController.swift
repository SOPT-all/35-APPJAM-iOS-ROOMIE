//
//  MapFilterViewController.swift
//  Roomie
//
//  Created by 예삐 on 1/11/25.
//

import UIKit
import Combine

import CombineCocoa

final class MapFilterViewController: BaseViewController {
    
    // MARK: - Property

    private let rootView = MapFilterView()
    
    private let viewModel: MapFilterViewModel
    
    private let cancelBag = CancelBag()
    
    private let depositMinTextSubject = PassthroughSubject<Int, Never>()
    private let depositMaxTextSubject = PassthroughSubject<Int, Never>()
    private let depositMinRangeSubject = PassthroughSubject<Int, Never>()
    private let depositMaxRangeSubject = PassthroughSubject<Int, Never>()
    
    
    // MARK: - Initializer

    init(viewModel: MapFilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle

    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    // MARK: - Functions

    override func setupView() {
        setupNavigationBar(with: "필터", isBorderHidden: true)
    }
    
    override func setupAction() {
        hideKeyboardWhenDidTap()
        
        rootView.filterSegmentedControl
            .publisher(for: \.selectedSegmentIndex)
            .sink { [weak self] selectedIndex in
                guard let self = self else { return }
                self.updateFilterViews(for: selectedIndex)
            }
            .store(in: cancelBag)
        
        rootView.filterPriceView.depositMinTextField
            .textPublisher
            .compactMap { $0 }
            .compactMap { Int($0) }
            .sink { [weak self] depositMinText in
                guard let self = self else { return }
                self.depositMinTextSubject.send(depositMinText)
            }
            .store(in: cancelBag)
        
        rootView.filterPriceView.depositMaxTextField
            .textPublisher
            .compactMap { $0 }
            .compactMap { Int($0) }
            .sink { [weak self] depositMaxText in
                guard let self = self else { return }
                self.depositMaxTextSubject.send(depositMaxText)
            }
            .store(in: cancelBag)
        
        rootView.filterPriceView.depositSlider
            .controlEventPublisher(for: .valueChanged)
            .sink { [weak self] in
                guard let self = self else { return }
                self.depositMinRangeSubject.send(Int(rootView.filterPriceView.depositSlider.min))
                self.depositMaxRangeSubject.send(Int(rootView.filterPriceView.depositSlider.max))
            }
            .store(in: cancelBag)
    }
}

private extension MapFilterViewController {
    func bindViewModel() {
        let input = MapFilterViewModel.Input(
            depositMinText: depositMinTextSubject.eraseToAnyPublisher(),
            depositMaxText: depositMaxTextSubject.eraseToAnyPublisher(),
            depositMinRange: depositMinRangeSubject.eraseToAnyPublisher(),
            depositMaxRange: depositMaxRangeSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.depositMinRange
            .map { Double($0) }
            .sink { [weak self] depositMin in
                guard let self = self else { return }
                self.rootView.filterPriceView.depositSlider.min = depositMin
            }
            .store(in: cancelBag)
        
        output.depositMaxRange
            .map { Double($0) }
            .sink { [weak self] depositMax in
                guard let self = self else { return }
                self.rootView.filterPriceView.depositSlider.max = depositMax
            }
            .store(in: cancelBag)
        
        output.depositMinText
            .map { String($0) }
            .sink { [weak self] depositMin in
                guard let self = self else { return }
                self.rootView.filterPriceView.depositMinTextField.text = depositMin
            }
            .store(in: cancelBag)
        
        output.depositMaxText
            .map { String($0) }
            .sink { [weak self] depositMax in
                guard let self = self else { return }
                self.rootView.filterPriceView.depositMaxTextField.text = depositMax
            }
            .store(in: cancelBag)
    }
    
    func updateFilterViews(for selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            rootView.filterPriceView.isHidden = false
            rootView.filterRoomView.isHidden = true
            rootView.filterPeriodView.isHidden = true
        case 1:
            rootView.filterPriceView.isHidden = true
            rootView.filterRoomView.isHidden = false
            rootView.filterPeriodView.isHidden = true
        default:
            rootView.filterPriceView.isHidden = true
            rootView.filterRoomView.isHidden = true
            rootView.filterPeriodView.isHidden = false
        }
    }
}
