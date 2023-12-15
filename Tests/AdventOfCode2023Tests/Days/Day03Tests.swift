//
// Created by John Griffin on 12/3/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day03Tests: XCTestCase {
    // MARK: - part 1

    func testPart1Example() throws {
        let grid = Grid.parse(Self.example.split(separator: .newline))
        let symbolAdjacentNumbers = grid.symbolAdjacentNumbers
        XCTAssertEqual(symbolAdjacentNumbers.map(\.value).reduce(0,+), 4361)
    }

    func testPart1Input() throws {
        let grid = Grid.parse(Self.input.split(separator: .newline, omittingEmptySubsequences: true))
        let symbolAdjacentNumbers = grid.symbolAdjacentNumbers
        XCTAssertEqual(symbolAdjacentNumbers.map(\.value).reduce(0,+), 540_212)
    }

    // MARK: - part 2

    func testPart2Example() throws {
        let grid = Grid.parse(Self.example.split(separator: .newline))
        let gears = grid.gears
        let gearRatios = gears.map { $0.gear1 * $0.gear2 }
        XCTAssertEqual(gearRatios.reduce(0,+), 467_835)
    }

    func testPart2Input() throws {
        let grid = Grid.parse(Self.input.split(separator: .newline, omittingEmptySubsequences: true))
        let gears = grid.gears
        let gearRatios = gears.map { $0.gear1 * $0.gear2 }
        XCTAssertEqual(gearRatios.reduce(0,+), 87_605_697)
    }
}

extension Day03Tests {
    static let input = try! dataFromResource(filename: "Day03Input.txt").bytes

    static let example: [Ascii] = try! """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """.asAscii

    // MARK: - parser

    struct Grid {
        let digits: [IndexXY: NumberBox]
        let symbols: [IndexXY: Ascii]

        var numbers: [NumberBox] {
            digits.values
                .uniqued(on: \.firstIndex)
                .sorted(by: \.firstIndex.y, then: \.firstIndex.x)
        }

        var symbolAdjacentNumbers: [NumberBox] {
            let neighborsOf = IndexXY.neighborsFunc(offsets: IndexXY.diagonalNeighborOffsets)
            return symbols.keys
                .flatMap { index in
                    neighborsOf(index).compactMap { digits[$0] }
                }
                .uniqued(on: \.firstIndex)
                .sorted(by: \.firstIndex.y, then: \.firstIndex.x)
        }

        var gears: [(index: IndexXY, gear1: Int, gear2: Int)] {
            let neighborsOf = IndexXY.neighborsFunc(offsets: IndexXY.diagonalNeighborOffsets)
            return symbols.filter { $0.value == Ascii(ch: "*") }
                .map { index, _ -> (index: IndexXY, gears: [NumberBox]) in
                    (
                        index,
                        neighborsOf(index)
                            .compactMap { digits[$0] }
                            .uniqued(on: \.firstIndex)
                    )
                }
                .compactMap { index, gears in
                    guard gears.count == 2 else { return nil }
                    return (index, gears.first!.value, gears.last!.value)
                }
        }

        static func parse(_ grid: [[Ascii].SubSequence]) -> Grid {
            var digits: [IndexXY: NumberBox] = [:]
            var symbols: [IndexXY: Ascii] = [:]

            for (y, row) in grid.enumerated() {
                var openBox: NumberBox?
                for (x, element) in row.enumerated() {
                    let index = IndexXY(x, y)

                    switch element {
                    case .dot:
                        openBox = nil

                    case _ where Set<Ascii>.isDigit.contains(element):
                        if openBox == nil {
                            openBox = NumberBox(firstIndex: index)
                        }
                        openBox!.appendDigit(Int(element.asDigitValue!))
                        digits[index] = openBox!

                    case .newline:
                        assertionFailure("unexected newline")

                    default:
                        symbols[index] = element
                        openBox = nil
                    }
                }
            }

            return Grid(digits: digits, symbols: symbols)
        }
    }

    class NumberBox: CustomStringConvertible {
        let firstIndex: IndexXY
        var value: Int = 0

        init(firstIndex: IndexXY) {
            self.firstIndex = firstIndex
        }

        func appendDigit(_ digit: Int) {
            value = value * 10 + digit
        }

        var description: String {
            "\(firstIndex) \(value)"
        }
    }

    static let inputParser = Parse { "???".map { true } }

    func testParseExample() throws {
        let grid = Grid.parse(Self.example.split(separator: .newline))
        XCTAssertEqual(grid.digits.count, 28)
        XCTAssertEqual(grid.numbers.count, 10)
        XCTAssertEqual(grid.symbols.values.asSet, "+#*$".asBytes.asSet)
    }

    func testParseInput() throws {
        let grid = Grid.parse(Self.input.split(separator: .newline))
        XCTAssertEqual(grid.digits.count, 3487)
        XCTAssertEqual(grid.numbers.count, 1213)
        XCTAssertEqual(grid.symbols.values.asSet, "$@%*-/&+=#".asBytes.asSet)
    }
}
