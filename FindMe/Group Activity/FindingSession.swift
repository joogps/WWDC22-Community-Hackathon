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
    
    @Published var people = [Person]()
    @Published var me: Person?
    @Published var game: Game?
    
    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<(), Never>>()
    
    func configureGroupSession(_ groupSession: GroupSession<FindingActivity>) async {
        DispatchQueue.main.async {
            self.groupSession = groupSession
            self.me = Person(id: groupSession.localParticipant.id)
            self.people.append(self.me!)
        }
        
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        
        groupSession.$activeParticipants.sink { activeParticipants in
            let newParticipants = activeParticipants.filter( { !Set(self.people.map { person in
                person.id
            }).contains($0.id) } )
            
            if let me = self.me {
                Task {
                    print("Sending new participants")
                    do {
                        try await messenger.send(me, to: .all)
                    } catch {
                        
                    }
                }
            }
        }.store(in: &subscriptions)
        
        groupSession.$state.sink { state in
            print("New state: \(state)")
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
        DispatchQueue.main.async {
            self.people.append(message)
        }
    }
    
    func handle(_ message: Game) async {
        DispatchQueue.main.async {
            self.game = message
        }
    }
    
    func sendGame() {
        if let messenger = messenger {
            if let game {
                Task {
                    do {
                        try await messenger.send(game)
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func leaveSession() {
        messenger = nil
        
        tasks.forEach( { $0.cancel() } )
        tasks = []
        subscriptions = []
        
        if groupSession != nil {
            groupSession?.leave()
            groupSession = nil
        }
    }
}

struct Game: Codable {
    var finder: Person
    var location: CLLocationCoordinate2D?
    var guesses: [Guess] = []
}

struct Guess: Codable {
    var location: CLLocationCoordinate2D
}

struct Person: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String = UIDevice.current.name
    // var color: Color = [Color.blue, Color.yellow, Color.red, Color.green].randomElement()!
}
