//
//  MapVC.swift
//  Virtual_Tourist_1.0
//
//  Created by maher malibari on 18/07/2019.
//  Copyright © 2019 maher malibari. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var context: NSManagedObjectContext{
        return DataController.sharedObject.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UdacityAPI.endSession { (error) in
            DispatchQueue.main.async {
                self.parent?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func createFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [
        NSSortDescriptor(key: "createDate", ascending: false)
        ]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            updateMap()
        }catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    func updateMap() {
        guard let pins = fetchedResultsController.fetchedObjects else {
            return
        }
        for pin in pins {
            if mapView.annotations.contains(where: { pin.compare(to: $0.coordinate)}){
                continue
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateMap()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = fetchedResultsController.fetchedObjects?.filter{
            $0.compare(to: view.annotation!.coordinate)}.first!
        performSegue(withIdentifier: "displayPhotos", sender: pin)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayPhotos" {
            let photosCollectionVC = segue.destination as! PhotoCollectionVC
            photosCollectionVC.pin = sender as? Pin
        }
    }

    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state != .began {
            return
        }
        
        let pointer = sender.location(in: mapView)
        let pin = Pin(context: context)
        pin.coordinate = mapView.convert(pointer, toCoordinateFrom: mapView)
        try? context.save()
        
    }
    
    
    
    
}
