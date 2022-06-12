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
    @State private var lineCoordinates: [CLLocationCoordinate2D] = [
        // Steve Jobs theatre
        CLLocationCoordinate2D(latitude: 37.330828, longitude: -122.007495),
        // Caffè Macs
        CLLocationCoordinate2D(latitude: 37.336083, longitude: -122.007356),
        // Apple wellness center
        CLLocationCoordinate2D(latitude: 37.336901, longitude:  -122.012345)]
    
    var body: some View {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Material.ultraThinMaterial)
                        .ignoresSafeArea()
                        .frame(height: 120)
                    
                    VStack{
                        HStack {
                            Text("Make Your Guess")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            Spacer()
                            Text("\(finding.guesses.count)/\(finding.people.count-1)")
                                .font(.system(size: 16, weight: .light))
                                .padding(.horizontal)
                            
                            InitialsView(initials: finding.me?.initials ?? "You")
                        }
                        .padding()
                        
                        TimelineView(.animation) { context in
                            ZStack(alignment: .leading) {
                                Rectangle().fill(.white)
                                Rectangle().fill(.blue)
                                    .scaleEffect(x: (context.date.timeIntervalSince1970-finding.startDate!.timeIntervalSince1970)/(finding.endDate!.timeIntervalSince1970-finding.startDate!.timeIntervalSince1970), anchor: .trailing)
                            }.frame(height: 10)
                        }
                    }
                }.frame(height: 95)
                    .offset(y: 10)
                
                ZStack {
                    MapView(centerCoordinate: .constant(region.center),
                            pinLocation: $pinLocation,
                            lineCoordinates: lineCoordinates)
                    .edgesIgnoringSafeArea(.all)
                    .offset(y: 0)
                    
                    VStack {
                        HStack(alignment: .top) {
                            Spacer()
                            TimelineView(.animation) { context in
                                Text("\(round(finding.endDate!.timeIntervalSince1970-context.date.timeIntervalSince1970)) seconds remaining")
                            }
                        }
                        
                        Button("Submit guess") {
                            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                            finding.makeGuess(location: pinLocation)
                        }.buttonStyle(ProminentButtonStyle())
                        Spacer()
                    }
                }
            }
            /*.onChange(of: self.timeRemaining, perform: { idk in
                if timeRemaining <= 0 {
                    if finding.gameState == .guessingLocation {
                        print("Times UP!")
                        finding.makeGuess(location: pinLocation)
                        // wait 3 seconds and hope everyones guess made it to the user!
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            //self.addResultLines()
                        }
                        finding.gameState = .end
                    }
                }
            })*/
    }
}
