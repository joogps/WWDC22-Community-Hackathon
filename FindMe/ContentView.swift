//
//  ContentView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State var region: MKCoordinateRegion = .init(center: .init(latitude: .zero, longitude: .zero),
                                                  span: .init(latitudeDelta: 80.0, longitudeDelta: 80.0))
    @EnvironmentObject var finding: FindingSession
    @State var showLookaround = false
    
    var body: some View {
        Group {
            switch finding.gameState {
            case .waitingForPlayers:
                ZStack {
                    
                    
                    Map(coordinateRegion: $region)
                    
                    VStack {
                        
                        HStack {
                            HStack {
                                Image(systemName: "globe.desk")
                                    .opacity(0.5)
                                Text("FindMe")
                                Button("Switch") {
                                    self.showLookaround.toggle()
                                }
                            }
                            .padding(.vertical, 80)
                            .padding(.horizontal, 30)
                            Spacer()
                        }
                        .font(.largeTitle.bold())
                        .background {
                            Rectangle()
                                .fill(.linearGradient(colors: [.black, .black.opacity(0.0)],
                                                      startPoint: .top,
                                                      endPoint: .bottom))
                        }
                        Spacer()
                    }
                }
                .ignoresSafeArea()
            case .selectingLocation, .waitingForOthersToGuess:
                LookAroundView().environmentObject(finding)
            case .timeLimitUp:
                VStack {
                    Text("time limit up")
                    Text("guesses: \(finding.guesses.description)")
                }
            }
        }
        .sheetWithDetents(
            isPresented: .constant(true),
            detents: [.large(), .medium()],
            onDismiss: {}
        ) {
            PeopleView()
                .sheetStyle()
                .environmentObject(finding)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
