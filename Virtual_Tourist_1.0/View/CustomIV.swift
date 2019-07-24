//
//  CustomIV.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 18/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import UIKit

let imageCached = NSCache<NSString, AnyObject>()

class CustomIV: UIImageView {

    var photo: Photo! {
        didSet{
            if let image = photo.get() {
                    hideActivityIndicatiorView()
                self.image = image
                return
            }
            
            guard let url = photo.url else {
                return
            }
            
            loadImage(with: url)
        }
    }
    
    var imageUrl: URL!
    
    func loadImage(with url: URL) {
        showActivityIndicator()
        imageUrl = url
        image = nil
        
        if let cachedImage = imageCached.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = cachedImage
            hideActivityIndicatiorView()
            return
        }
        
        URLSession.shared.dataTask(with: url){
            (data, responds, error) in
            if let error = error {
                return
            }
            guard let downloadImage = UIImage (data: data!) else {
                return
            }
            imageCached.setObject(downloadImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = downloadImage
                self.photo.set(image: downloadImage)
                try? self.photo.managedObjectContext?.save()
                self.hideActivityIndicatiorView()
            }
        }
        .resume()
    }
    
    func setPhoto(_ newPhoto: Photo) {
        if photo != nil {
            if photo.createDate == newPhoto.createDate{
                return
            }
            
        }
        photo = newPhoto
    }
    
    lazy var activityIndicatiorView: UIActivityIndicatorView = {
        let activityIndicatiorView = UIActivityIndicatorView(style: .gray)
        self.addSubview(activityIndicatiorView)
        activityIndicatiorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatiorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicatiorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicatiorView.hidesWhenStopped = true
        return activityIndicatiorView
    }()
    
    func showActivityIndicator(){
        DispatchQueue.main.async {
            self.activityIndicatiorView.startAnimating()
        }
    }
    func hideActivityIndicatiorView() {
        DispatchQueue.main.async {
            self.activityIndicatiorView.stopAnimating()
        }
    }
    

}
