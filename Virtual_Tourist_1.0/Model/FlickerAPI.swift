//
//  FlickerAPI.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 20/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import Foundation
import MapKit

struct FlickerAPI {
    static func getPhotosURLs(with coordinate: CLLocationCoordinate2D, pageNumber: Int,completion: @escaping([URL]? , Error? , String?) -> () ) {
        let methodParameters = [
            Constants.FlickerParamKeys.Method: Constants.FlickerParmValues.SearchMethod,
            Constants.FlickerParamKeys.APIKey: Constants.FlickerParmValues.APIKey,
            Constants.FlickerParamKeys.BoundingBox: bboxString(for: coordinate),
            Constants.FlickerParamKeys.SafeSearch: Constants.FlickerParmValues.UseSafeSearch,
            Constants.FlickerParamKeys.Extras: Constants.FlickerParmValues.MediumURL,
            Constants.FlickerParamKeys.Format: Constants.FlickerParmValues.ResponseFormat,
            Constants.FlickerParamKeys.NoJSONCallBack: Constants.FlickerParmValues.DisableJSONCallBack,
            Constants.FlickerParamKeys.Page: pageNumber,
            Constants.FlickerParamKeys.PerPage: Constants.FlickerParmValues.PerPage,
        ] as [String:Any]
        
        let requestURL =  URLRequest(url: getURL(from: methodParameters))
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data , response, error) in
            
            guard (error == nil) else {
                completion(nil , error , nil)
                return
            }
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            guard  statusCode! >= 200 && statusCode! <= 299 else {
                var errorMsg = ""
                if statusCode == 400 {
                    errorMsg = "Bad Request"
                } else if statusCode == 401 {
                    errorMsg = "Invalid Credentials"
                } else if statusCode == 403 {
                    errorMsg = "Unauthorized"
                } else if statusCode == 405 {
                    errorMsg = "HTTP Method Not Allowed"
                } else if statusCode == 410 {
                    errorMsg = "URL Changed"
                } else if statusCode == 500 {
                    errorMsg = "Server Error"
                } else {
                    errorMsg = "Try Again"
                }
                completion(nil,nil,errorMsg)
                return
            }
            
            guard let data = data else {
                completion(nil,nil,"data not found")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else {
                completion(nil,nil,"cannot parse to JSON")
                return
            }
            
            guard let status = result["stat"] as? String, status == "ok" else {
                completion(nil,nil,"Error while using Flicker API, error code: \(result)")
                return
            }
            
            guard let photoDict = result["photos"] as? [String:Any] else {
                completion(nil,nil,"key not found")
                return
            }
            
            guard let photoArray = photoDict["photo"] as? [[String:Any]] else {
                completion(nil,nil,"key not found")
                return
            }
            
            
            let photoURLs = photoArray.compactMap {
                photoDict -> URL? in
                guard let url = photoDict["url_m"] as? String else {
                    return nil
                }
                return URL(string: url)
            }
            
            completion(photoURLs,nil,nil)
            
        }
        
        task.resume()
        
    }
    
    static func bboxString(for coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let searchBBoxHalfLength = 0.6
        
        let minLon = max(longitude - searchBBoxHalfLength, -180)
        let minLat = max(latitude - searchBBoxHalfLength, -90)
        let maxLon = min(longitude + searchBBoxHalfLength, 180)
        let maxLat = min(latitude + searchBBoxHalfLength, 90)
        
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    static func getURL(from parameters: [String:Any]) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let query = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(query)
        }
        
        return components.url!
    }
}

