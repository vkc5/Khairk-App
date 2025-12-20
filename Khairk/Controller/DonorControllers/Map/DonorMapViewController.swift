//
//  DonorMapViewController.swift
//  Khairk
//
//  Created by vkc5 on 16/12/2025.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

final class NGOAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

class DonorMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
        @IBOutlet weak var mapView: MKMapView!
        private var latestUserCoordinate: CLLocationCoordinate2D?

        private let locationManager = CLLocationManager()
    
        private let db = Firestore.firestore()
        private var ngoAnnotations: [MKAnnotation] = []

        // ✅ safer than "!"
        private var ngoCoordinate: CLLocationCoordinate2D?

        private var hasCenteredOnUser = false
        private var lastRoutedLocation: CLLocationCoordinate2D?
        private var directions: MKDirections?

        override func viewDidLoad() {
            super.viewDidLoad()

            mapView.delegate = self
            mapView.showsUserLocation = true   // ✅ show blue dot

            loadNGOPins()
            setupLocation()
        }

        // MARK: - Location

        private func setupLocation() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()

            // ✅ if already authorized, start right away
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
               locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            latestUserCoordinate = location.coordinate

            // ✅ center map only once
            if !hasCenteredOnUser {
                hasCenteredOnUser = true
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 2000,
                    longitudinalMeters: 2000
                )
                mapView.setRegion(region, animated: true)
            }
            print("✅ didUpdateLocations:", location.coordinate.latitude, location.coordinate.longitude)
        }

        private func shouldUpdateRoute(current: CLLocationCoordinate2D) -> Bool {
            guard let last = lastRoutedLocation else { return true }

            let lastLoc = CLLocation(latitude: last.latitude, longitude: last.longitude)
            let currentLoc = CLLocation(latitude: current.latitude, longitude: current.longitude)

            return currentLoc.distance(from: lastLoc) > 50 // meters
        }

        // MARK: - NGO Pin

        private func loadNGOPins() {
            db.collection("users")
                .whereField("role", isEqualTo: "collector")
                .getDocuments { [weak self] snap, error in
                    guard let self = self else { return }

                    if let error = error {
                        print("❌ Load NGOs error:", error.localizedDescription)
                        return
                    }

                    self.mapView.removeAnnotations(self.ngoAnnotations)
                    self.ngoAnnotations.removeAll()

                    for doc in snap?.documents ?? [] {
                        let data = doc.data()

                        // ✅ filter locally (no index needed)
                        guard let geo = data["ngoLocation"] as? GeoPoint else { continue }

                        let name = (data["name"] as? String)
                            ?? (data["ngoName"] as? String)
                            ?? "NGO"

                        let coord = CLLocationCoordinate2D(latitude: geo.latitude, longitude: geo.longitude)

                        let ann = NGOAnnotation(title: name, subtitle: "Tap for info", coordinate: coord)
                        self.ngoAnnotations.append(ann)
                    }

                    DispatchQueue.main.async {
                        self.mapView.addAnnotations(self.ngoAnnotations)
                        self.zoomToFitAllPins()
                    }
                }
        }

        private func zoomToFitAllPins() {
            guard !ngoAnnotations.isEmpty else { return }

            var rect = MKMapRect.null
            for ann in ngoAnnotations {
                let point = MKMapPoint(ann.coordinate)
                let r = MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1)
                rect = rect.union(r)
            }

            mapView.setVisibleMapRect(
                rect,
                edgePadding: UIEdgeInsets(top: 120, left: 50, bottom: 120, right: 50),
                animated: true
            )
        }


        // MARK: - Directions
        private func showRouteToNGO(from userLocation: CLLocationCoordinate2D) {
            guard let ngoCoordinate = ngoCoordinate else {
                print("❌ ngoCoordinate is nil")
                return
            }

            directions?.cancel()

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: ngoCoordinate))
            request.transportType = .automobile

            let dir = MKDirections(request: request)
            directions = dir

            dir.calculate { [weak self] response, error in
                guard let self = self else { return }

                if let nsError = error as NSError? {
                    print("❌ Directions error:", nsError.localizedDescription)
                    print("   Domain:", nsError.domain, "Code:", nsError.code)

                    // ✅ fallback test: try walking (debug)
                    let walkReq = MKDirections.Request()
                    walkReq.source = request.source
                    walkReq.destination = request.destination
                    walkReq.transportType = .walking

                    MKDirections(request: walkReq).calculate { resp2, err2 in
                        if let err2 = err2 {
                            print("❌ Walking also failed:", err2.localizedDescription)
                            return
                        }
                        guard let route2 = resp2?.routes.first else {
                            print("❌ No walking routes returned")
                            return
                        }
                        DispatchQueue.main.async {
                            self.mapView.removeOverlays(self.mapView.overlays)
                            self.mapView.addOverlay(route2.polyline)
                            self.mapView.setVisibleMapRect(
                                route2.polyline.boundingMapRect,
                                edgePadding: UIEdgeInsets(top: 120, left: 60, bottom: 220, right: 60),
                                animated: true
                            )
                        }
                    }

                    return
                }

                guard let route = response?.routes.first else {
                    print("❌ No routes returned (response empty)")
                    return
                }

                print("✅ Route distance:", route.distance)

                DispatchQueue.main.async {
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.addOverlay(route.polyline)

                    self.mapView.setVisibleMapRect(
                        route.polyline.boundingMapRect,
                        edgePadding: UIEdgeInsets(top: 120, left: 60, bottom: 220, right: 60),
                        animated: true
                    )
                }
            }
        }
    
        // MARK: - MKMapViewDelegate

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemGreen
            renderer.lineWidth = 5
            return renderer
        }
    
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let id = "ngoPin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView

            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
                view?.canShowCallout = true

                // add info button on the callout
                let btn = UIButton(type: .detailDisclosure)
                view?.rightCalloutAccessoryView = btn
            } else {
                view?.annotation = annotation
            }

            view?.markerTintColor = .systemRed
            return view
        }
    
        func mapView(_ mapView: MKMapView,
                     annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {

            guard let ngo = view.annotation as? NGOAnnotation else { return }
            self.ngoCoordinate = ngo.coordinate   // ✅ IMPORTANT
            presentNGOSheet(name: ngo.title ?? "NGO", coordinate: ngo.coordinate)
        }
    
        private func presentNGOSheet(name: String, coordinate: CLLocationCoordinate2D) {
            let vc = NGOBottomSheetViewController()
            vc.ngoName = name
            vc.ngoCoordinate = coordinate
            vc.onDirectionsTapped = { [weak self] in
                guard let self = self,
                      let userCoord = self.latestUserCoordinate else {
                    print("❌ No user location yet")
                    return
                }
                self.showRouteToNGO(from: userCoord)
            }

            if let sheet = vc.sheetPresentationController {
                sheet.detents = [
                    .custom { _ in 120 }   // 👈 height in points
                ]
                sheet.prefersGrabberVisible = true
            }

            present(vc, animated: true)
        }
    }

