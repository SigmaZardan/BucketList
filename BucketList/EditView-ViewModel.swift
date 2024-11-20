//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Bibek Bhujel on 20/11/2024.
//

import Foundation

extension EditView {
    @Observable
    class ViewModel {
        enum LoadingState {
            case loading, loaded, failed
        }

       private(set) var loadingState = LoadingState.loading

        private(set) var pages = [Page]()
        let location: MapLocation
        var name: String
        var description: String

        init(location: MapLocation) {
            self.location = location
            self.name = location.name
            self.description = location.description
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
}
