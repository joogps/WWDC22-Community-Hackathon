//
//  FindingSession.swift
//  FindMe
//
//  Created by João Gabriel Pozzobon dos Santos on 11/06/22.
//

import SwiftUI
import GroupActivities
import Combine

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
                    try await messenger.send(self.me, to: .all)
                } catch {
                    
                }
            }
            
            let personTask = Task.detached { [weak self] in
                for await (message, _) in messenger.messages(of: Person.self) {
                    await self?.handle(message)
                }
            }
            self.tasks.insert(personTask)
            
        }.store(in: &subscriptions)
        
        groupSession.join()
    }
    
    func handle(_ message: Person) async {
        people.append(message)
    }
}

struct Game {
    var finder: Person
}

struct Person: Identifiable, Codable {
    let id: UUID
    var name: String = "Person"
    var color: [Color] = [Color.blue, Color.yellow, Color.red, Color.green].randomElement()!
}
