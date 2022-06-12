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
    
    @State private var center = CLLocationCoordinate2D(latitude: 37.334_900,
                                                       longitude: -122.009_020)
    
    @State var pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.334_900,
                                                                            longitude: -122.009_020)
    
    //add line coordinates after everyone has guessed
    @State private var allGuessCoordinates: [CLLocationCoordinate2D] = []
    @State private var winner: Person?
    @State private var distance: Int?
    
    @State private var showSheet = false
    
    var body: some View {
        MapView(centerCoordinate: $center, pinLocation: .constant(pinLocation), lines: true)
            .environmentObject(finding)
            .edgesIgnoringSafeArea(.all)
            .sheetWithDetents(isPresented: .constant(finding.gameState == .end),
                              detents: [.large(), .medium()],
                              onDismiss: {}) {
                VStack(spacing: 0) {
                    VStack {
                        if let winner, let distance, let selector = finding.selector {
                            Text("\(winner.id == finding.me?.id ? "You" : winner.name) won!")
                                .font(.custom("SF Pro Expanded Bold", size: 24))
                            
                            Text("\(winner.id == finding.me?.id ? "You" : "They") were \(distance) km away from the location \(selector.name) chose.")
                                .bold()
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }.padding(24)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.white.opacity(0.05))
                    
                    Chart {
                        ForEach(finding.guesses) { guess in
                            BarMark(
                                x: .value("Name", guess.person.name),
                                y: .value("Distance", distance(guess: guess.location, location: finding.location ?? .init(latitude: 0, longitude: 0)))
                            )
                            .cornerRadius(8)
                            .foregroundStyle(.linearGradient(colors: [.white, .white.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                            
                        }
                    }
                    .chartXAxis(.visible)
                    .chartYAxis(.hidden)
                    .allowsHitTesting(false)
                    .padding(.top, 24)
                    Button("Next round") {
                        finding.gameState = .waitingForPlayers
                        finding.reset()
                    }.buttonStyle(ProminentButtonStyle())
                        .padding(24)
                        .padding(.bottom, 12)
                }
                .multilineTextAlignment(.center)
                .sheetStyle()
            }
            .onAppear {
                allGuessCoordinates = finding.guesses.map {
                    $0.location
                }
                
                if let location = finding.selectedLocation {
                    self.center = location
                    
                    func distance(guess: CLLocationCoordinate2D) -> Double {
                        self.distance(guess: guess, location: location)
                    }
                    
                    winner = finding.guesses.sorted(by: { distance(guess: $0.location) > distance(guess: $1.location) }).first?.person
                    if let guess = finding.guesses.first(where: { $0.person.id == winner?.id }) {
                        self.distance = Int(distance(guess: guess.location))
                    }
                }
                
                finding.gameState = .end
            }
    }
    
    func distance(guess: CLLocationCoordinate2D, location: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: guess.latitude, longitude: guess.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
