//
// Created by John Griffin on 12/11/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day09Tests: XCTestCase {
    func testPredictNextValueExample() throws {
        let histories = try Self.inputParser.parse(Self.example)
        let nextValues = histories.map(predictNextValue)
        XCTAssertEqual(nextValues, [18, 28, 68])
        XCTAssertEqual(nextValues.reduce(0,+), 114)
    }

    func testPredictNextValueInput() throws {
        let histories = try Self.inputParser.parse(Self.input)
        let nextValues = histories.map(predictNextValue)
        XCTAssertEqual(nextValues.reduce(0,+), 1992273652)
    }

    func testPredictPrevValue() {
        let example = [10, 13, 16, 21, 30, 45]
        let prevValue = predictPrevValue(example)
        XCTAssertEqual(prevValue, 5)
    }

    func testPredictPrevValueExample() throws {
        let histories = try Self.inputParser.parse(Self.example)
        let prevValues = histories.map(predictPrevValue)
        XCTAssertEqual(prevValues, [-3, 0, 5])
        XCTAssertEqual(prevValues.reduce(0,+), 2)
    }

    func testPredictPrevValueInput() throws {
        let histories = try Self.inputParser.parse(Self.input)
        let prevValues = histories.map(predictPrevValue)
        XCTAssertEqual(prevValues.reduce(0,+), 1012)
    }
}

extension Day09Tests {
    func predictPrevValue(_ seq: [Int]) -> Int {
        var rows = [seq]
        var current = seq

        repeat {
            current = asDifferences(current)
            rows.append(current)
        } while !current.allSatisfy { $0 == 0 }

        let firsts = rows.map { $0.first! }
        let reductions = firsts.reversed().reductions(0) { result, first in
            first - result
        }
        return reductions.last!
    }

    func predictNextValue(_ seq: [Int]) -> Int {
        var rows = [seq]
        var current = seq

        repeat {
            current = asDifferences(current)
            rows.append(current)
        } while !current.allSatisfy { $0 == 0 }

        let lasts = rows.map { $0.last! }
        return lasts.reduce(0,+)
    }

    func asDifferences(_ a: [Int]) -> [Int] {
        zip(a, a.dropFirst()).map { $0.1 - $0.0 }
    }

    static let input = try! dataFromResource(filename: "Day09Input.txt").asString

    static let example: String = """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """

    // MARK: - parser

    static let inputParser = Parse(input: Substring.self) {
        Many {
            Many(1...) { Int.parser() } separator: { " " }
        } separator: { "\n" }
        Skip { Optionally { "\n" }}
    }

    func testParseExample() throws {
        let input = try Self.inputParser.parse(Self.example)
        XCTAssertNotNil(input)
    }

    func testParseInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        XCTAssertNotNil(input)
    }
}
