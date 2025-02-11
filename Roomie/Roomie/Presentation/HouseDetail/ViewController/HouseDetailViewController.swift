//
//  HouseDetailViewController.swift
//  Roomie
//
//  Created by 김승원 on 1/16/25.
//

import UIKit
import Combine

import CombineCocoa
import Kingfisher

enum NavigationBarStatus {
    case clear
    case filled
    case filledWithTitle
}

final class HouseDetailViewController: BaseViewController {
    
    // MARK: - Property
    
    private let rootView = HouseDetailView()
    
    private let viewModel: HouseDetailViewModel
    
    private var navigationBarStatus: NavigationBarStatus = .clear {
        didSet {
            setNavigationBarStatus()
        }
    }
    
    private var navigationBarTitle: String = ""
    
    private let navigationBarThreshold = Screen.height(212.0)
    private let navigationTitleThreshold = Screen.height(280.0)
    
    private let roomStatusCellHeight: CGFloat = Screen.height(182 + 12)
    private let roommateCellHeight: CGFloat = Screen.height(102 + 12)
    
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    private let wishListButtonSubject = PassthroughSubject<Void, Never>()
    
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer
    
    init(viewModel: HouseDetailViewModel) {
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
        
        setRegister()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearSubject.send(())
        setNavigationBarStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let borderIdentifier = "customBorder"
        if let existingBorder = navigationController?.navigationBar.subviews
            .first(where: { $0.accessibilityIdentifier == borderIdentifier }) {
            existingBorder.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        rootView.updateRoomStatusTableViewHeight(viewModel.roomInfos.count, height: roomStatusCellHeight)
        rootView.updateRoommateTableViewHeight(viewModel.roommateInfos.count, height: roommateCellHeight)
    }
    
    override func setView() {
        setNavigationBar(with: "", isBorderHidden: true)
    }
    
    override func setAction() {
        rootView.lookInsidePhotoButton.updateButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                let houseAllPhotoViewController = HouseAllPhotoViewController(
                    title: navigationBarTitle,
                    viewModel: HouseAllPhotoViewModel(
                        service: HousesService(),
                        houseID: viewModel.houseID
                    )
                )
                self.navigationController?.pushViewController(houseAllPhotoViewController, animated: true)
            }
            .store(in: cancelBag)
        
        rootView.tourApplyButton.tapPublisher
            .sink { [weak self] in
                self?.presentHouseDetailSheet()
            }
            .store(in: cancelBag)
        
        rootView.wishListButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.wishListButtonSubject.send(())
            }
            .store(in: cancelBag)
        
        rootView.contactButton.tapPublisher
            .sink{
                let webViewController = HouseDetailWebViewController()
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            .store(in: cancelBag)
    }
    
    override func setDelegate() {
        rootView.roomStatusTableView.dataSource = self
        rootView.roomStatusTableView.delegate = self
        
        rootView.roommateTableView.dataSource = self
        rootView.roommateTableView.delegate = self
        
        rootView.scrollView.delegate = self
    }
}

// MARK: - Functions

private extension HouseDetailViewController {
    func bindViewModel() {
        let input = HouseDetailViewModel.Input(
            houseDetailViewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            bottomSheetViewWillAppear: Just(()).eraseToAnyPublisher(),
            buttonIndexSubject: PassthroughSubject<Int, Never>().eraseToAnyPublisher(),
            tourApplyButtonTapSubject: PassthroughSubject<Void, Never>().eraseToAnyPublisher(),
            wishListButtonSubject: wishListButtonSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.pinnedStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] pinnedStatus in
                guard let self else { return }
                rootView.wishListButton
                    .setImage(
                        pinnedStatus ? .icnHeart24Active : .icnHeart24Normal,
                        for: .normal
                    )
            }
            .store(in: cancelBag)
        
