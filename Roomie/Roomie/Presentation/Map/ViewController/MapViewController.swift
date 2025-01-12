//
//  MapViewController.swift
//  Roomie
//
//  Created by 예삐 on 1/9/25.
//

import UIKit
import Combine

import CombineCocoa
import NMapsMap

final class MapViewController: BaseViewController {
    
    // MARK: - Property

    private let rootView = MapView()
    
    private let viewModel: MapViewModel
    
    private let cancelBag = CancelBag()
    
    private var selectedMarker: NMFMarker?
    
    private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
    private let markerDidSelectSubject = PassthroughSubject<Int, Never>()
    
    // MARK: - Initializer

    init(viewModel: MapViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewWillAppearSubject.send(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Functions
    
    override func setupDelegate() {
        rootView.mapView.touchDelegate = self
    }
    
    override func setupAction() {
        rootView.filteringButton
            .tapPublisher
            .sink {
                let mapFilterViewController = MapFilterViewController(
                    viewModel: MapFilterViewModel()
                )
                self.navigationController?.pushViewController(mapFilterViewController, animated: true)
            }
            .store(in: cancelBag)
        
        rootView.mapDetailCardView.arrowButton
            .tapPublisher
            .sink {
                // TODO: 매물 상세 뷰 화면 연결
            }
            .store(in: cancelBag)
    }
}

private extension MapViewController {
    func bindViewModel() {
        let input = MapViewModel.Input(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher(),
            markerDidSelect: markerDidSelectSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.markersInfo
            .sink { [weak self] markersInfo in
                for markerInfo in markersInfo {
                    let marker = NMFMarker(position: NMGLatLng(lat: markerInfo.x, lng: markerInfo.y))
                    marker.mapView = self?.rootView.mapView
                    marker.iconImage = NMFOverlayImage(name: "icn_map_pin_normal")
                    marker.width = 36
                    marker.height = 36
                    
                    marker.touchHandler = { [weak self] _ in
                        guard let self = self else { return false }
                        
                        erasePreviousSelectedMarker()
                        marker.iconImage = NMFOverlayImage(name: "icn_map_pin_active")
                        self.selectedMarker = marker
                        
                        self.markerDidSelectSubject.send(markerInfo.houseID)
                        
                        return true
                    }
                }
            }
            .store(in: cancelBag)
        
        output.markerDetailInfo
            .sink { [weak self] markerDetailInfo in
                self?.rootView.mapDetailCardView.isHidden = false
                
                self?.rootView.mapDetailCardView.titleLabel.updateText(
                    "월세 \(markerDetailInfo.monthlyRent)"
                )
                self?.rootView.mapDetailCardView.depositLabel.updateText(
                    "보증금 \(markerDetailInfo.deposit)"
                )
                self?.rootView.mapDetailCardView.contractTermLabel.updateText(
                    "\(markerDetailInfo.contractTerm)개월"
                )
                self?.rootView.mapDetailCardView.genderOccupancyLabel.updateText(
                    "\(markerDetailInfo.genderPolicy)・\(markerDetailInfo.occupancyType)"
                )
                self?.rootView.mapDetailCardView.locationLabel.updateText(
                    "\(markerDetailInfo.location)・\(markerDetailInfo.locationDescription)"
                )
                self?.rootView.mapDetailCardView.moodTagLabel.updateText(
                    markerDetailInfo.moodTag
                )
            }
            .store(in: cancelBag)
    }
    
    func erasePreviousSelectedMarker() {
        if let previousMarker = self.selectedMarker {
            previousMarker.iconImage = NMFOverlayImage(name: "icn_map_pin_normal")
        }
    }
}

// MARK: - NMFMapViewTouchDelegate

extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        view.endEditing(true)
        
        if !rootView.mapDetailCardView.isHidden {
            erasePreviousSelectedMarker()
            
            rootView.mapDetailCardView.isHidden = true
        }
    }
}
