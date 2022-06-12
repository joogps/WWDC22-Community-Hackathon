//
//  MapView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 12/06/22.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var pinLocation: CLLocationCoordinate2D
    
    let mapView = MKMapView()
    
    //poly lines
    let lineCoordinates: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
        mapView.addOverlay(polyline)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        //print(#function)
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
            self.parent.mapView.addAnnotation(annotation)
            self.placedPin(coordinate)
            
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let routePolyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routePolyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
        
    }
}
