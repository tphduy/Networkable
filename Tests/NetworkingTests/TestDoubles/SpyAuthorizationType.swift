//
//  SpyAuthorizationType.swift
//  Networking
//
//  Created by Duy Tran on 7/14/20.
//

import Foundation
@testable import Networking

final class SpyAuthorizationType: AuthorizationType {

    var invokedKeyGetter = false
    var invokedKeyGetterCount = 0
    var stubbedKey: String! = ""

    var key: String {
        invokedKeyGetter = true
        invokedKeyGetterCount += 1
        return stubbedKey
    }

    var invokedValueGetter = false
    var invokedValueGetterCount = 0
    var stubbedValue: String! = ""

    var value: String {
        invokedValueGetter = true
        invokedValueGetterCount += 1
        return stubbedValue
    }

    var invokedPlaceGetter = false
    var invokedPlaceGetterCount = 0
    var stubbedPlace: AuthorizationPlace!

    var place: AuthorizationPlace {
        invokedPlaceGetter = true
        invokedPlaceGetterCount += 1
        return stubbedPlace
    }
}

extension SpyAuthorizationType: Equatable {

    static func == (lhs: SpyAuthorizationType, rhs: SpyAuthorizationType) -> Bool {
        lhs.key == rhs.key
            && lhs.value == rhs.value
            && lhs.place == rhs.place
    }
}
