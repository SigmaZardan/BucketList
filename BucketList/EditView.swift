//
//  EditView.swift
//  BucketList
//
//  Created by Bibek Bhujel on 17/11/2024.
//

import SwiftUI

struct EditView: View {

    @Environment(\.dismiss) var dismiss
    let onSave: (MapLocation) -> Void
    @State private var viewModel: ViewModel

    init(location: MapLocation,onSave: @escaping (MapLocation) -> Void) {
        self.onSave = onSave
        // rather than changing the data , we are changing the while instance of @State properties
        _viewModel = State(initialValue: ViewModel(location: location))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place Name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                }

                Section("Nearby...") {
                    switch viewModel.loadingState {
                        case .loading:
                            Text("Loading...")
                        case .loaded:
                            ForEach(viewModel.pages, id: \.pageid) { page in
                                Text(page.title).font(.headline)
                                + Text(": ")
                                + Text(page.description)
                            }
                        case .failed:
                            Text("Please try again later.")
                    }
                }
            }.toolbar {
                Button("Save") {
                    // create a new location
                    // copy of the location being passed
                    var newLocation = viewModel.location
                    newLocation.id = UUID()
                    newLocation.name = viewModel.name
                    newLocation.description = viewModel.description
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await viewModel.fetchNearByPlaces()
            }
        }
    }

   
}

#Preview {
    EditView(location: .example) { _ in }
}
