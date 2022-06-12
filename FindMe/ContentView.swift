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
        GameView()
        /* if let game = finding.game {
            GameView()
        } else {
            LobbyView()
        } */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
