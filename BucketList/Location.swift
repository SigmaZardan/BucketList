//
//  Location.swift
//  BucketList
//
//  Created by Bibek Bhujel on 16/11/2024.
//
import MapKit
import Foundation

// conforming to Equatable means that
// There is a == function built in that will compare each and every property of the structure
// But as we know that the UUID property which is unique based on identifiable protocol
// There is no need for use to check every property rather checking only the id property is the best approach
// Therefore, it is best for us the perform operator overloading and create our own
// == method that checks only the UUID

struct MapLocation: Identifiable, Codable, Equatable{
    var id: UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func ==(lhs: MapLocation, rhs: MapLocation) -> Bool {
        lhs.id == rhs.id
    }

// this is for testing purpose and won't be included in app store release
#if DEBUG
    static let example = MapLocation(id: UUID(), name: "Buckingham Palace", description: "Lit by over 40,000 lightbulbs.", latitude: 51.501, longitude: -0.141)
#endif
}
