//
//  EditView.swift
//  BucketList
//
//  Created by Bibek Bhujel on 17/11/2024.
//

import SwiftUI

struct EditView: View {

    enum LoadingState {
        case loading, loaded, failed
    }

    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()

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

                Section("Nearby...") {
                    switch loadingState {
                        case .loading:
                            Text("Loading...")
                        case .loaded:
                            ForEach(pages, id: \.pageid) { page in
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
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await fetchNearByPlaces()
            }
        }
    }

    func fetchNearByPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            // we got some data back !
            let items = try JSONDecoder().decode(Result.self, from: data)

            pages = items.query.pages.values.sorted()
            loadingState = .loaded
        }catch {
            print(error.localizedDescription)
            loadingState = .failed
        }
    }
}

#Preview {
    EditView(location: .example) { _ in }
}
