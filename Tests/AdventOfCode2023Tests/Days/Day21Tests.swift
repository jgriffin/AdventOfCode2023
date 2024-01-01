//
// Created by John Griffin on 1/1/24
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day21Tests: XCTestCase {
    func testParseExample() throws {
        let garden = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(garden.plots.count, 81)
        let result = garden.canReachCountInSteps(6)
        XCTAssertEqual(result, 16)
    }

    func testParseInput() throws {
        let garden = try Self.inputParser.parse(Self.input)
        XCTAssertEqual(garden.plots.count, 15507)
        let result = garden.canReachCountInSteps(64)
        XCTAssertEqual(result, 3816)
    }
}

extension Day21Tests {
    struct IndexInSteps: Hashable {
        let index: IndexRC
        let inSteps: Int
    }

    struct Garden {
        let indexRanges: IndexRCRanges
        let neighbors: IndexRC.NeighborsOf
        let plots: Set<IndexRC>
        let start: IndexRC

        let canReachMemoizer = Memoizer<IndexInSteps, Set<IndexRC>>()

        func canReachCountInSteps(_ steps: Int) -> Int {
            let canReach = canReachFrom(.init(index: start, inSteps: steps))
            return canReach.count
        }

        func canReachFrom(_ from: IndexInSteps) -> Set<IndexRC> {
            canReachMemoizer.memoized(from) { indexInSteps in
                guard indexInSteps.inSteps > 1 else {
                    return neighbors(indexInSteps.index).asSet
                }

                let halfSteps = indexInSteps.inSteps / 2
                let halfStepsReachable = canReachFrom(.init(index: indexInSteps.index, inSteps: halfSteps))

                let remainSteps = indexInSteps.inSteps - halfSteps
                let remainStepsReachable = halfStepsReachable.flatMap { halfIndex in
                    canReachFrom(.init(index: halfIndex, inSteps: remainSteps))
                }

                return remainStepsReachable.asSet
            }
        }

        // MARK: - intitialization

        init(_ tiles: [[Tile]]) {
            indexRanges = tiles.indexRCRanges
            plots = indexRanges.allIndicesFlat().filter { tiles[$0] != .rock }.asSet
            start = indexRanges.allIndicesFlat().first(where: { tiles[$0] == .start })!
            neighbors = IndexRC.neighborsFunc(
                offsets: IndexRC.squareNeighborOffsets,
                isValidIndex: plots.contains
            )
        }

        static let parser = Parse(Garden.init) {
            Many {
                Many(1...) { Tile.parser }
            } separator: { "\n" }
        }

        enum Tile {
            case start, rock, plot

            static let parser = OneOf {
                "S".map { Tile.start }
                ".".map { Tile.plot }
                "#".map { Tile.rock }
            }
        }
    }

    static let inputParser = Parse {
        Garden.parser
        Skip { Optionally { "\n" } }
    }
}

extension Day21Tests {
    static let input = try! dataFromResource(filename: "Day21Input.txt").asString

    static let example: String = """
    ...........
    .....###.#.
    .###.##..#.
    ..#.#...#..
    ....#.#....
    .##..S####.
    .##..#...#.
    .......##..
    .##.#.####.
    .##..##.##.
    ...........
    """
}
