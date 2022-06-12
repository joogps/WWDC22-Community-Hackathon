//
//  FindingSession.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import GroupActivities
import Combine
import MapKit

class FindingSession: ObservableObject {
    @Published var groupSession: GroupSession<FindingActivity>?
    
    var messenger: GroupSessionMessenger?
    
    @Published var people: [Person] = []
    @Published var me: Person?
    @Published var host: Person?
    @Published var game: Game?
    
    
    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<(), Never>>()
    
    func configureGroupSession(_ groupSession: GroupSession<FindingActivity>) async {
        self.groupSession = groupSession
        
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        
        me = Person(id: groupSession.localParticipant.id)
        
        groupSession.$activeParticipants.sink { activeParticipants in
            let newParticipants = activeParticipants.filter( { !Set(self.people.map( { $0.id } )).contains($0.id) } )
            
            Task {
                do {
                    try await messenger.send(self.me, to: .only(newParticipants))
                } catch {
                }
            }
        }.store(in: &subscriptions)
        
        let personTask = Task.detached { [weak self] in
            for await (message, _) in messenger.messages(of: Person.self) {
                await self?.handle(message)
            }
        }
        self.tasks.insert(personTask)
        
        let gameTask = Task.detached { [weak self] in
            for await (message, _) in messenger.messages(of: Game.self) {
                await self?.handle(message)
            }
        }
        self.tasks.insert(gameTask)
        
        groupSession.join()
    }
    
    func handle(_ message: Person) async {
        people.append(message)
    }
    
    func handle(_ message: Game) async {
        self.game = message
    }
    
    func startGame() {
        let finder = people.randomElement()!
        self.game = Game(finder: finder, endGuessTime: .now + 90)
        
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(game)
                } catch {
                    
                }
            }
        }
    }
}

struct Game: Codable {
    var finder: Person
    var location: CLLocationCoordinate2D?
    var guesses: [Guess] = []
    var endGuessTime: Date
}

struct Guess: Codable {
    var location: CLLocationCoordinate2D
}

struct Person: Identifiable, Codable {
    let id: UUID
    var name: String = "Person"
    var color: Color = [Color.blue, Color.yellow, Color.red, Color.green].randomElement()!
}


