//
// Created by John Griffin on 12/11/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day10Tests: XCTestCase {
    func testFarthestExample() throws {
        let grid = try Self.inputParser.parse(Self.example)
        let loop = grid.walkLoop()
        let farthest = loop.count / 2
        XCTAssertEqual(farthest, 4)
    }

    func testFarthestInput() throws {
        let grid = try Self.inputParser.parse(Self.input)
        let loop = grid.walkLoop()
        let farthest = loop.count / 2
        XCTAssertEqual(farthest, 6701)
    }

    func testEnclosedCountExample1() throws {
        let example = """
        ...........
        .S-------7.
        .|F-----7|.
        .||.....||.
        .||.....||.
        .|L-7.F-J|.
        .|..|.|..|.
        .L--J.L--J.
        ...........
        """

        let grid = try Self.inputParser.parse(example)
        let enclosedCount = grid.enclosedCountConnected()
        XCTAssertEqual(enclosedCount, 4)
    }

    func testEnclosedCountExample2() throws {
        let example = """
        .F----7F7F7F7F-7....
        .|F--7||||||||FJ....
        .||.FJ||||||||L7....
        FJL7L7LJLJ||LJ.L-7..
        L--J.L7...LJS7F-7L7.
        ....F-J..F7FJ|L7L7L7
        ....L7.F7||L7|.L7L7|
        .....|FJLJ|FJ|F7|.LJ
        ....FJL-7.||.||||...
        ....L---J.LJ.LJLJ...
        """

        let grid = try Self.inputParser.parse(example)
        let enclosedCount = grid.enclosedCountConnected()
        XCTAssertEqual(enclosedCount, 8)
    }

    func testEnclosedCountExample3() throws {
        let example = """
        FF7FSF7F7F7F7F7F---7
        L|LJ||||||||||||F--J
        FL-7LJLJ||||||LJL-77
        F--JF--7||LJLJ7F7FJ-
        L---JF-JLJ.||-FJLJJ7
        |F|F-JF---7F7-L7L|7|
        |FFJF7L7F-JF7|JL---7
        7-L-JL7||F7|L7F-7F7|
        L.L7LFJ|||||FJL7||LJ
        L7JLJL-JLJLJL--JLJ.L
        """

        let grid = try Self.inputParser.parse(example)
        let enclosedCount = grid.enclosedCountConnected()
        XCTAssertEqual(enclosedCount, 10)
    }

    func testEnclosedCountInput() throws {
        let grid = try Self.inputParser.parse(Self.input)
        let enclosedCount = grid.enclosedCountConnected()
        XCTAssertEqual(enclosedCount, 303)
    }
}

extension IndexRC {
    static let north = IndexRC(-1, 0)
    static let south = IndexRC(1, 0)
    static let east = IndexRC(0, +1)
    static let west = IndexRC(0, -1)
}

extension Day10Tests {
    struct Grid: ParserPrinterStringConvertible {
        let tiles: [[Tile]]
        let indexRanges: IndexRCRanges

        init(tiles: [[Day10Tests.Tile]]) {
            self.tiles = tiles
            indexRanges = tiles.indexRCRanges
        }

        func walkLoop() -> [IndexRC] {
            // start doesn't have a direction, so pick a valid one
            let start = indexRanges.allIndicesFlat().first { tiles[$0] == .start }!
            let firstStep = neighborsOf(start).first(where: { neighborsOf($0).contains(start) })!

            var loop = [start]
            var current = firstStep
            repeat {
                let next = neighborsOf(current).first(where: { $0 != loop.last! })!
                loop.append(current)
                current = next
            } while current != start
            loop.append(start)

            return loop
        }

        func neighborsOf(_ index: IndexRC) -> [IndexRC] {
            tiles[index].neighborOffsets.map { index + $0 }
                .filter { index in
                    indexRanges.isValidIndex(index) && tiles[index] != .ground
                }
        }

        func resolveStartTile(_ startIndex: IndexRC) -> Tile {
            guard tiles[startIndex] == .start else {
                return tiles[startIndex]
            }

            let neighbors = neighborsOf(startIndex).filter { neighborsOf($0).contains(startIndex) }
            assert(neighbors.count == 2)

            let n = neighbors.contains(startIndex + .north)
            let s = neighbors.contains(startIndex + .south)
            let e = neighbors.contains(startIndex + .east)
            let w = neighbors.contains(startIndex + .west)

            switch (n, s, e, w) {
            case (true, true, false, false):
                return .ns
            case (false, false, true, true):
                return .ew
            case (true, false, true, false):
                return .ne
            case (true, false, false, true):
                return .nw
            case (false, true, false, true):
                return .sw
            case (false, true, true, false):
                return .se
            default:
                fatalError()
            }
        }

        func enclosedCountConnected() -> Int {
            let loopEdges = walkLoop().asSet

            let groupedByColor = indexRanges.connectedGroupsByColor(isEdge: loopEdges.contains)
            let enclosedColors = groupedByColor.compactMap { color, indices -> Int? in
                isEnclosed(indices.first!, loopEdges: loopEdges) ? color : nil
            }.sorted()

            let count = groupedByColor.filter { enclosedColors.contains($0.key) }.map(\.value.count).reduce(0,+)
            return count
        }

