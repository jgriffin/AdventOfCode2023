//
//  Created by Griff on 12/23/23.
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day18Tests: XCTestCase {
    func testExample() throws {
        let plan = try Self.inputParser.parse(Self.example)
        let area = Lagoon(plan).area()
        XCTAssertEqual(area, 62)
    }

    func testInput() throws {
        let plan = try Self.inputParser.parse(Self.input)
        let area = Lagoon(plan).area()
        XCTAssertEqual(area, 49578)
    }

    func testHexExample() throws {
        let plan = try Self.inputParser.parse(Self.example)
        let area = Lagoon(hexPlan: plan).area()
        XCTAssertEqual(area, 952_408_144_115)
    }

    func testHexInput() throws {
        let plan = try Self.inputParser.parse(Self.input)
        let area = Lagoon(hexPlan: plan).area()
        XCTAssertEqual(area, 52_885_384_955_882)
    }
}

extension Day18Tests {
    struct Lagoon {
        let trench: [IndexRC]
        let indexRanges: IndexRCRanges

        init(_ trench: [IndexRC]) {
            self.trench = trench
            indexRanges = Ranger(trench).rangesRC
        }

        init(_ plan: [PlanStep]) {
            let trench = plan.reduce(into: [IndexRC.zero]) { result, step in
                result.append(result.last! + step.count * IndexRC.offsetOf(step.dir))
            }

            let minR = trench.map(\.r).min()!
            let minC = trench.map(\.c).min()!
            self.init(trench.map { IndexRC($0.r - minR, $0.c - minC) })
        }

        init(hexPlan: [PlanStep]) {
            let trench = hexPlan.reduce(into: [IndexRC.zero]) { result, step in
                result.append(result.last! + step.distance * IndexRC.offsetOf(step.dir2))
            }
            let minR = trench.map(\.r).min()!
            let minC = trench.map(\.c).min()!
            self.init(trench.map { IndexRC($0.r - minR, $0.c - minC) })
        }

        func area() -> Int {
            let segments = trench.adjacentPairs()
                .map { OrderedPair($0, $1) }
                .sorted(by: \.first, then: \.second)

            /**
             The idea is to use the trench points to split things in all possible rectangles, where it's easy to figure out the area of
             each rectangle, and we just then need to decide whether each is inside or outside the trench
             */
            let rs = (trench.map(\.r) + trench.map { $0.r + 1 }).asSet.sorted()
            let cs = (trench.map(\.c) + trench.map { $0.c + 1 }).asSet.sorted()

            // top left is in rect, bottom right isn't
            let rectangleTL2BR = rs.adjacentPairs().flatMap { t, b in
                cs.adjacentPairs().map { l, r in
                    OrderedPair(.init(t, l), .init(b, r))
                }
            }.sorted(by: \.first, then: \.second)

//            let rangesPrefix = IndexRCRanges(r: indexRanges.r.prefix(30), c: indexRanges.c)
//            print(rangesPrefix.dump { index in segments.contains { $0.intersects(index) }})

            let insideRectangles = rectangleTL2BR.filter { rect in
                let topLeft = rect.first

                let candidateSegments = segments
                    .drop(while: { $0.second.r < topLeft.r })
                    .prefix(while: { $0.first.r <= topLeft.r })
                    .sorted(by: \.first.c)

                var crossings = 0
                var currentBias: OrderedPair.EdgeBias? = nil

                for pair in candidateSegments {
                    guard !pair.intersects(topLeft) else {
                        return true
                    }

                    let bias = pair.isEdgeLeftOf(topLeft)

                    switch (currentBias, bias) {
                    case (nil, .vertical),
                         (.vertical, .vertical),
                         (.up, .down),
                         (.down, .up):
                        currentBias = nil
                        crossings += 1

                    case (.up, .up),
                         (.down, .down):
                        currentBias = nil

                    case (nil, nil),
                         (.vertical, nil),
                         (nil, .up),
                         (nil, .down),
                         (.vertical, .up),
                         (.vertical, .down):
                        currentBias = bias

                    case (.down, nil),
                         (.up, nil):
                        // keep bias
                        break

                    case (.down, .vertical),
                         (.up, .vertical):
                        currentBias = .vertical
                        crossings += 1
                    }
                }

                // assert(currentBias == .neutral || currentBias == .notEdge)

                if crossings % 2 == 1 {
                    return true
                } else {
                    return false
                }
            }

            //            print("---")
            //            print(rectangleTL2BR.map { "\($0.first)-\($0.second)" }.joined(separator: "  "))

//            print("---")
//            print(rangesPrefix.dump { i in insideRectangles.contains(where: { $0.contains(i) }) })

            let areas = insideRectangles.map(\.area)
            let area = areas.reduce(0,+)
            return area
        }
    }

