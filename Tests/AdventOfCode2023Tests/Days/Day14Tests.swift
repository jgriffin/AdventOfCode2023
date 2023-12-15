//
// Created by John Griffin on 12/14/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day14Tests: XCTestCase {
    func testSlideNorth() throws {
        var platform = try Self.inputParser.parse(Self.example)
        let check = """
        OOOO.#.O..
        OO..#....#
        OO..O##..O
        O..#.OO...
        ........#.
        ..#....#.#
        ..O..#.O.O
        ..O.......
        #....###..
        #....#....
        """

        platform.tilt(.north)
        
        XCTAssertEqual(platform.description, check)
    }

    func testTotalLoadExample() throws {
        var platform = try Self.inputParser.parse(Self.example)
        platform.tilt(.north)
        
        let totalLoad = platform.totalLoad()
        XCTAssertEqual(totalLoad, 136)
    }
    
    func testTotalLoadInput() throws {
        var platform = try Self.inputParser.parse(Self.input)
        platform.tilt(.north)
        
        let totalLoad = platform.totalLoad()
        XCTAssertEqual(totalLoad, 106997)
    }
    
    func testTiltCycle3Example() throws {
        let checkAfter1 = """
        .....#....
        ....#...O#
        ...OO##...
        .OO#......
        .....OOO#.
        .O#...O#.#
        ....O#....
        ......OOOO
        #...O###..
        #..OO#....
        """
        let checkAfter2 = """
        .....#....
        ....#...O#
        .....##...
        ..O#......
        .....OOO#.
        .O#...O#.#
        ....O#...O
        .......OOO
        #..OO###..
        #.OOO#...O
        """
        let checkAfter3 = """
        .....#....
        ....#...O#
        .....##...
        ..O#......
        .....OOO#.
        .O#...O#.#
        ....O#...O
        .......OOO
        #...O###.O
        #.OOO#...O
        """

        var platform = try Self.inputParser.parse(Self.example)
        platform.tiltCycle()
        XCTAssertEqual(platform.description, checkAfter1)
        platform.tiltCycle()
        XCTAssertEqual(platform.description, checkAfter2)
        platform.tiltCycle()
        XCTAssertEqual(platform.description, checkAfter3)
    }
    
    func testTiltCyclePatternExample() throws {
        let initial = try Self.inputParser.parse(Self.example)
        let result = Self.totalLoadFor(initial, afterCycle: 20)
        
        var platform = initial
        20.times { _ in
            platform.tiltCycle()
        }
        XCTAssertEqual(platform.totalLoad(), result)
    }

    func testTiltCycleMillionExample() throws {
        let platform = try Self.inputParser.parse(Self.example)

        let result = Self.totalLoadFor(platform, afterCycle: 1000000000)
        XCTAssertEqual(result, 64)
    }
    
    func testTiltCycleMillionInput() throws {
        let platform = try Self.inputParser.parse(Self.input)

        let result = Self.totalLoadFor(platform, afterCycle: 1000000000)
        XCTAssertEqual(result, 99641)
    }
}

extension Day14Tests {
    static func totalLoadFor(_ start: Platform, afterCycle: Int) -> Int {
        guard let cycle = findTiltCycleStartAndLength(start) else { fatalError() }
        
        let cycleOffset = afterCycle < cycle.start ? afterCycle :
            (afterCycle - cycle.start) % cycle.length + cycle.start
        print("afterCycle: \(afterCycle) (start: \(cycle.start), length: \(cycle.length)) == \(cycleOffset)")

        return cycle.load[cycleOffset]
    }

    static func findTiltCycleStartAndLength(_ start: Platform) -> (start: Int, length: Int, load: [Int])? {
        var hashHistory: [Int] = []
        var loadHistory: [Int] = []
        
        var platform = start
        var hashValue = platform.hashValue
        while !hashHistory.contains(hashValue) {
            hashHistory.append(hashValue)
            loadHistory.append(platform.totalLoad())
            
            platform.tiltCycle()
            hashValue = platform.hashValue
        }

        guard let index = hashHistory.firstIndex(of: hashValue) else {
            return nil
        }
            
        // print(hashHistory.map(\.niceHash).joined(separator: "\n"))
        return (index, hashHistory.count - index, loadHistory)
    }
    
    static let input = try! dataFromResource(filename: "Day14Input.txt").asString
    
    static let example: String = """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """
    
    struct Platform: Hashable, ParserPrinterStringConvertible {
        var rocks: [[Rock]]
        
        func totalLoad() -> Int {
            let rowCount = rocks.indexRCRanges.r.upperBound
            return rocks.indexRCRanges.allIndicesFlat()
                .filter { rocks[$0] == .round }
                .map { rowCount - $0.r }
                .reduce(0,+)
        }
        
        mutating func tiltCycle() {
            Direction.allCases.forEach { direction in
                tilt(direction)
            }
        }
        
        mutating func tilt(_ direction: Direction) {
            let primaryOffsets: [IndexRC]
            let secondaryOffsets: [IndexRC]
            let nextOpenStep: IndexRC
            
            switch direction {
            case .north:
                primaryOffsets = rocks.indexRCRanges.c.map { c in IndexRC(0, c) }
                secondaryOffsets = rocks.indexRCRanges.r.map { r in IndexRC(r, 0) }
                nextOpenStep = .south
            case .west:
                primaryOffsets = rocks.indexRCRanges.r.map { r in IndexRC(r, 0) }
                secondaryOffsets = rocks.indexRCRanges.c.map { c in IndexRC(0, c) }
                nextOpenStep = .east
            case .south:
                primaryOffsets = rocks.indexRCRanges.c.map { c in IndexRC(0, c) }
                secondaryOffsets = rocks.indexRCRanges.r.reversed().map { r in IndexRC(r, 0) }
                nextOpenStep = .north
            case .east:
                primaryOffsets = rocks.indexRCRanges.r.map { r in IndexRC(r, 0) }
                secondaryOffsets = rocks.indexRCRanges.c.reversed().map { c in IndexRC(0, c) }
                nextOpenStep = .west
            }
            
            primaryOffsets.forEach { primary in
                var nextOpen = primary + secondaryOffsets.first!

                secondaryOffsets.forEach { secondary in
                    let index = primary + secondary

                    switch rocks[index] {
                    case .round:
                        if index != nextOpen {
                            rocks[nextOpen] = rocks[index]
                            nextOpen += nextOpenStep
                            rocks[index] = .space
                        } else {
                            nextOpen = index + nextOpenStep
                        }
                    case .square:
                        nextOpen = index + nextOpenStep
                    case .space:
                        break
                    }
                }
            }
        }
        
        static let parser = ParsePrint(.memberwise(Platform.init)) {
            Many {
                Many(1...) { Rock.parser }
            } separator: { "\n" }
        }
    }
    
    enum Direction: CaseIterable {
        case north, west, south, east
    }
    
    enum Rock: ParserPrinterStringConvertible {
        case round, square, space
        
        static let parser = OneOf {
            "O".map { Rock.round }
            "#".map { Rock.square }
            ".".map { Rock.space }
        }
    }
    
    // MARK: - parser
    
    static let inputParser = Parse {
        Platform.parser
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

extension Int {
    var niceHash: String {
        String(UInt(bitPattern: hashValue), radix: 16, uppercase: true).suffix(5).asString
    }
}
