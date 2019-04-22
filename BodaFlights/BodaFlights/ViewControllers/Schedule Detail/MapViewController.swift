//
//  MapViewController.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/22/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SVProgressHUD

class AirportPin: MKPointAnnotation {
    enum AirportType {
        case departure, arrival, transit
        
        var icon: UIImage {
            switch self {
            case .departure:
                return R.image.iconDepartPin()!
            case .arrival:
                return R.image.iconArrivePin()!
            default:
                return R.image.iconTransitPin()!
            }
        }
    }
    var airportType: AirportType = .transit
    init(airport: Airport) {
        super.init()
        title = airport.name
        subtitle = airport.code
        coordinate = airport.location!.coordinate
    }
    
}

class MapViewController: BaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var schedule: Schedule! {
        didSet {
            schedule.updateAirports()
        }
    }
    private let annotationIdentifier = "AnnotationIdentifier"
    
    static func show(schedule: Schedule) {
        let vc = R.storyboard.main.mapViewController()!
        vc.schedule = schedule
        UIViewController.topMostController().present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        var coordinates = schedule.coordinates
        let airports = schedule.airports
        let geoPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: coordinates.count)
        mapView.addOverlay(geoPolyline)

        for airport in airports {
            if airport.location != nil {
                let pin = AirportPin(airport: airport)
                if airport == airports.first {
                    pin.airportType = .departure
                } else if airport == airports.last {
                    pin.airportType = .arrival
                }
                mapView.addAnnotation(pin)
            }
        }
        
        let rect = geoPolyline.boundingMapRect
        //mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
        renderer.alpha = 0.5
        renderer.strokeColor = UIColor.BodaColors.orange
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let aiportPin = annotation as? AirportPin else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        annotationView!.image = aiportPin.airportType.icon
        return annotationView
    }
}
