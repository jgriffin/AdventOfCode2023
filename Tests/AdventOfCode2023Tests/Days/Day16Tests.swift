//
// Created by John Griffin on 12/15/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day16Tests: XCTestCase {
    func testEnergizedExample() throws {
        var contraption = try Self.inputParser.parse(Self.example)
        let energized = contraption.energizedMax([.init(pos: .zero, dir: .east)])
        XCTAssertEqual(energized, 46)
    }

    func testEnergizedInput() throws {
        var contraption = try Self.inputParser.parse(Self.input)
        let energized = contraption.energizedMax([.init(pos: .zero, dir: .east)])
        XCTAssertEqual(energized, 7939)
    }

    func testMostEnergizedByExampleCheck() throws {
        var contraption = try Self.inputParser.parse(Self.example)
        let max = contraption.energizedMax([.init(pos: .init(0, 3), dir: .south)])
        XCTAssertEqual(max, 51)
    }

    func testMostEnergizedByExample() throws {
        var contraption = try Self.inputParser.parse(Self.example)
        let max = contraption.energizedMax()
        XCTAssertEqual(max, 51)
    }

    func testMostEnergizedByInput() throws {
        var contraption = try Self.inputParser.parse(Self.input)
        let max = contraption.energizedMax()
        XCTAssertEqual(max, 8318)
    }
}

extension Day16Tests {
    struct Contraption {
        let tiles: [[Tile]]
        let isValidIndex: (IndexRC) -> Bool
        init(tiles: [[Tile]]) {
            self.tiles = tiles
            isValidIndex = tiles.indexRCRanges.isValidIndex
        }

        mutating func energizedMax() -> Int {
            let indexRCRanges = tiles.indexRCRanges

            let leftStarts = indexRCRanges.r.map { r in Beam(pos: IndexRC(r, indexRCRanges.c.first!), dir: .east) }
            let rightStarts = indexRCRanges.r.map { r in Beam(pos: IndexRC(r, indexRCRanges.c.last!), dir: .west) }
            let topStarts = indexRCRanges.c.map { c in Beam(pos: IndexRC(indexRCRanges.r.first!, c), dir: .south) }
            let bottomStarts = indexRCRanges.c.map { c in Beam(pos: IndexRC(indexRCRanges.r.last!, c), dir: .north) }

            let leftMax = energizedMax(leftStarts)
            let rightMax = energizedMax(rightStarts)
            let topMax = energizedMax(topStarts)
            let bottomMax = energizedMax(bottomStarts)

            let max = [leftMax, rightMax, topMax, bottomMax].max()!
            return max
        }

        mutating func energizedMax(_ beams: [Beam]) -> Int {
            let results = beams.map { start in
                let result = energizedBy(start, [])
                return (start, result.beams.map(\.pos).asSet.count)
            }
            return results.map(\.1).max()!
        }

        private var beamsEnergizedBy: [Beam: Set<Beam>] = [:]

        struct EnergizedResult: CustomStringConvertible {
            let beams: Set<Beam>
            var loopedAt: Set<Beam>

            var description: String { "\(beams.description) looped: \(loopedAt.description)" }

            static func combine(lhs: EnergizedResult, rhs: EnergizedResult) -> EnergizedResult {
                EnergizedResult(
                    beams: lhs.beams.union(rhs.beams),
                    loopedAt: lhs.loopedAt.union(rhs.loopedAt)
                )
            }
        }

        mutating func energizedBy(_ beam: Beam, _ path: [Beam]) -> EnergizedResult {
            if let cached = beamsEnergizedBy[beam] {
                return EnergizedResult(beams: cached, loopedAt: .init())
            }
            if path.contains(beam) {
                return EnergizedResult(beams: [beam], loopedAt: .init([beam]))
            }

            let next = nextBeams(beam)
            let nextEnergizedBy = next.map { self.energizedBy($0, path + [beam]) }
            let result = nextEnergizedBy
                .reduce(EnergizedResult(beams: [beam], loopedAt: .init()), EnergizedResult.combine)

            guard !result.loopedAt.isEmpty else {
                // cache it
                beamsEnergizedBy[beam] = result.beams
                return result
            }

            guard result.loopedAt.contains(beam) else {
                return result
            }

            // cache it
            beamsEnergizedBy[beam] = result.beams
            return EnergizedResult(beams: result.beams, loopedAt: result.loopedAt.subtracting([beam]))
        }

        func nextBeams(_ beam: Beam) -> [Beam] {
            let directions: [IndexRC] = {
                switch (beam.dir, tiles[beam.pos]) {
                case (_, .space),
                     (.east, .horiz), (.west, .horiz),
                     (.north, .vert), (.south, .vert):
                    return [beam.dir]

                case (.north, .horiz), (.south, .horiz):
                    return [.east, .west]
                case (.east, .vert), (.west, .vert):
                    return [.north, .south]

                case (.east, .forward):
                    return [.north]
                case (.west, .forward):
                    return [.south]
                case (.north, .forward):
                    return [.east]
                case (.south, .forward):
                    return [.west]

                case (.east, .backward):
                    return [.south]
                case (.west, .backward):
                    return [.north]
                case (.north, .backward):
                    return [.west]
                case (.south, .backward):
                    return [.east]

                default:
                    fatalError()
                }
            }()

            return directions
                .map { Beam(pos: beam.pos + $0, dir: $0) }
                .filter { isValidIndex($0.pos) }
        }

        static let parser = Parse {
            Contraption(tiles: $0)
        } with: {
            Many {
                Many(1...) { Tile.parser }
            } separator: { "\n" }
        }
    }

    struct Beam: Hashable, CustomStringConvertible {
        var pos: IndexRC
        var dir: IndexRC

        var nextPos: Beam { Beam(pos: pos + dir, dir: dir) }

        var description: String { "\(pos) dir: \(dir)" }
    }

    enum Tile {
        case space, vert, horiz, forward, backward

        static let parser = OneOf {
            ".".map { Tile.space }
            "|".map { Tile.vert }
            "-".map { Tile.horiz }
            #"\"#.map { Tile.backward }
            #"/"#.map { Tile.forward }
        }
    }
}

extension Day16Tests {
    static let input = try! dataFromResource(filename: "Day16Input.txt").asString

    static let example: String = #"""
    .|...\....
    |.-.\.....
    .....|-...
    ........|.
    ..........
    .........\
    ..../.\\..
    .-.-/..|..
    .|....-|.\
    ..//.|....
    """#

    // MARK: - parser

    static let inputParser = Parse {
        Contraption.parser
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
