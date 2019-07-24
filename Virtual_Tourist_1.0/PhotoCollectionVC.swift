//
//  PhotoCollectionVC.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 18/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoCollectionVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var newPhotosButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var pageNum = 1
    var clearStatus = false
    
    var context: NSManagedObjectContext {
        return DataController.sharedObject.viewContext
    }
    
    var numOfPhotos: Bool {
        return (fetchedResultsController.fetchedObjects?.count ?? 0 ) != 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    self.noPhotosLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createFetchedResultsController()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    @IBAction func newPhotosButtonPressed(_ sender: Any) {
        
        updateView(process: true) 
        if numOfPhotos{
            clearStatus = true
            for photo in fetchedResultsController.fetchedObjects! {
                context.delete(photo)
            }
            try? context.save()
            clearStatus = false
        }
        
        FlickerAPI.getPhotosURLs(with: pin.coordinate, pageNumber: pageNum) { (urls, error, errorMsg) in
            DispatchQueue.main.async {
                self.updateView(process: false)
                
                guard (error == nil) && (errorMsg == nil) else {
                    self.alert(t: "Error", m: error?.localizedDescription ?? errorMsg)
                    return
                }
                
                guard let urls = urls, !urls.isEmpty else {
                    self.noPhotosLabel.isHidden = false
                    return
                }
                
                self.noPhotosLabel.isHidden = true
                
                for url in urls {
                    let photo = Photo(context: self.context)
                    photo.url = url
                    photo.pin = self.pin
                    try? self.context.save()
                }
                
            }
        }
        pageNum = pageNum+1
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.photoCellImageView.setPhoto(photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        context.delete(photo)
        try? context.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-20)/3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    
    func updateView(process: Bool) {
        collectionView.isUserInteractionEnabled = !process
        if process {
            newPhotosButton.title = ""
            activityIndicator.startAnimating()
        }else {
            activityIndicator.stopAnimating()
            newPhotosButton.title = "New Photos"
        }
    }
    
    func createFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createDate", ascending: false)
        ]
        
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if numOfPhotos {
                updateView(process: false)
            }else {
                newPhotosButtonPressed(self)
            }

        }catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange didChangeanObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let indexPath = indexPath, type == .delete && !clearStatus {
            collectionView.deleteItems(at: [indexPath])
            return
        }
        if let indexPath = newIndexPath, type == .insert  {
            collectionView.insertItems(at: [indexPath])
            return
        }
        
        if type != .update {
            collectionView.reloadData()
        }
    }
    
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
