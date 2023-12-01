//
// Created by John Griffin on 12/1/23
//

import EulerTools
import Foundation
import XCTest

extension XCTestCase {
    static func resourceURL(filename: String) -> URL? {
        Bundle.module.url(forResource: filename, withExtension: nil)
    }

    static func dataFromResource(filename: String) throws -> Data {
        try Data(contentsOf: resourceURL(filename: filename).unwrapped)
    }
}

public extension Sequence<UInt8> {
    var bytes: [UInt8] {
        Array(self)
    }
}