        func isEnclosed(_ index: IndexRC, loopEdges: Set<IndexRC>) -> Bool {
            let isValidIndex = indexRanges.isValidIndex

            do {
                var edgeCount = 0
                var edgeBias: Tile?
                var cur = index
                while isValidIndex(cur) {
                    if loopEdges.contains(cur) {
                        let tile = resolveStartTile(cur)
                        handleLoopEdge(tile: tile, edgeBias: &edgeBias, edgeCount: &edgeCount)
                    } else {
                        assert(edgeBias == nil)
                    }
                    cur += .east
                }
                guard edgeCount % 2 == 1 else { return false }
            }

            return true
        }

        func handleLoopEdge(tile: Tile, edgeBias: inout Tile?, edgeCount: inout Int) {
            switch (edgeBias, tile) {
            case (_, .start), (.start, _):
                assertionFailure("resolve start before calling")

            // simple
            case (nil, .ns):
                edgeCount += 1

            // passthrough
            case (.some, .ew):
                break

            // bias cases
            case (nil, .ne), (nil, .se):
                edgeBias = tile

            case (.ne, .sw), (.se, .nw):
                edgeBias = nil
                edgeCount += 1

            case (.ne, .nw), (.se, .sw):
                edgeBias = nil

            // shouldn't be possible
            case (.some, .ns),
                 (nil, .ew), (nil, .nw), (nil, .sw),
                 (.some, .se), (.some, .ne), (.some, .sw), (.some, .nw),
                 (_, .ground):
                assertionFailure()
            }
        }

        struct Scan {
            let horizontal: Bool
            var wasEdge: Bool = false
            var edgeCount: Int = 0
            var insideGround: [IndexRC] = []

            mutating func process(
                _ index: IndexRC,
                _ tile: Tile,
                isLoopEdge: Bool
            ) {
                guard !isLoopEdge else {
                    let isScanEdge = horizontal ? tile.isHScanEdge : tile.isVScanEdge
                    if isScanEdge != nil {
                        wasEdge = true
                        edgeCount += 1
                    }
                    return
                }
                if wasEdge {
                    wasEdge = false
                }
                if case .ground = tile, edgeCount % 2 == 1 {
                    insideGround.append(index)
                }
            }
        }

        func neighbors(_ index: IndexRC) -> [IndexRC] {
            tiles[index].neighborOffsets.map { $0 + index }
        }

        static let parser = ParsePrint(
            .convert(
                apply: { Grid(tiles: $0) },
                unapply: { $0.tiles }
            )
        ) {
            Many {
                Many(1...) { Tile.parser }
            } separator: { "\n" }
        }.eraseToAnyParserPrinter()
    }

    enum Tile: ParserPrinterStringConvertible {
        case start, ns, ew, ne, nw, sw, se, ground

        var neighborOffsets: [IndexRC] {
            switch self {
            case .ns: return [.north, .south]
            case .ew: return [.east, .west]
            case .ne: return [.north, .east]
            case .nw: return [.north, .west]
            case .sw: return [.south, .west]
            case .se: return [.south, .east]
            case .ground: return []
            case .start: return [.north, .south, .east, .west]
            }
        }

        var isHScanEdge: Bool? {
            switch self {
            case .ns: true
            case .ew: nil
            case .ne, .nw, .sw, .se, .start: true
            case .ground: false
            }
        }

        var isVScanEdge: Bool? {
            switch self {
            case .ew: true
            case .ns: false
            case .ne, .nw, .sw, .se, .start: nil
            case .ground: false
            }
        }

        //  | is a vertical pipe connecting north and south.
        //  - is a horizontal pipe connecting east and west.
        //  L is a 90-degree bend connecting north and east.
        //  J is a 90-degree bend connecting north and west.
        //  7 is a 90-degree bend connecting south and west.
        //  F is a 90-degree bend connecting south and east.
        //  . is ground; there is no pipe in this tile.
        //  S is the starting position of the animal; there is a pipe on this tile,
        //    but your sketch doesn't show what shape the pipe has.
        static let parser = OneOf(input: Substring.self) {
            "|".map { Tile.ns }
            "-".map { Tile.ew }
            "L".map { Tile.ne }
            "J".map { Tile.nw }
            "7".map { Tile.sw }
            "F".map { Tile.se }
            ".".map { Tile.ground }
            "S".map { Tile.start }
        }.eraseToAnyParserPrinter()
    }
}

extension Day10Tests {
    static let input = try! dataFromResource(filename: "Day10Input.txt").asString

    static let example: String = """
    .....
    .S-7.
    .|.|.
    .L-J.
    .....
    """

    static let inputParser = Parse {
        Grid.parser
        Skip { Many { "\n" } }
    }

    // MARK: - parser

    func testParseExample() throws {
        let input = try Self.inputParser.parse(Self.example)
        XCTAssertNotNil(input)
    }

    func testParseInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        XCTAssertNotNil(input)
    }
}
