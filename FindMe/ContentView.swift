//
//  ContentView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var finding: FindingSession
    
    var body: some View {
        if case .waitingForPlayers = finding.gameState {
            LobbyView()
        } else {
            GameView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
