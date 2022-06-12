//
//  LobbyView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import MapKit

struct LobbyView: View {
    @State var region: MKCoordinateRegion = .init(center: .init(latitude: .zero, longitude: .zero),
                                                  span: .init(latitudeDelta: 80.0, longitudeDelta: 80.0))
    @EnvironmentObject var finding: FindingSession
    
    @State var showingNamePicker = true
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: finding.people.filter { $0.location != nil}) { person in
                MapAnnotation(coordinate: person.location!) {
                    CircleView(initials: person.initials)
                        .transition(.scale)
                }
            }
            
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "globe.desk")
                            .opacity(0.5)
                        Text("FindMe")
                    }
                    .font(.custom("SF Pro Expanded Heavy", size: 32, relativeTo: .largeTitle))
                    .padding(.vertical, 80)
                    .padding(.horizontal, 30)
                    Spacer()
                }
                .background {
                    Rectangle()
                        .fill(.linearGradient(colors: [.black, .black.opacity(0.0)],
                                              startPoint: .top,
                                              endPoint: .bottom))
                        .allowsHitTesting(false)
                }
                Spacer()
            }
        }.ignoresSafeArea()
            .sheetWithDetents(isPresented: .constant(finding.gameState == .waitingForPlayers),
                              detents: [.large(), .medium()],
                              onDismiss: {}) {
                PeopleView()
                    .sheetStyle()
                    .environmentObject(finding)
            }
          .alert("Pick name", isPresented: $showingNamePicker) {
              TextField("Name", text: $finding.name)
          }.onChange(of: locationManager.lastLocation) { location in
              finding.location = location?.coordinate
          }
          .onChange(of: showingNamePicker) { _ in
              if showingNamePicker == false {
                  Task {
                      for await session in FindingActivity.sessions() {
                          await finding.configureGroupSession(session)
                      }
                  }
              }
          }
    }
}

struct CircleView: View {
    let initials: String
    var systemIcon: String?
    
    var padding = 12.0
    
    var body: some View {
        Group {
            if let systemIcon {
                Image(systemName: systemIcon)
            } else {
                Text(initials)
            }
        }
        .bold()
        .padding(padding)
        .background(Circle().fill(Color.accentColor))
    }
}

struct LobbyView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyView()
    }
}
