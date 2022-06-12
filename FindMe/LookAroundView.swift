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


struct MakeGuessView: View {
    @EnvironmentObject var finding: FindingSession
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    @State var timeRemaining = 44.0
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
                        ZStack(alignment: .leading) {
                            Rectangle().frame( height: 10).foregroundColor(.white)
                            Rectangle().frame(width: (self.timeRemaining / 90.0) * geo.size.width, height: 10).foregroundColor(.blue)
                        }
                        
                        
                    }
                }.frame(height: 95)
                    .offset(y:10)
                
                
                ZStack {
                    Map(coordinateRegion: $region)
                        .edgesIgnoringSafeArea(.all)
                        .offset(y:-10)
                    VStack{
                        HStack(alignment: .top) {
                            Spacer()
                            Text("\(Int(round(self.timeRemaining))) seconds remaining")
                        }
                    }
                }
                
            }
            .task {
                if let game = finding.game {
                    self.timeRemaining = game.endGuessTime.timeIntervalSince1970 - Date().timeIntervalSince1970
                    print("timeRemaining: \(timeRemaining)")
                }
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
