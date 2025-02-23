//
//  TourCheckViewModel.swift
//  Roomie
//
//  Created by 김승원 on 1/15/25.
//

import Foundation
import Combine

// TODO: bulider이용해서 roomId, houseId를 model로 보내주기
final class TourCheckViewModel {
    
    // MARK: - Property
    
    private let builder: TourRequestDTO.Builder
    
    private(set) var selectedRoomInfo: SelectedRoomInfo
    
    private let roomIDSubject = PassthroughSubject<Int, Never>()
    private let houseIDSubject = PassthroughSubject<Int, Never>()
    
    // MARK: - Initializer
    
    init(selectedRoomInfo: SelectedRoomInfo, builder: TourRequestDTO.Builder) {
        self.selectedRoomInfo = selectedRoomInfo
        self.builder = builder
    }
}

extension TourCheckViewModel: ViewModelType {
    struct Input {
        let nextButtonSubject: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let presentNextView: AnyPublisher<Void, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.nextButtonSubject
            .sink { [weak self] in
                guard let self else { return }
                self.builder.setHouseID(self.selectedRoomInfo.houseID)
                self.builder.setRoomID(self.selectedRoomInfo.roomID)
            }
            .store(in: cancelBag)
        
        return Output(presentNextView: input.nextButtonSubject)
    }
}