        output.pinnedInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] isPinned in
                guard let self else { return }
                if isPinned {
                    rootView.wishListButton.setImage(.icnHeart24Active, for: .normal)
                } else {
                    rootView.wishListButton.setImage(.icnHeart24Normal, for: .normal)
                    Toast().show(message: "찜 목록에서 삭제되었어요", inset: Screen.height(120), view: rootView)
                }
            }
            .store(in: cancelBag)
        
        output.navigationBarTitle
            .receive(on: RunLoop.main)
            .sink { [weak self] navigationBarTitle in
                guard let self else { return }
                self.navigationBarTitle = navigationBarTitle
            }
            .store(in: cancelBag)
        
        output.houseMainInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] houseMainInfo in
                guard let self else { return }
                if let imageUrl = URL(string: houseMainInfo.mainImageURL) {
                    self.rootView.photoImageView.kf.setImage(with: imageUrl)
                }
                self.rootView.nameLabel.updateText(houseMainInfo.name)
                self.rootView.titleLabel.updateText(houseMainInfo.title)
                self.rootView.locationIconLabel.updateText(with: houseMainInfo.location)
                self.rootView.occupancyTypesIconLabel.updateText(with: houseMainInfo.occupancyTypes)
                self.rootView.occupancyStatusIconLabel.updateText(with: houseMainInfo.occupancyStatus)
                self.rootView.genderPolicyIconLabel.updateText(with: houseMainInfo.genderPolicy)
                self.rootView.contractTermIconLabel.updateText(with: houseMainInfo.contractTerm)
            }
            .store(in: cancelBag)
        
        output.roomMoodInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] roomMoodInfo in
                guard let self else { return }
                self.rootView.roomMoodLabel.updateText(roomMoodInfo.roomMood)
                self.rootView.bindGroundRule(roomMoodInfo.groundRule)
                self.rootView.bindMoodTags(roomMoodInfo.moodTags)
                
            }
            .store(in: cancelBag)
        
        viewModel.$roomInfos
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.rootView.roomStatusTableView.reloadData()
            }
            .store(in: cancelBag)
        
        output.safetyLivingFacilityInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] safetyLivingFacilityInfo in
                guard let self else { return }
                rootView.safetyLivingFacilityView.dataBind(safetyLivingFacilityInfo)
            }
            .store(in: cancelBag)
        
        output.kitchenFacilityInfo.receive(on: RunLoop.main)
            .sink { [weak self] kitchenFacilityInfo in
                guard let self else { return }
                rootView.kitchenFacilityView.dataBind(kitchenFacilityInfo)
            }
            .store(in: cancelBag)
        
        viewModel.$roommateInfos
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.rootView.roommateTableView.reloadData()
            }
            .store(in: cancelBag)
    }
    
    func setRegister() {
        rootView.roomStatusTableView.register(
            RoomStatusTableViewCell.self,
            forCellReuseIdentifier: RoomStatusTableViewCell.reuseIdentifier
        )
        
        rootView.roommateTableView.register(
            RoommateTableViewCell.self,
            forCellReuseIdentifier: RoommateTableViewCell.reuseIdentifier
        )
        
        rootView.roommateTableView.register(
            RoommateNotFoundTableViewCell.self,
            forCellReuseIdentifier: RoommateNotFoundTableViewCell.reuseIdentifier
        )
    }
    
    func setNavigationBarStatus() {
        switch navigationBarStatus {
        case .clear:
            setClearNavigationBar()
        case .filled:
            setFilledNavigationBar()
        case .filledWithTitle:
            setFilledNavigationBar(navigationBarTitle)
        }
    }
    
    func setClearNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        
        let clearAppearance = UINavigationBarAppearance()
        clearAppearance.configureWithTransparentBackground()
        clearAppearance.shadowColor = nil
        clearAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.grayscale12,
            .font: UIFont.pretendard(.heading5)
        ]
        
        navigationController?.navigationBar.standardAppearance = clearAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = clearAppearance
        navigationController?.navigationBar.compactAppearance = clearAppearance
        
        let borderIdentifier = "customBorder"
        if let existingBorder = navigationController?.navigationBar.subviews
            .first(
            where: { $0.accessibilityIdentifier == borderIdentifier }
            ) {
            existingBorder.removeFromSuperview()
        }
        
        navigationItem.title = nil
    }
    
    func setFilledNavigationBar(_ navigationBarTitle: String = "") {
        navigationItem.title = navigationBarTitle
        
        navigationController?.navigationBar.isHidden = false
        
        let filledAppearance = UINavigationBarAppearance()
        filledAppearance.configureWithOpaqueBackground()
        filledAppearance.backgroundColor = .grayscale1
        filledAppearance.shadowColor = .grayscale4
        
        filledAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.grayscale12,
            .font: UIFont.pretendard(.heading5)
        ]
        
        navigationController?.navigationBar.standardAppearance = filledAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = filledAppearance
        navigationController?.navigationBar.compactAppearance = filledAppearance
        
        let borderIdentifier = "customBorder"
        let existingBorder = navigationController?.navigationBar.subviews
            .first(
                where: { $0.accessibilityIdentifier == borderIdentifier }
            )
        
        if existingBorder == nil {
            let customBorder = UIView()
            customBorder.accessibilityIdentifier = borderIdentifier
            customBorder.backgroundColor = .grayscale4
            
            navigationController?.navigationBar.addSubview(customBorder)
            
            customBorder.snp.makeConstraints {
                $0.height.equalTo(1)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension HouseDetailViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if tableView == rootView.roomStatusTableView {
            return viewModel.roomInfos.count // TODO: DataBind
        }
        
        if tableView == rootView.roommateTableView {
            let cellCount = viewModel.roommateInfos.count == 0 ? 1 : viewModel.roommateInfos.count
            return cellCount
        }
        
        return 0
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if tableView == rootView.roomStatusTableView {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: RoomStatusTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? RoomStatusTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            
            cell.dataBind(viewModel.roomInfos[indexPath.row])
            return cell
        }
        
        if tableView == rootView.roommateTableView {
            if viewModel.roommateInfos.count == 0 {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: RoommateNotFoundTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as? RoommateNotFoundTableViewCell else {
                    return UITableViewCell()
                }
                cell.selectionStyle = .none
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: RoommateTableViewCell.reuseIdentifier,
                    for: indexPath
                ) as? RoommateTableViewCell else {
                    return UITableViewCell()
                }
                cell.selectionStyle = .none
                
                cell.dataBind(viewModel.roommateInfos[indexPath.row])
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension HouseDetailViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if tableView == rootView.roomStatusTableView {
            return roomStatusCellHeight
        }
        
        if tableView == rootView.roommateTableView {
            return roommateCellHeight
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == rootView.roomStatusTableView {
            let houseSinglePhotoViewController = HouseSinglePhotoViewController(
                title: navigationBarTitle,
                index: indexPath.row,
                viewModel: HouseSinglePhotoViewModel(
                    service: HousesService(),
                    houseID: viewModel.houseID
                )
            )
            navigationController?.pushViewController(houseSinglePhotoViewController, animated: true)
        }
    }
}

// MARK: - ScrollView Delegate

extension HouseDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        let newStatus: NavigationBarStatus
        if offsetY > navigationBarThreshold {
            newStatus = offsetY > navigationTitleThreshold ? .filledWithTitle : .filled
        } else {
            newStatus = .clear
        }

        if navigationBarStatus != newStatus {
            navigationBarStatus = newStatus
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension HouseDetailViewController: UIAdaptivePresentationControllerDelegate {
    func presentHouseDetailSheet() {
        let houseDetailSheetViewController = HouseDetailSheetViewController(viewModel: viewModel)
        houseDetailSheetViewController.delegate = self
        let fullDetent = UISheetPresentationController.Detent.custom { _ in Screen.height(380) }
        
        if let sheet = houseDetailSheetViewController.sheetPresentationController {
            sheet.detents = [fullDetent]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 16
        }
        
        houseDetailSheetViewController.isModalInPresentation = false
        
        self.present(houseDetailSheetViewController, animated: true)
    }
}

// MARK: - HouseDetailSheetViewControllerDelegate

extension HouseDetailViewController: HouseDetailSheetViewControllerDelegate {
    func tourApplyButtonDidTap(_ selectedRoomInfo: SelectedRoomInfo) {
        
        let tourCheckViewController = TourCheckViewController(
            viewModel: TourCheckViewModel(
                selectedRoomInfo: selectedRoomInfo,
                builder: TourRequestDTO.Builder.shared
            )
        )
        navigationController?.pushViewController(tourCheckViewController, animated: true)
    }
}
