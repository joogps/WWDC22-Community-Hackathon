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

enum GameState {
    case waitingForPlayers
    
    // When you are the selector, and you need to select a location for others to guess.
    case selectLocationForOthers
    
    // When you are a guesser, and you are waiting for the selector to select a location.
    case waitingForSelector
    
    // When you are a selector, and you are waiting for guessers to find your location.
    case selectorWaitingForGuesses
    
    // When you are a guesser, and you are guessing the location that the selector selected.
    case guessingLocation
    
    // When you are a guesser, and you are waiting for others to make their guesses.
    case guesserWaitingForOthers
    
    case timeLimitUp
}

class FindingSession: ObservableObject {
    @Published var groupSession: GroupSession<FindingActivity>?
    
    var messenger: GroupSessionMessenger?
    
    @Published var people: [Person] = []
    @Published var peopleToAddNextRound: [Person] = []
    
    @Published var me: Person?
    @Published var selector: Person?
    
    @Published var guesses: [Guess] = []
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var endTime: Date?
    
    @AppStorage("name") var name = "Person"
    @Published var location: CLLocationCoordinate2D?
    @Published var gameState: GameState = .waitingForPlayers
    
    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<(), Never>>()
    
    func configureGroupSession(_ groupSession: GroupSession<FindingActivity>) async {
        DispatchQueue.main.async {
            self.groupSession = groupSession
            self.me = Person(id: groupSession.localParticipant.id,
                             name: self.name,
                             location: self.location)
            self.people.append(self.me!)
        }
        
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        
        groupSession.$activeParticipants.sink { activeParticipants in
            _ = activeParticipants.filter( { !Set(self.people.map { person in
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
        
        let personMessageTask = Task.detached { [weak self] in
            for await (message, _) in messenger.messages(of: Person.self) {
                await self?.handle(message)
            }
        }
        self.tasks.insert(personMessageTask)
        
        let locationSelectorMessageTask = Task.detached { [weak self] in
            for await (message, _) in messenger.messages(of: SetLocationSelectorMessage.self) {
                await self?.handle(message)
            }
        }
        self.tasks.insert(locationSelectorMessageTask)
        
        let guessMessageTask = Task.detached { [weak self] in
            for await (message, _) in messenger.messages(of: Guess.self) {
                await self?.handle(message)
            }
        }
        self.tasks.insert(guessMessageTask)
        
        let selectedLocationMessage = Task.detached { [weak self] in
            for await (message, _) in messenger.messages(of: SelectedLocationMessage.self) {
                await self?.handle(message)
            }
        }
        self.tasks.insert(selectedLocationMessage)
        
        groupSession.join()
    }
    
    func handle(_ message: Person) async {
        DispatchQueue.main.async {
            // we dont want to append new players if the game has already started
            // instead they should be added next round
            if case .waitingForPlayers = self.gameState {
                self.people.append(message)
                
            } else {
                self.peopleToAddNextRound.append(message)
            }
        }
    }
    
    func handle(_ message: SetLocationSelectorMessage) async {
        selector = message.locationSelector
        
        if message.locationSelector.id == me?.id {
            gameState = .selectLocationForOthers
        } else {
            gameState = .waitingForSelector
        }
    }
    
    func handle(_ message: Guess) async {
        guesses.append(message)
        if guesses.count == people.count {
            gameState = .timeLimitUp
        }
    }
    
    func handle(_ message: SelectedLocationMessage) async {
        if case .waitingForSelector = gameState {
            selectedLocation = message.location
            gameState = .guessingLocation
        }
    }
    
    func startGame() {
        let selector = people.randomElement()!
        let selectorMessage = SetLocationSelectorMessage(locationSelector: selector)
        
        if selector.id == me?.id {
            gameState = .selectLocationForOthers
        } else {
            gameState = .waitingForSelector
        }
        
        self.selector = selector
        
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(selectorMessage)
                } catch {
                    
                }
            }
        }
    }
    
    // this will ONLY be run by selectors
    func selectLocation(location: CLLocationCoordinate2D) {
        let selectMessage = SelectedLocationMessage(location: location, endGuessTime: .now + 90)
        gameState = .selectorWaitingForGuesses
        selectedLocation = location
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(selectMessage)
                } catch {
                }
            }
        }
    }
    
    // this will ONLY be run by guessers
    func makeGuess(location: CLLocationCoordinate2D) {
        guard let me = me else { return }
        let guess = Guess(personId: me.id, location: location)
        gameState = .guesserWaitingForOthers
        
        if let messenger = messenger {
            Task {
                do {
                    try await messenger.send(guess)
                } catch {
                    
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

struct SetLocationSelectorMessage: Codable {
    var locationSelector: Person
}

struct SelectedLocationMessage: Codable {
    var location: CLLocationCoordinate2D
    var endGuessTime: Date
}

struct Guess: Codable {
    var personId: UUID
    var location: CLLocationCoordinate2D
}

struct Person: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String = UIDevice.current.name
    var location: CLLocationCoordinate2D?
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    // var color: Color = [Color.blue, Color.yellow, Color.red, Color.green].randomElement()!
}
