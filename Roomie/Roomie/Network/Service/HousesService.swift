//
//  HousesService.swift
//  Roomie
//
//  Created by MaengKim on 1/22/25.
//

import Foundation

import Moya

final class HousesService {
    let provider: MoyaProvider<HousesTargetType>
    
    init(provider: MoyaProvider<HousesTargetType> = MoyaProvider(plugins: [MoyaLoggingPlugin()])) {
        self.provider = provider
    }
    
    func request<T: ResponseModelType>(
        with request: HousesTargetType
    ) async throws -> BaseResponseBody<T>? {
        return try await withCheckedThrowingContinuation {
            continuation in provider.request(request) {
                result in
                switch result {
                case .success(let response):
                    do {
                        let decodedData = try JSONDecoder().decode(
                            BaseResponseBody<T>.self, from: response.data
                        )
                        continuation.resume(returning: decodedData)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension HousesService: HouseDetailServiceProtocol {
    func applyTour(request: TourRequestDTO, roomID: Int) async throws -> BaseResponseBody<TourResponseDTO>? {
        return try await self.request(with: .applyTour(request: request, roomID: roomID))
    }
    
    func fetchHouseDetailRoomsData(
        houseID: Int
    ) async throws -> BaseResponseBody<HouseDetailRoomsResponseDTO>? {
        return try await self.request(with: .fetchHouseDetailRoomsData(houseID: houseID))
    }
    
    func fetchHouseDetailImagesData(
        houseID: Int
    ) async throws -> BaseResponseBody<HouseDetailImagesResponseDTO>? {
        return try await self.request(with: .fetchHouseDetailImagesData(houseID: houseID))
    }
    
    func fetchHouseDetailData(houseID: Int) async throws -> BaseResponseBody<HouseDetailResponseDTO>? {
        return try await self.request(with: .fetchHouseDetailData(houseID: houseID))
    }
    
    func updatePinnedHouse(houseID: Int) async throws -> BaseResponseBody<PinnedResponseDTO>? {
        return try await self.request(with: .updatePinnedHouse(houseID: houseID))
    }
}

final class MockHousesService: HouseDetailServiceProtocol {
    func fetchHouseDetailData(houseID: Int) async throws -> BaseResponseBody<HouseDetailResponseDTO>? {
        let mockData: HouseDetailResponseDTO = HouseDetailResponseDTO(
            houseInfo: HouseInfo(
                houseID: 1,
                name: "루미 100호점(이대역)",
                mainImageURL: "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832",
                monthlyRent: "43~50",
                deposit: "90~100",
                location: "서대문구 연희동",
                occupancyTypes: "1,2,3인실",
                occupancyStatus: "2/5",
                genderPolicy: "여성전용",
                contractTerm: 3,
                moodTags: ["#차분한", "#유쾌한", "#경쾌한"],
                roomMood: "전반적으로 조용하고 깔끔한 환경을 선호하는 아침형 룸메이트들이에요.",
                groundRule: ["요리 후 바로 설거지해요", "청소는 주3회 돌아가면서 해요"],
                maintenanceCost: 300000,
                isPinned: true,
                safetyLivingFacility: ["소화기", "소화기"],
                kitchenFacility: ["주걱", "밥솥"]
            ),
            rooms: [
                Room(
                    roomID: 1,
                    name: "1A 싱글침대",
                    status: true,
                    isTourAvailable: true,
                    occupancyType: 2,
                    gender: "여성",
                    deposit: 5000000,
                    prepaidUtilities: 100000,
                    monthlyRent: 500000,
                    contractPeriod: "24-12-20",
                    managementFee: "1/n"
                ),
                Room(
                    roomID: 1,
                    name: "1A 싱글침대",
                    status: false,
                    isTourAvailable: true,
                    occupancyType: 2,
                    gender: "여성",
                    deposit: 5000000,
                    prepaidUtilities: 100000,
                    monthlyRent: 500000,
                    contractPeriod: "24-12-20",
                    managementFee: "1/n"
                ),
                Room(
                    roomID: 1,
                    name: "1A 싱글침대",
                    status: false,
                    isTourAvailable: false,
                    occupancyType: 2,
                    gender: "여성",
                    deposit: 5000000,
                    prepaidUtilities: 100000,
                    monthlyRent: 500000,
                    contractPeriod: "24-12-20",
                    managementFee: "1/n"
                )
            ],
            roommates: [
                Roommate(
                    name: "1A 싱글침대",
                    age: "20대 초반",
                    job: "대학생",
                    mbti: "INFP",
                    sleepTime: "21:00 - 21:00",
                    activityTime: "21:00 - 21:00"
                )
            ]
        )
        return BaseResponseBody(code: 200, message: "", data: mockData)
    }
    
    func fetchHouseDetailImagesData(houseID: Int) async throws -> BaseResponseBody<HouseDetailImagesResponseDTO>? {
        let mockData: HouseDetailImagesResponseDTO = HouseDetailImagesResponseDTO(
            images: HouseDetailImages(
                mainImageURL: "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832",
                mainImageDescription: "상세설명",
                facilityImageURLs: [
                    "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832",
                    "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832",
                    "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832"
                ],
                facilityImageDescription: "상세설명",
                floorImageURL: "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832"
            )
        )
        return BaseResponseBody(code: 200, message: "", data: mockData)
    }
    
    func fetchHouseDetailRoomsData(houseID: Int) async throws -> BaseResponseBody<HouseDetailRoomsResponseDTO>? {
        let mockData: HouseDetailRoomsResponseDTO = HouseDetailRoomsResponseDTO(
            rooms: [
                HouseDetailRoom(
                    roomID: 1,
                    name: "1A 싱글침대",
                    facility: ["침대, 책상, 옷"],
                    status: true,
                    mainImageURL: [
                    "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832",
                    "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832",
                    "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F32%2Fab%2F6a%2F32ab6a8f37b33c4d7922505824a1af86.jpg&type=sc960_832"
                    ]
                )
            ]
        )
        return BaseResponseBody(code: 200, message: "", data: mockData)
    }
    
    func applyTour(request: TourRequestDTO, roomID: Int) async throws -> BaseResponseBody<TourResponseDTO>? {
        let mockData: TourResponseDTO = TourResponseDTO(isSuccess: true)
        return BaseResponseBody(code: 200, message: "", data: mockData)
    }
    
    func updatePinnedHouse(houseID: Int) async throws -> BaseResponseBody<PinnedResponseDTO>? {
        let mockData: PinnedResponseDTO = PinnedResponseDTO(isPinned: false)
        return BaseResponseBody(code: 200, message: "", data: mockData)
    }
}
