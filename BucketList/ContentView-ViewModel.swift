//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Bibek Bhujel on 18/11/2024.
//
import Foundation
import LocalAuthentication
import MapKit
import SwiftUI

extension ContentView {
    @Observable
    class ViewModel {
        var selectedLocation: MapLocation?
        private(set) var locations: [MapLocation]

        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")

        private(set) var isUnlocked = false

        var mapType = UserDefaults.standard.integer(forKey: "mapType") {
            didSet {
                UserDefaults.standard.set(mapType, forKey: "mapType")
            }
        }

        var mapMode: MapStyle {
            return switch(mapType) {
                case 0: .standard
                case 1: .imagery
                case 2: .hybrid
                default: .standard
            }
        }

        var showError: Bool = false
        var errorTitle: String = ""
        var errorMessage: String = ""

        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([MapLocation].self, from: data)
            } catch {
                print(error.localizedDescription)
                locations = []
            }
        }

        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data
                    .write(
                        to: savePath,
                        options: [.atomic, .completeFileProtection]
                    )
            } catch {
                print("Unable to save data: \(error.localizedDescription)")
            }
        }


        func addLocation(coordinate: CLLocationCoordinate2D ) {
            let newLocation = MapLocation(
                id: UUID(),
                name: "New Location",
                description: "",
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            locations.append(newLocation)
            save()
        }


        func updateLocation(newLocation: MapLocation) {
            guard let selectedLocation else {
                print("No location seledted")
                return
            }
            if let index = locations.firstIndex(of: selectedLocation) {
                locations[index] = newLocation
                save()
            }
        }

        func authenticate() {
            let context = LAContext()
            var error: NSError?

            if context
                .canEvaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    error: &error
                ) {
                let reason = "Please authenticate yourself to unlock your places."

                  context
                    .evaluatePolicy(
                        .deviceOwnerAuthenticationWithBiometrics,
                        localizedReason: reason
                    ) {
                        success, authenticationError in
                            if success {
                                self.isUnlocked = true
                            } else {
                                // authentication error occurred
                                if let error = authenticationError as? LAError {
                                    if error.errorCode == -6 {
                                        self.errorTitle = "Permission denied."
                                        self.errorMessage = "Allow permission for biometrics on app settings."
                                        self.showError = true
                                    }
                                }
                            }
                 }

            } else {
                // no biometrics
                // we need to handle it somehow
                if let error = error as? LAError {
                    if error.errorCode == -6 {
                        self.errorTitle = "Permission denied."
                        self.errorMessage = "Allow permission for biometrics on app settings."
                        self.showError = true
                    }
                }
            }
        }
    }
}
