//
//  Learning.swift
//  BucketList
//
//  Created by Bibek Bhujel on 12/11/2024.
//
import LocalAuthentication
import MapKit
import SwiftUI

struct Learning: View {
    // Adding conformation to comparable for custom types
    // first of all we have default sort method for arrays
    let sorted = [1,4, 3, 2, 5].sorted()
    // we have list of users
    let users = [
        User(firstName: "bibek", lastName: "bhujel"),
        User(firstName: "sanjina", lastName: "giri"),
        User(firstName: "mokshu", lastName: "something")
    ]
        .sorted()
    // here if we try to sort the list of users using sorted method then it is not possible
    // just using sorted() is not possible
    // but if we pass how the users should be sorted then it will work fine

    // here we have sorted based on last name
    // but this is not an ideal solution because
    // we should not tell the model how it should behave inside the SwiftUI
    // second, if wer have to sort the users array in multiple places
    // if any  code has to be changed for example, you might want to sort the the array of users using firstName
    // This means we have to change the code in multiple places which is again not ideal


    // swift by default knows how to sort array using comparable protocol where < is recognized and used
    // we use the concept of operator overloading
    // after conforming the comparable protocol and providing the definition of < operator,
    // the sorted() method works fine because it knows how to compare the values for User structure
    var body: some View {
//        List(sorted, id: \.self) { number in
//            Text(String(number))
//        }

        UsingTouchIdAndFaceId()
    }
}
// what if we want to apply same method for structures
//

struct User: Identifiable, Comparable, Codable{
    var id = UUID()
    var firstName: String
    var lastName: String
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.lastName < rhs.lastName
    }
}


// writing data to the documents directory
// this is where we could have used swift data but we are just trying to explore different
// ways to store data in swift
// UserDefaults was used when we wanted to store small amount of data and something like that
// But here the data can be large

// all IOS apps are sandboxed this means they have their own container with a hard to guess directory name
// As a result, we cannot and shouldnot try to guess the directory where our app is installed
// special url that points to the app's documents directory called ( documentsDirectory)

struct StoringDataToDocuments: View {
    let fileManager = FileManager()
    var body: some View {
        Button("Read and Write") {
            fileManager.save(contents: "Hello,My name is Bibek", path: "bibek.txt")
            print(fileManager.read(fileName: "bibek.txt"))
        }
    }
}
// extension
extension FileManager {
    func save(contents: String, path: String) {
        let documentURL = self.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let userURL = documentURL.appendingPathComponent(path)
        let data = contents.data(using: .utf8)
        do {
            if let data  {
                try data
                    .write(
                        to: userURL,
                        options: [.atomic, .completeFileProtection]
                    )
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func read(fileName: String) -> String {
        let documentURL = self.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let userURL = documentURL.appendingPathComponent(fileName)
        do {
            return try String(contentsOf: userURL, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
}


// Switching view states with enums
enum LoadingState {
    case loading, success, failed
}

struct DifferentState: View {
    @State private var loadingState = LoadingState.loading
    var body: some View {
        switch loadingState {
            case .loading:
                LoadingView()
            case .success:
                SuccessView()
            case .failed:
                FailedView()
        }
    }
}

struct LoadingView: View {
    var body: some View {
        Text("Loading.....")
    }
}
struct SuccessView: View {
    var body: some View {
        Text("Success")
    }
}

struct FailedView: View {
    var body: some View {
        Text("Failed")
    }
}
// integrating map kit with swiftUI
struct IntegratingMap: View {
    // map interaction modes :
    // allowing users to rotate and zoom
    // interactionModes: [.rotate, .zoom]
    // you can pass it empty [] array like this for no interactions
    // we can set the location that needs to be seem when the user starts the map for the first time

    // here is a constant property for london with
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    var body: some View {
        VStack {
            Map(position: $position)
                .mapStyle(.hybrid(elevation: .realistic))
                .onMapCameraChange(frequency: .continuous) { context in
                    print(context.region)
                }
            // When the user finishes the drag, he will be able to get the position
            // If you want the position on the map continuously then you can use frequency to be continuous
            // That way we can easily handle things

            HStack(spacing: 50) {
                Button("Paris") {
                      position = MapCameraPosition.region(
                          MKCoordinateRegion(
                              center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
                              span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                          )
                      )
                  }

                  Button("Tokyo") {
                      position = MapCameraPosition.region(
                          MKCoordinateRegion(
                              center: CLLocationCoordinate2D(latitude: 35.6897, longitude: 139.6922),
                              span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                          )
                      )
                  }
            }
        }

    }
}
// placing annotations
// Making the location structure conform to identifiable because
// we want to make sure that swiftUI identify each marker uniquely

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct PlacingAnnotations: View {
    let locations = [
        Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]

    var body: some View {
        // we use special view map reader that wraps around the map to get an actual location on the map
        // map reader will provide a map proxy object that will help to convert the screen locations to map location and vice versa
        MapReader { proxy in
            Map {
                ForEach(locations) { location in
                    // this is just to mark the location on the map
                    Marker(location.name, coordinate: location.coordinate)

                    // for more control over the marker we can use Annotation
                    Annotation(location.name, coordinate: location.coordinate) {
                        Text(location.name)
                            .font(.headline)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                    }
                    .annotationTitles(.hidden)

                }
            }.onTapGesture {
                // it gives us the screen location called position
                // using the proxy from  map reader we re able to convert it into
                // map coordinates and display on the screen
                position in
                if let coordinate = proxy.convert(position, from: .local) {
                    print(coordinate)
                }
            }
        }
    }
}


// using touch id and face id with swiftui
struct UsingTouchIdAndFaceId: View {
    @State private var isUnlocked = false
    var body: some View {
        VStack {
            if isUnlocked {
                Text("Unlocked")
            } else {
                Text("Locked")
            }
        }.onAppear(perform: authenticate)
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,error: &error) {
            // it's possible to go ahead and use it
                  let reason = "We want to unlock our data."

                  context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason) { success, authenticationError in
                        // authentication has now completed
                        if success {
                            // authenticated successfully
                            isUnlocked = true
                        } else {
                            // there was a problem
                            print(authenticationError?.localizedDescription ?? "No value for the error")
                        }
                    }
        } else {
            // no biometrics
        }
    }
}

#Preview {
    Learning()
}
