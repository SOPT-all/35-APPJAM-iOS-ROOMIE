//
//  HousesTargetType.swift
//  Roomie
//
//  Created by MaengKim on 1/22/25.
//

import Foundation

import Moya

enum HousesTargetType {
    case fetchWishLishData
    case fetchHouseDetailData(houseID: Int)
    case fetchMoodListData(moodTag: String)
    case updatePinnedHouse(houseID: Int)
    case fetchHouseDetailImagesData(houseID: Int)
}

extension HousesTargetType: TargetType {
    var baseURL: URL {
        return URL(string: "\(Environment.baseURL)/v1")!
    }
    
    var path: String {
        switch self {
        case .fetchMoodListData:
            return "/houses"
        case .fetchWishLishData:
            return "/houses/pins"
        case .fetchHouseDetailData(houseID: let houseID):
            return "/houses/\(houseID)/details"
        case .updatePinnedHouse(houseID: let houseID):
            return "/houses/\(houseID)/pins"
        case .fetchHouseDetailImagesData(houseID: let houseID):
            return "/houses/\(houseID)/details/images"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchWishLishData, .fetchHouseDetailData: return .get
        case .fetchMoodListData, .fetchHouseDetailImagesData: return .get
        case .updatePinnedHouse: return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchWishLishData, .fetchHouseDetailData, .updatePinnedHouse, .fetchHouseDetailImagesData:
            return .requestPlain
        case .fetchMoodListData(moodTag: let moodTag):
            return .requestParameters(
                parameters: ["moodTag": moodTag],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
