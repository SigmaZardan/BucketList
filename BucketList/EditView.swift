//
//  EditView.swift
//  BucketList
//
//  Created by Bibek Bhujel on 17/11/2024.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var description: String
    let location: MapLocation
    let onSave: (MapLocation) -> Void

    init(location: MapLocation,onSave: @escaping (MapLocation) -> Void) {
        // rather than changing the data , we are changing the while instance of @State properties
        self.location = location
        self.onSave = onSave
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place Name", text: $name)
                    TextField("Description", text: $description)
                }
            }.toolbar {
                Button("Edit Location", systemImage: "plus") {
                    // create a new location
                    // copy of the location being passed
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    onSave(newLocation)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    EditView(location: .example) { _ in }
}
