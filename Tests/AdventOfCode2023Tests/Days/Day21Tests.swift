//
// Created by John Griffin on 1/1/24
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day21Tests: XCTestCase {
    func testCanReachExample() throws {
        let garden = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(garden.rocks.count, 40)
        let result = garden.canReachCountInSteps(6)
        XCTAssertEqual(result, 16)
    }

    func testCanReachInput() throws {
        let garden = try Self.inputParser.parse(Self.input)
        XCTAssertEqual(garden.rocks.count, 1654)
        let result = garden.canReachCountInSteps(64)
        XCTAssertEqual(result, 3816)
    }

    func testCanReachMoreExample() throws {
        let garden = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(garden.canReachCountExtendedInSteps(6), 16)
        XCTAssertEqual(garden.canReachCountExtendedInSteps(10), 50)
        XCTAssertEqual(garden.canReachCountExtendedInSteps(50), 1594)
        XCTAssertEqual(garden.canReachCountExtendedInSteps(100), 6536)
        XCTAssertEqual(garden.canReachCountExtendedInSteps(500), 167004)
        XCTAssertEqual(garden.canReachCountExtendedInSteps(1000), 668697)
//        XCTAssertEqual(garden.canReachCountExtendedInSteps(5000), 16733044)
    }

    func testCanReachMoreExploreExample() throws {
        let garden = try Self.inputParser.parse(Self.example)
        let count = garden.canReachCountExtendedInSteps(100)
    }
}

extension Day21Tests {
    struct IndexInSteps: Hashable {
        let index: IndexRC
        let inSteps: Int
    }

    struct Garden {
        let indexRanges: IndexRCRanges
        let rCount, cCount: Int
        let rocks: Set<IndexRC>
        let start: IndexRC

        func notARock(_ index: IndexRC) -> Bool {
            let centralized = IndexRC(
                index.r >= 0 ? index.r % rCount : rCount + (index.r % rCount),
                index.c >= 0 ? index.c % cCount : cCount + (index.c % cCount)
            )
            return !rocks.contains(centralized)
        }

        func gridAndIndex(_ index: IndexRC) -> (grid: IndexRC, index: IndexRC) {
            var rQR = index.r.quotientAndRemainder(dividingBy: rCount)
            if index.r < 0 {
                rQR = (rQR.quotient - 1, rCount - rQR.remainder)
            }
            var cQR = index.c.quotientAndRemainder(dividingBy: cCount)
            if index.c < 0 {
                cQR = (cQR.quotient - 1, cCount - cQR.remainder)
            }
            return (grid: IndexRC(rQR.quotient, cQR.quotient),
                    index: IndexRC(rQR.remainder, cQR.remainder))
        }

        func canReachCountInSteps(_ steps: Int) -> Int {
            let results = (1 ... steps).reductions([start].asSet) { reachable, _ in
                reachable
                    .flatMap { plot in IndexRC.squareNeighborOffsets.map { plot + $0 } }
                    .filter { indexRanges.isValidIndex($0) && notARock($0) }
                    .asSet
            }

            return results.last!.count
        }

        func canReachCountExtendedInSteps(_ steps: Int) -> Int {
            let results = (1 ... steps).reductions([start].asSet) { reachable, _ in
                reachable
                    .flatMap { plot in IndexRC.squareNeighborOffsets.map { plot + $0 } }
                    .filter(notARock)
                    .asSet
            }
            
            let grided = results.map {
                $0.map(gridAndIndex)
                    .grouped(by: \.grid)
                    .mapValues { $0.count }
                    .sorted(by: \.value)
            }
//            print(grided.map { $0.map { "\($0.key)\t\($0.value)" }.joined(separator: "\t") }.joinedByNewlines)
            print(grided.map { $0.map { "\($0.value)" }.joined(separator: "\t") }.joinedByNewlines)

            return results.last!.count
        }

        // MARK: - intitialization

        init(_ tiles: [[Tile]]) {
            indexRanges = tiles.indexRCRanges
            rCount = indexRanges.r.count
            cCount = indexRanges.c.count
            rocks = indexRanges.allIndicesFlat().filter { tiles[$0] == .rock }.asSet
            start = indexRanges.allIndicesFlat().first(where: { tiles[$0] == .start })!
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
