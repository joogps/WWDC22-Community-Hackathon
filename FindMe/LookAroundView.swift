//
//  LookAroundView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import MapKit

struct LookAroundView: View {
    @State var lookAroundScene: MKLookAroundScene?
    @State var presenting = false
    
    var body: some View {
        HStack {
            if let lookAroundScene {
                LookAroundViewRepresentable(scene: lookAroundScene)
                    .frame(height: 200)
                    .cornerRadius(24)
                    .padding(20)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            presenting.toggle()
                        }
                    }.sheetWithDetents(isPresented: $presenting, detents: [.large(), .medium()], onDismiss: {
                        
                    }, content: {
                        Rectangle()
                            .fill(.white)
                    })
            }
        }.task {
            let sceneRequest = MKLookAroundSceneRequest(coordinate: CLLocationCoordinate2D(latitude: 37.73536, longitude: -122.40709))
            print(sceneRequest)
            do {
                lookAroundScene = try await sceneRequest.scene
            } catch {
            }
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

struct LookAroundView_Previews: PreviewProvider {
    static var previews: some View {
        LookAroundView()
    }
}
