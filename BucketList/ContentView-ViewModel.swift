//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Bibek Bhujel on 18/11/2024.
//
import Foundation
import MapKit

extension ContentView {
    @Observable
    class ViewModel {
        var selectedLocation: MapLocation?
        private(set) var locations: [MapLocation]

        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")

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
    }
}
