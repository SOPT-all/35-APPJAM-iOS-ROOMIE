//
//  MapView.swift
//  Roomie
//
//  Created by 예삐 on 1/9/25.
//

import UIKit

import NMapsMap
import SnapKit
import Then

final class MapView: BaseView {
    
    // MARK: - UIComponent
    
    private let searchBarView = UIView()
    private let searchBarLabel = UILabel()
    private let searchImageView = UIImageView()
    let searchBarButton = UIButton()
    
    let filteringButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "icn_map_fillter_20")
        let button = UIButton(configuration: config)
        return button
    }()
    
    let mapView = NMFMapView(frame: .zero)
    
    let mapListButton = NextMapButtonView()
    
    let mapDetailCardView = MapDetialCardView()
    
    // MARK: - UISetting

    override func setStyle() {
        searchBarView.do {
            $0.backgroundColor = .grayscale1
            $0.layer.cornerRadius = 8
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 2
            $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
        
        searchBarLabel.do {
            $0.setText("원하는 장소를 찾아보세요", style: .title1, color: .grayscale7)
        }
        
        searchImageView.do {
            $0.image = .icnSearch40
        }
        
        filteringButton.do {
            $0.backgroundColor = .grayscale1
            $0.layer.cornerRadius = 8
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 2
            $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
        
        mapView.do {
            $0.moveCamera(NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.555184166, lng: 126.936910322)))
        }
        
        mapDetailCardView.do {
            $0.backgroundColor = .grayscale1
            $0.layer.cornerRadius = 12
            $0.isHidden = true
            $0.layer.shadowOpacity = 0.25
            $0.layer.shadowRadius = 2
            $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
    }
    
    override func setUI() {
        addSubviews(
            mapView,
            mapDetailCardView,
            searchBarView,
            filteringButton,
            mapListButton
        )
        searchBarView.addSubviews(
            searchBarLabel,
            searchImageView,
            searchBarButton
        )
    }
    
    override func setLayout() {
        searchBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(12)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(filteringButton.snp.leading).offset(-8)
            $0.height.equalTo(50)
        }
        
        searchBarLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        searchImageView.snp.makeConstraints {
            $0.centerY.equalTo(searchBarView.snp.centerY)
            $0.trailing.equalTo(searchBarView.snp.trailing).offset(-6)
            $0.size.equalTo(40)
        }
        
        searchBarButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        filteringButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(48)
            $0.height.equalTo(50)
        }
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        mapListButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        mapDetailCardView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(170)
        }
    }
}
