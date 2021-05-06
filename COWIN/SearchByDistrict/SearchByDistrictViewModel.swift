//
//  SearchByDistrictViewModel.swift
//  COWIN
//
//  Created by Nemi Shah on 02/05/21.
//

import Foundation

enum SearchByDistrictAPIErrors: Error {
    case statesParsingFailed
    case districtsParsingFailed
    case slotsParsingFailed
    case apiError(error: Error?)
}

class SearchByDistrictViewModel {
    let baseUrl: String = "https://cdn-api.co-vin.in/api/v2/"
    let stateListUrlPath: String = "admin/location/states"
    let districtsUrlPath: String = "admin/location/districts/"
    let slotsInfoUrlPath: String = "appointment/sessions/public/calendarByDistrict"
    
    func getStatesList(completion: @escaping (StatesData?, SearchByDistrictAPIErrors?) -> Void) {
        let url: URL = URL(string: "\(baseUrl)\(stateListUrlPath)")!
        cowinSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil, .apiError(error: error))
                return
            }
            
            if let _data: Data = data, let states: StatesData = try? JSONDecoder().decode(StatesData.self, from: _data) {
                completion(states, nil)
            } else {
                completion(nil, .statesParsingFailed)
            }
        }.resume()
    }
    
    func getDistrictForState(stateId: Int, completion: @escaping (DistrictData?, SearchByDistrictAPIErrors?) -> Void) {
        let url: URL = URL(string: "\(baseUrl)\(districtsUrlPath)\(stateId)")!
        cowinSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil, .apiError(error: error))
                return
            }
            
            if let _data: Data = data, let districts: DistrictData = try? JSONDecoder().decode(DistrictData.self, from: _data) {
                completion(districts, nil)
            } else {
                completion(nil, .districtsParsingFailed)
            }
        }.resume()
    }
    
    func fetchSlotsInfo(forDate date: String, forDistrictId district: Int, completion: @escaping (CowinData?, SearchByDistrictAPIErrors?) -> Void) {
        let url: URL = URL(string: "\(baseUrl)\(slotsInfoUrlPath)?district_id=\(district)&date=\(date)")!
        cowinSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil, .apiError(error: error))
                return
            }
            
            if let _data: Data = data, let sessionsData: CowinData = try? JSONDecoder().decode(CowinData.self, from: _data) {
                completion(sessionsData, nil)
            } else {
                completion(nil, .slotsParsingFailed)
            }
        }.resume()
    }
}
