//
//  LeaderboardView.swift
//  FindMe
//
//  Created by Ryan D on 6/12/22.
//

import SwiftUI
import Charts
import CoreLocation
import MapKit

struct LeaderboardView: View {
    @EnvironmentObject var finding: FindingSession
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    
    @State var pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.334_900,
                                                                            longitude: -122.009_020)
    
    //add line coordinates after everyone has guessed
    @State private var allGuessCoordinates: [CLLocationCoordinate2D] = []
    @State private var winner: Person?
    @State private var distance: Int?
    
    var body: some View {
        MapView(centerCoordinate: .constant(region.center), pinLocation: $pinLocation, lines: true).environmentObject(finding)
            .ignoresSafeArea()
            .sheetWithDetents(isPresented: .constant(finding.gameState == .end),
                              detents: [.large(), .medium()],
                              onDismiss: {}) {
                VStack {
                    if let winner, let distance, let selector = finding.selector {
                        Text("\(winner.name) won! They were \(distance)km from the location that \(selector.name) chose.")
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(24)
                            .background(.white.opacity(0.05))
                    }
                    Chart {
                        ForEach(finding.guesses) { guess in
                            BarMark(
                                x: .value("Name", guess.person.name),
                                y: .value("Distance", calculateDistance(guess: guess.location, location: finding.location ?? .init(latitude: 0, longitude: 0)))
                            )
                            .cornerRadius(8)
                            .foregroundStyle(.linearGradient(colors: [.white, .white.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                            
                        }
                    }
                    .chartXAxis(.visible)
                    .chartYAxis(.hidden)
                    .allowsHitTesting(false)
                    Button("Restart") {
                        finding.reset()
                    }.buttonStyle(ProminentButtonStyle())
                        .padding(24)
                }
                .sheetStyle()
            }
            .onAppear {
                allGuessCoordinates = finding.guesses.map {
                    $0.location
                }
                if let location = finding.selectedLocation {
                    func distance(guess: CLLocationCoordinate2D) -> Double {
                        CLLocation(latitude: guess.latitude, longitude: guess.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
                    }
                    
                    winner = finding.guesses.sorted(by: { distance(guess: $0.location) > distance(guess: $1.location) }).first?.person
                    if let guess = finding.guesses.first(where: { $0.person.id == winner?.id }) {
                        self.distance = Int(distance(guess: guess.location))
                    }
                }
                
                
            }
    }
    
    func calculateDistance(guess: CLLocationCoordinate2D, location: CLLocationCoordinate2D) -> Double {
        return sqrt(pow(guess.longitude - location.longitude, 2) + pow(guess.latitude - location.latitude, 2))
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
