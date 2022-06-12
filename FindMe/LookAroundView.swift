//
//  LookAroundView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import MapKit

struct LookAroundView<Content: View>: View {
    var coordinate = CLLocationCoordinate2D(latitude: 37.73536, longitude: -122.40709)
    
    @State var lookAroundScene: MKLookAroundScene?
    @State var presenting = false
    
    var content: () -> (Content)
    
    var body: some View {
        HStack {
            if let lookAroundScene {
                LookAroundViewRepresentable(scene: lookAroundScene)
                    .frame(height: 200)
                    .cornerRadius(24)
                    .padding(20)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            presenting = true
                        }
                    }.sheetWithDetents(isPresented: $presenting,
                                       presentOnTop: true,
                                       detents: [.large(), .medium()],
                                       onDismiss: {},
                                       content: {
                        content()
                            .sheetStyle()
                    })
            }
        }.onChange(of: presenting) { presenting in
            print(true)
        }.task {
            let sceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
            do {
                lookAroundScene = try await sceneRequest.scene
            } catch {
                
            }
        }
    }
}



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


struct MakeGuessView: View {
    @EnvironmentObject var finding: FindingSession
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    @State var timeRemaining = 44.0
    @State var pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.334_900,
                                                                            longitude: -122.009_020)
    let justATimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    //add line coordinates after everyone has guessed
    @State private var lineCoordinates: [CLLocationCoordinate2D] = [
        // Steve Jobs theatre
        CLLocationCoordinate2D(latitude: 37.330828, longitude: -122.007495),
        // Caffè Macs
        CLLocationCoordinate2D(latitude: 37.336083, longitude: -122.007356),
        // Apple wellness center
        CLLocationCoordinate2D(latitude: 37.336901, longitude:  -122.012345)]
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack{
                    
                    Rectangle()
                        .fill(Material.ultraThinMaterial)
                        .ignoresSafeArea()
                        .frame(height: 120)
                    
                    VStack{
                        HStack {
                            Text("Make Your Guess")
                                .font(.system(size: 20,weight: .bold))
                                .padding(.horizontal)
                            Spacer()
                            Text("4/6")
                                .font(.system(size: 16, weight: .light))
                                .padding(.horizontal)
                            
                            //                    if let me = finding.me {
                            ZStack{
                                Text("JG")
                                    .padding()
                                    .background(
                                        Circle()
                                            .fill(.red) //me.color
                                        
                                    )
                                
                            }.padding(.horizontal)
                            //                    }
                            
                        }
                        ZStack(alignment: .leading){
                            
                            Rectangle().frame( height: 10).foregroundColor(.white)
                            
                            Rectangle().frame(width: (self.timeRemaining / 90.0) * geo.size.width, height: 10).foregroundColor(.blue)
                        }
                        
                        
                    }
                }.frame(height: 95)
                    .offset(y:10)
                
                
                ZStack {
                    MapView(centerCoordinate: .constant(region.center), pinLocation: $pinLocation, lineCoordinates: lineCoordinates)
                    
                    
                        .edgesIgnoringSafeArea(.all)
                        .offset(y:-10)
                    
                    VStack{
                        HStack(alignment: .top) {
                            Spacer()
                            if self.timeRemaining <= 0 {
                                Text("Time's up")
                            } else {
                                Text("\(Int(round(self.timeRemaining))) seconds remaining")
                            }
                        }
                        Button("submit guess") {
                            finding.makeGuess(location: pinLocation)
                        }
                        Spacer()
                    }
                }
                
            }
            .onReceive(justATimer) { time in
                if let game = finding.game {
                    self.timeRemaining = game.endGuessTime.timeIntervalSince1970 - Date().timeIntervalSince1970
                    print("timeRemaining: \(timeRemaining)")
                }
            }
            .onChange(of: self.timeRemaining, perform: { idk in
                if timeRemaining <= 0 {
                    if finding.gameState == .guessingLocation {
                        print("Times UP!")
                        finding.makeGuess(location: pinLocation)
                        // wait 3 seconds and hope everyones guess made it to the user!
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.addResultLines()
                        }
                    }
                }
            })
        }
    }
    func addResultLines() {
        for guess in self.finding.guesses {
            self.lineCoordinates.append(guess.location)
        }
    }
}
struct LookAroundViewRepresentable: UIViewControllerRepresentable {
    let scene: MKLookAroundScene
    
    typealias UIViewControllerType = MKLookAroundViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let lookAround = MKLookAroundViewController(scene: scene)
        return lookAround
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
