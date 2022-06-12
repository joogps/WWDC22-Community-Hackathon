//
//  MapView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 12/06/22.
//

import SwiftUI
import MapKit
import CoreLocation

final class LocationAnnotationView: MKAnnotationView {

    // MARK: Initialization

    init(annotation: MKAnnotation?, reuseIdentifier: String?, initials: String, systemImage: String? = nil) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)

        canShowCallout = true
//        if let annotation = annotation {
//            setupUI(initials: ((annotation.title) ?? "📌")!)
//        }
        setupUI(initials: initials, systemImage: systemImage)
        
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func setupUI(initials: String, systemImage: String? = nil) {
        backgroundColor = .clear

        let vc = UIHostingController(rootView: CircleView(initials: initials, systemIcon: systemImage, padding: 4))
        vc.view.backgroundColor = .clear
        guard let view = vc.view else {
            print("ERRORRRRRRRR")
            return
        }
        addSubview(view)

        view.frame = bounds
    }
}

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var pinLocation: CLLocationCoordinate2D
    @EnvironmentObject var finding: FindingSession
    
    let mapView = MKMapView()
    
    
    //poly lines
    var lines: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.register(LocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pinID")
        mapView.delegate = context.coordinator
        
        if lines {
            
            sleep(1)
            let lineCoordinates = finding.guesses.map({ $0.location })
            if finding.gameState == .end {
                print("adding Lines \(lineCoordinates)")
                for guessCoordinate in lineCoordinates {
                    let polyline = MKPolyline(coordinates: [guessCoordinate, finding.selectedLocation!], count: 2)
                    print("added a line")
                    mapView.addOverlay(polyline)
                }
            }
            
            //add initials
            for guess in finding.guesses {
                let annotation = MKPointAnnotation()
//                annotation.title = guess.person.initials
                annotation.coordinate = guess.location
                self.mapView.addAnnotation(annotation)
            }
            
            if let selectedLocation = finding.selectedLocation {
                let annotation = MKPointAnnotation()
//                annotation.title = "Selected Location"
                annotation.coordinate = selectedLocation
                self.mapView.addAnnotation(annotation)
            }
            
        }

        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, placedPin: { location in
            print(location)
            self.pinLocation = location
        })
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView
        
        var gRecognizer = UITapGestureRecognizer()
        var annotation = MKPointAnnotation()
        let placedPin: ((CLLocationCoordinate2D)->())
        
        init(_ parent: MapView, placedPin: @escaping ((CLLocationCoordinate2D)->())) {
            self.parent = parent
            self.placedPin = placedPin
            super.init()
            self.gRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
            self.gRecognizer.delegate = self
            self.parent.mapView.addGestureRecognizer(gRecognizer)
        }
        
        @objc func tapHandler(_ gesture: UITapGestureRecognizer) {
            // position on the screen, CGPoint
            let location = gRecognizer.location(in: self.parent.mapView)
            // position on the map, CLLocationCoordinate2D
            let coordinate = self.parent.mapView.convert(location, toCoordinateFrom: self.parent.mapView)
            
            annotation.coordinate = coordinate
//            annotation.title = self.parent.finding.me?.initials ?? "🤷‍♂️"
            self.parent.mapView.addAnnotation(annotation)
            self.placedPin(coordinate)
            
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
          if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor(Color.accentColor)
            renderer.lineWidth = 6
            return renderer
          }
          return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            print("ANNOTATION")
            print(annotation)
            print("an coordinate")
            print(annotation.coordinate)
            print("guesses coordinates")
            print(self.parent.finding.guesses.map({$0.location}))
            
            var initials = self.parent.finding.guesses.first(where: { $0.location == annotation.coordinate })?.person.initials
            var systemImage: String? = nil
            
            if initials == nil {
                if annotation.coordinate == self.parent.finding.selectedLocation {
                    systemImage = "star.fill"
                } else {
                    systemImage = "pin.fill"
                }
            }
            
            let customAnnotation = LocationAnnotationView(annotation: annotation, reuseIdentifier: "pinId",
                                                          initials: initials ?? "",
                                                        systemImage: systemImage)
            return customAnnotation
        }
        
    }
}

