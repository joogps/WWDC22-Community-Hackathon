//
//  GameView.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var finding: FindingSession
    
    var body: some View {
        if finding.game?.finder == finding.me {
            Text("Find a place")
        } else {
            if let location = finding.game?.location {
                
            } else {
                Text("Someone is finding a place")
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