    struct OrderedPair: CustomStringConvertible {
        let first: IndexRC
        let second: IndexRC
        var minR: Int { first.r }
        var maxR: Int { second.r }
        var minC: Int { first.c }
        var maxC: Int { second.c }

        init(_ first: IndexRC, _ second: IndexRC) {
            if first < second {
                self.first = first
                self.second = second
            } else {
                self.first = second
                self.second = first
            }
        }

        var description: String { "\(first)-\(second)" }

        func intersects(_ pt: IndexRC) -> Bool {
            (minR ... maxR).contains(pt.r) &&
                (minC ... maxC).contains(pt.c)
        }

        func contains(_ pt: IndexRC) -> Bool {
            (minR ..< maxR).contains(pt.r) &&
                (minC ..< maxC).contains(pt.c)
        }

        enum EdgeBias: CustomStringConvertible {
            case up, down, vertical

            var description: String { String(describing: self) }
        }

        func isEdgeLeftOf(_ pt: IndexRC) -> EdgeBias? {
            guard first.c == second.c, first.c < pt.c,
                  (minR ... maxR).contains(pt.r)
            else {
                return nil
            }

            switch pt.r {
            case minR: return .down
            case maxR: return .up
            default: return .vertical
            }
        }

        var area: Int {
            abs(second.r - first.r) * abs(second.c - first.c)
        }
    }

    struct PlanStep {
        let dir: Direction2
        let count: Int
        let distance: Int
        let dir2: Direction2

        static let parser = Parse {
            PlanStep(dir: $0, count: $1, distance: $2, dir2: $3)
        } with: {
            directionParser
            " "
            Digits()
            " "
            "(#"; distanceParser; directionParser; ")"
        }.eraseToAnyParser()

        static let directionParser = OneOf {
            "U".map { Direction2.up }
            "R".map { Direction2.right }
            "D".map { Direction2.down }
            "L".map { Direction2.left }
            "0".map { Direction2.right }
            "1".map { Direction2.down }
            "2".map { Direction2.left }
            "3".map { Direction2.up }
        }.eraseToAnyParser()

        static let distanceParser = Parse(input: Substring.self) {
            Int($0, radix: 16)!
        } with: {
            Prefix(5 ... 5, while: "0123456789abcdef".contains)
        }
    }
}

extension Day18Tests {
    static let input = try! dataFromResource(filename: "Day18Input.txt").asString

    static let example: String = #"""
    R 6 (#70c710)
    D 5 (#0dc571)
    L 2 (#5713f0)
    D 2 (#d2c081)
    R 2 (#59c680)
    D 2 (#411b91)
    L 5 (#8ceee2)
    U 2 (#caa173)
    L 1 (#1b58a2)
    U 2 (#caa171)
    R 2 (#7807d2)
    U 3 (#a77fa3)
    L 2 (#015232)
    U 2 (#7a21e3)
    """#

    // MARK: - parser

    static let inputParser = Parse {
        Many { PlanStep.parser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }
}
