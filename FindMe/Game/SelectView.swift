//
//  SelectView.swift
//  FindMe
//
//  Created by Christian Privitelli on 12/6/2022.
//

import SwiftUI
import CoreLocation
import MapKit

struct SelectView: View {
    @EnvironmentObject var finding: FindingSession
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    )
    
    @State var pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.334_900,
                                                                            longitude: -122.009_020)
    
    @State private var scene: MKLookAroundScene?
    @State private var error = false
    
    var body: some View {
        ZStack {
            MapView(centerCoordinate: .constant(region.center), pinLocation: $pinLocation, lines: false)
                .onChange(of: pinLocation) { _ in
                    Task {
                        let sceneRequest = MKLookAroundSceneRequest(coordinate: pinLocation)
                        do {
                            scene = try await sceneRequest.scene
                            finding.selectLocation(location: pinLocation)
                        } catch {
                            self.error = true
                        }
                    }
                    
                }
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Select a location for everyone to find!")
                        .font(.custom("SF Pro Expanded Bold", size: 24))
                        .padding(.bottom, 12)
                    if error {
                        Text("That location isn't available yet! Try somewhere else.")
                            .transition(.move(edge: .bottom))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(
                    .ultraThinMaterial
                )
                Spacer()
            }
        }
    }
}

struct SelectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}
