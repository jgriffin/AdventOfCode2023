//
// Created by John Griffin on 12/5/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day05Tests: XCTestCase {
    // MARK: - part 1

    func testPart1Example() throws {
        let almanac = try Almanac.parser.parse(Self.example)

        let locations = almanac.seeds.map(almanac.locationForSeed)
        XCTAssertEqual(locations.min(), 35)
    }

    func testPart1Input() throws {
        let almanac = try Almanac.parser.parse(Self.input)

        let locations = almanac.seeds.map(almanac.locationForSeed)
        XCTAssertEqual(locations.min(), 26_273_516)
    }

    // MARK: - part 2

    func testPart2Example() throws {
        let almanac = try Almanac.parser.parse(Self.example)
        let seedRanges = almanac.seeds.chunks(ofCount: 2).map { $0.first! ..< $0.first! + $0.last! }
        XCTAssertEqual(seedRanges.count, 2)

        let locations = seedRanges.flatMap {
            $0.map(almanac.locationForSeed)
        }
        XCTAssertEqual(locations.count, 27)
        XCTAssertEqual(locations.min(), 46)
    }

    func testPart2RangesExample() throws {
        let almanac = try Almanac.parser.parse(Self.example)
        let seedRanges = almanac.seeds.chunks(ofCount: 2).map { $0.first! ..< $0.first! + $0.last! }
        XCTAssertEqual(seedRanges.count, 2)

        let locationRanges = seedRanges.flatMap(almanac.locationsForSeeds)
        XCTAssertEqual(locationRanges.count, 7)
        XCTAssertEqual(locationRanges.map(\.lowerBound).min(), 46)
    }

    func testPart2Input() throws {
        let almanac = try Almanac.parser.parse(Self.input)
        let seedRanges = almanac.seeds.chunks(ofCount: 2).map { $0.first! ..< $0.first! + $0.last! }
        XCTAssertEqual(seedRanges.count, 10)

        let locationRanges = seedRanges.flatMap(almanac.locationsForSeeds)
        XCTAssertEqual(locationRanges.count, 112)
        XCTAssertEqual(locationRanges.map(\.lowerBound).min(), 34_039_469)
    }
}

extension Day05Tests {
    struct Almanac {
        let seeds: [Int]
        let resourceMaps: [ResourceMap]

        func locationForSeed(_ seed: Int) -> Int {
            let reductions = resourceMaps.reductions(seed) { result, resourceMap in
                resourceMap.destinationFor(source: result)
            }
            return reductions.last!
        }

        func locationsForSeeds(_ seeds: Range<Int>) -> [Range<Int>] {
            let reductions = resourceMaps.reductions([seeds]) { sources, resourceMap in
                sources.flatMap(resourceMap.destinationsFor)
            }
            return reductions.last!
        }

        static let parser = Parse(Almanac.init) {
            "seeds: "
            Many { Digits() } separator: { " " }
            "\n\n"
            Many { ResourceMap.parser } separator: { "\n\n" }
            Skip { Optionally { "\n" }}
        }
    }

    struct ResourceMap: CustomStringConvertible {
        let from: String
        let to: String
        let rows: [MapRow]

        init(from: String, to: String, rows: [Day05Tests.ResourceMap.MapRow]) {
            self.from = from
            self.to = to
            self.rows = rows.sorted(by: \.sourceRange.lowerBound)
        }

        func destinationFor(source: Int) -> Int {
            guard let row = rows.first(where: { $0.sourceRange.contains(source) }) else {
                return source
            }

            return row.destinationStart + (source - row.sourceRange.lowerBound)
        }

        func destinationsFor(source: Range<Int>) -> [Range<Int>] {
            var ranges: [Range<Int>] = []
            var remaining = source

            for row in rows {
                guard remaining.lowerBound < row.sourceRange.upperBound else {
                    continue
                }

                if remaining.lowerBound < row.sourceRange.lowerBound {
                    // in a gap ... pass through
                    ranges.append(remaining.clamped(to: .min ..< remaining.lowerBound))
                    remaining = remaining.clamped(to: remaining.lowerBound ..< .max)
                }
                if remaining.overlaps(row.sourceRange) {
                    let delta = row.destinationStart - row.sourceRange.lowerBound
                    let clamped = remaining.clamped(to: row.sourceRange)
                    let mapped = clamped.lowerBound + delta ..< clamped.upperBound + delta

                    ranges.append(mapped)
                    remaining = remaining.clamped(to: row.sourceRange.upperBound ..< .max)
                }

                if remaining.isEmpty {
                    break
                }
            }

            if !remaining.isEmpty {
                ranges.append(remaining)
            }

            return ranges
        }

        var description: String {
            "\(from)-to-\(to)\n" + rows.map(\.description).joined(separator: "\n")
        }

        static let parser = Parse(input: Substring.self) {
            ResourceMap(from: String($0), to: String($1), rows: $2)
        } with: {
            Prefix(while: \.isLetter); "-to-"; Prefix(while: \.isLetter); " map:\n"
            Many { MapRow.parser } separator: { "\n" }
        }

        struct MapRow: CustomStringConvertible {
            let destinationStart: Int
            let sourceRange: Range<Int>

            init(destinationStart: Int, sourceStart: Int, count: Int) {
                self.destinationStart = destinationStart
                sourceRange = sourceStart ..< sourceStart + count
            }

            var description: String {
                "\(destinationStart) \(sourceRange)"
            }

            static let parser = Parse(input: Substring.self, MapRow.init) {
                Digits()
                " "
                Digits()
                " "
                Digits()
            }
        }
    }

    static let input = try! dataFromResource(filename: "Day05Input.txt").asString

    static let example: String = """
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15

    fertilizer-to-water map:
    49 53 8
    0 11 42
    42 0 7
    57 7 4

    water-to-light map:
    88 18 7
    18 25 70

    light-to-temperature map:
    45 77 23
    81 45 19
    68 64 13

    temperature-to-humidity map:
    0 69 1
    1 0 69

    humidity-to-location map:
    60 56 37
    56 93 4
    """

    // MARK: - parser

    func testParseExample() throws {
        let almanac = try Almanac.parser.parse(Self.example)
        XCTAssertEqual(almanac.seeds, [79, 14, 55, 13])
        XCTAssertEqual(almanac.resourceMaps.count, 7)
    }

    func testParseInput() throws {
        let almanac = try Almanac.parser.parse(Self.input)
        XCTAssertEqual(almanac.seeds.count, 20)
        XCTAssertEqual(almanac.resourceMaps.count, 7)
    }
}
