//
//  Constants.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 20/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import Foundation
import MapKit

struct Constants {

    
    struct FlickerParamKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    struct FlickerParmValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "74eb712ea367441145b005f22b644b13"
        static let ResponseFormat = "json"
        static let DisableJSONCallBack = "1"
        static let GalleryPhotoMethod = "flicker.galleries.photos"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PerPage = "15"
    }
}
