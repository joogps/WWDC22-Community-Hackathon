//
//  GuessingView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 12/06/22.
//

import SwiftUI
import MapKit

struct GuessingView: View {
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
    
    var body: some View {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Material.ultraThinMaterial)
                        .ignoresSafeArea()
                        .frame(height: 120)
                    
                    VStack{
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Make Your Guess")
                                    .font(.custom("SF Pro Expanded Heavy", size: 24))
                                    .allowsTightening(true)
                                    .minimumScaleFactor(0.1)
                                
                                TimelineView(.animation) { context in
                                    Text("\(Int(finding.endDate!.timeIntervalSince1970-context.date.timeIntervalSince1970)) seconds remaining")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                            }.padding(.horizontal, 2)
                            Spacer()
                            Text("\(finding.guesses.count)/\(finding.people.count-1)")
                                .padding(.horizontal, 2)
                            
                            CircleView(initials: finding.me?.initials ?? "You")
                        }
                        .offset(y: 10)
                        .padding()
                        Spacer()
                        TimelineView(.animation) { context in
                            ZStack(alignment: .leading) {
                                Rectangle().fill(.white)
                                Rectangle().fill(Color.accentColor)
                                    .scaleEffect(x: 1-(context.date.timeIntervalSince1970-finding.startDate!.timeIntervalSince1970)/(finding.endDate!.timeIntervalSince1970-finding.startDate!.timeIntervalSince1970), anchor: .leading)
                            }.frame(height: 20)
                        }
                    }
                }.frame(height: 95)
                
                ZStack {
                    if finding.gameState == .end {
                        MapView(centerCoordinate: .constant(region.center), pinLocation: $pinLocation, lines: true).environmentObject(finding)
                            .edgesIgnoringSafeArea(.all)
                            .offset(y: 0)
                    }else {
                        MapView(centerCoordinate: .constant(region.center), pinLocation: $pinLocation, lines: false).environmentObject(finding)
                            .edgesIgnoringSafeArea(.all)
                            .offset(y: 0)
                    }
                    VStack {
                        Spacer()
                        
                        Button("Submit guess") {
                            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                            finding.makeGuess(location: pinLocation)
                        }.buttonStyle(ProminentButtonStyle())
                            .padding()
                            .padding(.bottom)
                            .disabled(pinLocation == CLLocationCoordinate2D(latitude: 37.334_900,
                                                                            longitude: -122.009_020))
                    }
                }
            }
    }
}
