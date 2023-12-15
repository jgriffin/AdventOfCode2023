//
// Created by John Griffin on 12/5/23
//

import AdventOfCode2023
import Algorithms
import EulerTools
import Parsing
import XCTest

final class Day06Tests: XCTestCase {
    // MARK: - part 1

    func testPart1Example() throws {
        let races = try Self.inputParser.parse(Self.example)
        let winRanges = races.map { $0.winRange() }
        XCTAssertEqual(winRanges, [2 ... 5, 4 ... 11, 11 ... 19])
        let winsProduct = winRanges.map(\.count).reduce(1,*)
        XCTAssertEqual(winsProduct, 288)
    }

    func testPart1Input() throws {
        let races = try Self.inputParser.parse(Self.input)
        let winRanges = races.map { $0.winRange() }
        let winsProduct = winRanges.map(\.count).reduce(1,*)
        XCTAssertEqual(winsProduct, 800_280)
    }

    // MARK: - part 2

    func testPart2Example() throws {
        let race = try Race.combining(Self.inputParser.parse(Self.example))
        XCTAssertEqual(race.time, 71530)
        XCTAssertEqual(race.distance, 940_200)
        let winRange = race.winRange()
        XCTAssertEqual(winRange, 14 ... 71516)
        XCTAssertEqual(winRange.count, 71503)
    }

    func testPart2Input() throws {
        let race = try Race.combining(Self.inputParser.parse(Self.input))
        let winRange = race.winRange()
        XCTAssertEqual(winRange, 4_790_126 ... 49_918_149)
        XCTAssertEqual(winRange.count, 45_128_024)
    }
}

extension Day06Tests {
    struct Race {
        let time: Int
        let distance: Int

        func isWin(hold: Int) -> Bool {
            hold * (time - hold) > distance
        }

        func winRange() -> ClosedRange<Int> {
            let middle = time / 2
            assert(isWin(hold: middle))
            let (bottom, top) = (0 ... middle, middle ... time)

            let firstIndex = bottom.partitioningIndex(where: isWin)
            let lastIndex = top.partitioningIndex(where: { !isWin(hold: $0) })
            return bottom[firstIndex] ... top[top.index(before: lastIndex)]
        }

        static func combining(_ races: [Race]) -> Race {
            let time = Int(races.map { String($0.time) }.joined())!
            let distance = Int(races.map { String($0.distance) }.joined())!
            return Race(time: time, distance: distance)
        }
    }

    static let input = try! dataFromResource(filename: "Day06Input.txt").asString

    static let example: String = """
    Time:      7  15   30
    Distance:  9  40  200
    """

    // MARK: - parser

    static let inputParser = Parse {
        times, distances in zip(times, distances).map { Race(time: $0, distance: $1) }
    } with: {
        "Time:"; Whitespace()
        Many { Digits() } separator: { Whitespace() }
        "\nDistance:"; Whitespace()
        Many { Digits() } separator: { Whitespace() }
        Skip { Optionally { "\n" }}
    }

    func testParseExample() throws {
        let races = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(races.count, 3)
    }

    func testParseInput() throws {
        let races = try Self.inputParser.parse(Self.input)
        XCTAssertEqual(races.count, 4)
    }
}
