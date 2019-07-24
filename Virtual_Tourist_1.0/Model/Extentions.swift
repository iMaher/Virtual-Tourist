//
//  Extentions.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 20/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import Foundation
import MapKit
import UIKit


extension Pin {
    var coordinate: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    func compare(to coordinate: CLLocationCoordinate2D) -> Bool {
        return (latitude == coordinate.latitude && longitude == coordinate.longitude)
    }
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createDate = Date()
    }
    
}

extension Photo {
    func set(image: UIImage) {
        self.image = image.pngData()
    }
    func get() -> UIImage? {
        return (image == nil) ? nil: UIImage(data: image!)
    }
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createDate = Date()
    }
}

extension ViewController {
    func alert(t: String, m: String?) {
        let alert = UIAlertController(title: t, message: m, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert,animated: true,completion: nil)
        }
    }
}

extension UIViewController {
    func alert(t: String?, m: String?) {
        let alert = UIAlertController(title: t, message: m, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert,animated: true,completion: nil)
        }
    }
}

extension UIViewController {
    func ActivityIndicator() -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(style: .gray)
        self.view.addSubview(ai)
        self.view.bringSubviewToFront(ai)
        ai.center = self.view.center
        ai.hidesWhenStopped = true
        ai.startAnimating()
        return ai
    }
}
