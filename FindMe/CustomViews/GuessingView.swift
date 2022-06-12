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
                ZStack {
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
                            Text("\(finding.guesses.count)/\(finding.people.count)")
                                .font(.system(size: 16, weight: .light))
                                .padding(.horizontal)
                            
                            ZStack {
                                Text("JG")
                                    .padding()
                                    .background(
                                        Circle()
                                            .fill(.red)
                                        
                                    )
                            }.padding(.horizontal)
                        }
                        
                        ZStack(alignment: .leading){
                            Rectangle().frame( height: 10).foregroundColor(.white)
                            Rectangle().frame(width: (self.timeRemaining / 90.0) * geo.size.width, height: 10).foregroundColor(.blue)
                        }
                    }
                }.frame(height: 95)
                    .offset(y:10)
                
                
                ZStack {
                    MapView(centerCoordinate: .constant(region.center),
                            pinLocation: $pinLocation,
                            lineCoordinates: lineCoordinates)
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
                        Button("Submit guess") {
                            finding.makeGuess(location: pinLocation)
                        }.buttonStyle(ProminentButtonStyle())
                        Spacer()
                    }
                }
            }
            .onReceive(justATimer) { time in
                if let endTime = finding.endTime {
                    self.timeRemaining = endTime.timeIntervalSinceNow
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
                        finding.gameState = .timeLimitUp
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
