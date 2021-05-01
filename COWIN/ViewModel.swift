//
//  ViewModel.swift
//  COWIN
//
//  Created by Anush on 01/05/21.
//

import Foundation

class ViewModel{
    var centers:[Center] = []
    func getdata(pincode:String, offset:Int = 0, onComplete:@escaping ()->Void){
        //"https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=400068&date=20-05-2021"
        guard let offsetDate = Calendar.current.date(
          byAdding: .day,
          value: offset,
                to: Date()) else{
            return
        }
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        let dateStr = df.string(from: offsetDate)
        
        let url = URL(string: "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=\(pincode)&date=\(dateStr)")!
        
        URLSession.shared.dataTask(with: url) {(_data, response, error) in
            if let data = _data, let obj = try? JSONDecoder().decode(CowinData.self, from: data),let newCenters = obj.centers, !newCenters.isEmpty{
                for newCenter in newCenters{
                    if let index = self.centers.firstIndex(where: { (item) -> Bool in
                        item.centerID == newCenter.centerID
                    }){
                        self.centers[index].sessions?.append(contentsOf: newCenter.sessions ?? [])
                    }else{
                        self.centers.append(newCenter)
                    }
                }
                if offset < 100{
                    self.getdata(pincode: pincode, offset: offset+7) {
                        onComplete()
                    }
                }else{
                    onComplete()
                }
            }else{
                if offset < 100{
                    self.getdata(pincode: pincode, offset: offset+7) {
                        onComplete()
                    }
                }else{
                    onComplete()
                }
            }
        }.resume()
    }
}
