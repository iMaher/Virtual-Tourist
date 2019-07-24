//
//  UdacityAPI.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 24/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import Foundation
import MapKit

class UdacityAPI {
    static func createSession(with email: String, password:String,completion: @escaping (String?) -> ()){
        var request = URLRequest(url:URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let statusCoDeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion(statusCoDeError.localizedDescription)
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
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
                completion(errorMsg)
                return
            }
            
            
            let newData = data![5..<data!.count]
            let result = try! JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            print(String(data: newData, encoding: .utf8)!)
            
            
            
            let account = result["account"] as? [String: Any]
            let key = account?["key"] as? String
            
            UserData.loginKey = key ?? ""
            completion(nil)
            
        }
        task.resume()
    }
    
    static func getUserData(completion: @escaping (String?) -> ()){
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(UserData.loginKey)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let statusCoDeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion(statusCoDeError.localizedDescription)
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
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
                completion(errorMsg)
                return
            }
            
            
            let newData = data![5..<data!.count]
            let result = try! JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            print(String(data: newData, encoding: .utf8)!)
            
            let firstName: String?
            let lastName: String?
            
            if let account = result["user"] as? [String: Any]{
                firstName = account["first_name"] as? String
                lastName = account["last_name"] as? String
            }else {
                firstName = result["first_name"] as? String
                lastName = result["last_name"] as? String
            }
            
            UserData.randomFirstName = firstName ?? "Maher"
            UserData.randomLastName = lastName ?? "Malibari"
            
            
            
            completion(nil)
            
        }
        task.resume()
    }
    
    static func endSession(completion: @escaping (Error?) -> ()){
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(error)
                return
            }
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            
            completion(nil)
        }
        task.resume()
    }
    
    class Parse {
        static func postLocation(link: String, coordinate: CLLocationCoordinate2D, name: String, completion: @escaping (Error?) -> ()){
            var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-ID")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"\(UserData.loginKey)\", \"firstName\": \"\(UserData.randomFirstName)\", \"lastName\": \"\(UserData.randomLastName)\",\"mapString\": \"\(name)\", \"mediaURL\": \"\(link)\",\"latitude\":\(coordinate.latitude), \"longitude\":\(coordinate.longitude)}".data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion(error)
                    return
                }
                print(String(data: data!, encoding: .utf8)!)
                completion(nil)
            }
            task.resume()
        }
        
        static func getLocations ( completion: @escaping (String?) -> ()){
            let orignalURL = "https://onthemap-api.udacity.com/v1/StudentLocation"
            var request = URLRequest(url: URL(string: orignalURL+"?limit=100&order=-updatedAt")!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-ID")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    completion(error?.localizedDescription)
                    return
                }
                let a = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                guard let results = a["results"] as? [[String:Any]] else {
                    return
                }
                let result = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
                let locations = try! JSONDecoder().decode([StudentLocation].self, from: result)
                Shareable.shared.locations = locations
                completion(nil)
                
            }
            task.resume()
        }
    }
}

