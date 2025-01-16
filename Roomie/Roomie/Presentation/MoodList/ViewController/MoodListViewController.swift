//
//  MoodListViewController.swift
//  Roomie
//
//  Created by MaengKim on 1/16/25.
//

import UIKit

import SnapKit
import Then

final class MoodListViewController: BaseViewController {
    
    // MARK: - Property
    
    let rootView = MoodListView()
    
    private let viewModel: MoodListViewModel
    
    final let cellHeight: CGFloat = 112
    final let cellWidth: CGFloat = UIScreen.main.bounds.width - 32
    final let contentInterSpacing: CGFloat = 4
    final let contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
    
    private var moodListRooms: [MoodListRoom] = MoodListRoom.moodListRoomData()
    
    private var moodInfo: [MoodInfo] = MoodInfo.mockMoodInfoData()
    
    private let moodType: MoodType
    
    private var moodNavibarTitle: String
    
    // MARK: - Initializer
    
    init(viewModel: MoodListViewModel, moodType: MoodType) {
        self.viewModel = viewModel
        self.moodType = moodType
        self.moodNavibarTitle = moodType.moodListTitle
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
        
        setDelegate()
        setRegister()
    }
    
    // MARK: - Functions
    
    override func setView() {
        setNavigationBar(with: "\(moodNavibarTitle)")
    }
    
    override func setDelegate() {
        rootView.moodListCollectionView.delegate = self
        rootView.moodListCollectionView.dataSource = self
    }
    
    private func setRegister() {
        rootView.moodListCollectionView.register(
            RoomListCollectionViewCell.self,
            forCellWithReuseIdentifier: RoomListCollectionViewCell.reuseIdentifier
        )
        
        rootView.moodListCollectionView.register(
            MoodListCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MoodListCollectionHeaderView.reuseIdentifier
        )
        
        rootView.moodListCollectionView.register(
            WishListCollectionFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: WishListCollectionFooterView.reuseIdentifier
        )
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MoodListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return contentInterSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return contentInset
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        // TODO: 상세매물 페이지와 연결
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 183)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
}

// MARK: - UICollectionViewDataSource

extension MoodListViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return moodListRooms.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RoomListCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? RoomListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let data = moodListRooms[indexPath.row]
        cell.dataBind(data)
        
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: MoodListCollectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? MoodListCollectionHeaderView else {
                return UICollectionReusableView()
            }
            
            header.configure(with: moodType)
            
            return header
            
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: WishListCollectionFooterView.reuseIdentifier,
                for: indexPath
            ) as? WishListCollectionFooterView else {
                return UICollectionReusableView()
            }
            
            return footer
        }
        
        return UICollectionReusableView()
    }
}
