//
// Created by John Griffin on 12/12/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day11Tests: XCTestCase {
    func textExpandedUniverse() throws {
        let check = """
        ....#........
        .........#...
        #............
        .............
        .............
        ........#....
        .#...........
        ............#
        .............
        .............
        .........#...
        #....#.......
        """

        let universe = try Self.inputParser.parse(Self.example)
        let expanded = universe.expandedUniverse(factor: 1)

        XCTAssertEqual(expanded.description, check)
    }

    func testDistanceBetweenExample() throws {
        let universe = try Self.inputParser.parse(Self.example).expandedUniverse(factor: 2)
        let distances = universe.distanceBetweenGalaxies()
        XCTAssertEqual(distances, 374)
    }

    func testDistanceBetweenInput() throws {
        let universe = try Self.inputParser.parse(Self.input).expandedUniverse(factor: 2)
        let distances = universe.distanceBetweenGalaxies()
        XCTAssertEqual(distances, 9_565_386)
    }

    func testDistanceBetweenXExample() throws {
        let universe = try Self.inputParser.parse(Self.example)

        let universe2 = universe.expandedUniverse(factor: 2)
        XCTAssertEqual(universe2.distanceBetweenGalaxies(), 374)

        let universe10 = universe.expandedUniverse(factor: 10)
        XCTAssertEqual(universe10.distanceBetweenGalaxies(), 1030)

        let universe100 = universe.expandedUniverse(factor: 100)
        XCTAssertEqual(universe100.distanceBetweenGalaxies(), 8410)
    }

    func testDistanceBetweenMInput() throws {
        let universe = try Self.inputParser.parse(Self.input)

        let universe2 = universe.expandedUniverse(factor: 1_000_000)
        XCTAssertEqual(universe2.distanceBetweenGalaxies(), 857_986_849_428)
    }
}

extension Day11Tests {
    struct Universe: CustomStringConvertible {
        let galaxies: Set<IndexRC>
        let rangesRC: IndexRCRanges

        init(galaxies: some Collection<IndexRC>) {
            rangesRC = Ranger(galaxies).rangesRC
            self.galaxies = galaxies.asSet
        }

        init(image: [[Bool]]) {
            rangesRC = image.indexRCRanges
            galaxies = rangesRC.allIndicesFlat().filter { image[$0] }.asSet
        }

        func distanceBetweenGalaxies() -> Int {
            let sorted = zip(1..., galaxies.sorted()).asArray
            let distances = sorted.combinations(ofCount: 2).map { c in
                (c[0].0, c[1].0, dist: IndexRC.manhattanDistance(c[0].1, c[1].1))
            }
            return distances.map(\.dist).reduce(0,+)
        }

        func expandedUniverse(factor: Int) -> Universe {
            let expansion = factor - 1
            let rowExpansionMap = {
                let nonEmptyRows = galaxies.map(\.r).asSet
                var rowExpansion = 0
                return rangesRC.r.reduce(into: [Int: Int]()) { result, r in
                    guard nonEmptyRows.contains(r) else {
                        rowExpansion += expansion
                        return
                    }

                    result[r] = r + rowExpansion
                }
            }()

            let colExpansionMap = {
                let nonEmptyCols = galaxies.map(\.c).asSet
                var colExpansion = 0
                return rangesRC.c.reduce(into: [Int: Int]()) { result, c in
                    guard nonEmptyCols.contains(c) else {
                        colExpansion += expansion
                        return
                    }

                    result[c] = c + colExpansion
                }
            }()

            let expandedGalaxies = galaxies.map { index in
                IndexRC(r: rowExpansionMap[index.r]!, c: colExpansionMap[index.c]!)
            }

            return Universe(galaxies: expandedGalaxies)
        }

        // MARK: - io

        var description: String { rangesRC.dump(galaxies.contains, trueString: "#") }

        static let parser = Parse(Universe.init) {
            Many {
                Many(1...) {
                    OneOf {
                        "#".map { true }
                        ".".map { false }
                    }
                }
            } separator: { "\n" }
        }
    }

    static let input = try! dataFromResource(filename: "Day11Input.txt").asString

    static let example: String = """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """

    // MARK: - parser

    static let inputParser = Parse {
        Universe.parser
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
