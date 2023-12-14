//
// Created by John Griffin on 12/14/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day13Tests: XCTestCase {
    func testIndexOfReflectionExample() throws {
        let patterns = try Self.inputParser.parse(Self.example)
        // print(patterns.map(\.description).joined(separator: "\n\n"))

        let reflections = patterns.map { $0.indexOfReflection().assertOnly! }
        XCTAssertEqual(reflections, [.init(0, 5), .init(4, 0)])
        let sum = reflections.reduce(.zero, +)
        XCTAssertEqual(100 * sum.r + sum.c, 405)
    }

    func testIndexOfReflectionInput() throws {
        let patterns = try Self.inputParser.parse(Self.input)

        let reflections = patterns.map { $0.indexOfReflection().assertOnly! }
        let sum = reflections.reduce(.zero, +)
        XCTAssertEqual(100 * sum.r + sum.c, 33520)
    }

    func testSmudgeIndexOfReflectionExample() throws {
        let patterns = try Self.inputParser.parse(Self.example)

        let reflections = patterns.map { $0.smudgeIndexOfReflection()! }
        let sum = reflections.reduce(.zero, +)
        XCTAssertEqual(100 * sum.r + sum.c, 400)
    }

    func testSmudgeIndexOfReflectionInput() throws {
        let patterns = try Self.inputParser.parse(Self.input)

        let reflections = patterns.map { $0.smudgeIndexOfReflection()! }
        let sum = reflections.reduce(.zero, +)
        XCTAssertEqual(100 * sum.r + sum.c, 34824)
    }
}

extension Day13Tests {
    struct Pattern: CustomStringConvertible {
        var pattern: [[Bool]]

        func smudgeIndexOfReflection() -> IndexRC? {
            var copy = self
            var reflectionIndices = pattern.indexRCRanges.allIndicesFlat().flatMap { index in
                copy.pattern[index].toggle()
                defer { copy.pattern[index].toggle() }

                return copy.indexOfReflection()
            }.asSet

            if reflectionIndices.count > 1 {
                let originalReflection = indexOfReflection().assertOnly!
                reflectionIndices.remove(originalReflection)
            }

            XCTAssertEqual(reflectionIndices.count, 1)
            return reflectionIndices.first
        }

        func indexOfReflection() -> [IndexRC] {
            let rows = linesOfReflectionVert()
            let cols = linesOfReflectionHoriz()

            return rows.map { r in IndexRC(r, 0) } + cols.map { c in IndexRC(0, c) }
        }

        func linesOfReflectionHoriz() -> [Int] {
            Self.linesOfReflectionHoriz(pattern)
        }

        func linesOfReflectionVert() -> [Int] {
            Self.linesOfReflectionHoriz(pattern.flipRowsAndColumns())
        }

        static func linesOfReflectionHoriz(_ pattern: [[Bool]]) -> [Int] {
            let indexRanges = pattern.indexRCRanges
            return pattern.reduce(indexRanges.c.dropFirst().asArray) { candidateCols, row in
                candidateCols.filter { c in
                    let width = min(c - indexRanges.c.lowerBound, indexRanges.c.upperBound - c)
                    let colRange = c - width ..< c + width
                    return row[colRange].isAnagram
                }
            }
        }

        // MARK: - initialization

        var description: String {
            pattern.indexRCRanges.dump({ pattern[$0] }, trueString: "#")
        }

        static let parser = Parse {
            Pattern(pattern: $0)
        } with: {
            Many(1...) {
                Many(1...) {
                    OneOf {
                        "#".map { true }
                        ".".map { false }
                    }
                }
            } separator: { "\n" }
        }
    }

    static let input = try! dataFromResource(filename: "Day13Input.txt").asString

    static let example: String = """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """

    // MARK: - parser

    static let inputParser = Parse {
        Many(1...) {
            Pattern.parser
        } separator: { "\n\n" }
        Skip { Optionally { "\n" } }
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

extension Collection where Element: Equatable {
    var isAnagram: Bool {
        zip(self, reversed()).allSatisfy(==)
    }
}

extension Collection where Element: Collection, Element.Index == Int {
    func flipRowsAndColumns() -> [[Element.Element]] {
        first!.indices.map { c in
            self.map { $0[c] }
        }
    }
}
