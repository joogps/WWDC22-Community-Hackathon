//
//  FindMeApp.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import FontBlaster

@main
struct FindMeApp: App {
    @ObservedObject var finding = FindingSession()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(finding)
                .preferredColorScheme(.dark)
                .onAppear {
                    FontBlaster.blast()
                }
        }
    }
}
