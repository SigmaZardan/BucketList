//
//  ContentView.swift
//  BucketList
//
//  Created by Bibek Bhujel on 12/11/2024.
//
import MapKit
import SwiftUI

struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )

    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            if viewModel.isUnlocked {
                ZStack(alignment:.topLeading){
                    MapReader { proxy in
                        Map(initialPosition: startPosition) {
                            ForEach(viewModel.locations) { location in
                                Annotation(
                                    location.name,
                                    coordinate: location.coordinate
                                ) {
                                    VStack {
                                        Image(systemName: "star.circle")
                                            .resizable()
                                            .background(.white)
                                            .frame(width: 44, height: 44)
                                            .foregroundStyle(.red)
                                            .clipShape(.circle)
                                            .simultaneousGesture(LongPressGesture(minimumDuration: 1).onEnded { _ in
                                                viewModel.selectedLocation = location
                                            })
                                    }
                                }
                            }
                        }.mapStyle(viewModel.mapMode)
                            .onTapGesture { position in
                                if let coordinate = proxy.convert(position, from: .local) {
                                    viewModel.addLocation(coordinate: coordinate)
                                }
                            }
                            .sheet(item: $viewModel.selectedLocation) {selectedLocation in
                                // It is another form of sheet. The sheet will appear when there is some value in the selectedlocation.
                                EditView(location: selectedLocation) { newLocation in
                                    // update the current one
                                    //                    if let index = viewModel.locations.firstIndex(of: selectedLocation) {
                                    //                        viewModel.locations[index] = newLocation
                                    //                        // this will not update the location because it will first treat both selectedLocation and newLocation as same because we have overriden method == and made sure that if the UUID is same then the two map locations are same
                                    //                        // Therefore, to fix this we must make sure that the UUID is different for both of them
                                    //                        // make the UUID mutable
                                    //                        // and create a new UUID when you create a new location in the edit view
                                    //                    }
                                    viewModel.updateLocation(newLocation: newLocation)
                                }
                            }

                    }
                    Menu {
                        Picker("Map Mode",selection: $viewModel.mapType) {
                            Text("Standard").tag(0)
                            Text("Imagery").tag(1)
                            Text("Hybrid").tag(2)
                        }.pickerStyle(.menu)

                    }label: {
                        Text("Mode")
                            .padding()
                            .foregroundStyle(.black)
                            .background(.ultraThinMaterial)
                            .clipShape(.capsule)
                    }.padding(.horizontal)
                }
            } else {
                Button("Unlock Places", action: viewModel.authenticate)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(.rect(cornerRadius: 10))
            }
        }.alert(
            viewModel.errorTitle,
            isPresented: $viewModel.showError,
            actions: {
                Button("Settings") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                Button("OK") {}
            },
            message: {Text(viewModel.errorMessage)}
        )
    }
}


#Preview {
    ContentView()
}
