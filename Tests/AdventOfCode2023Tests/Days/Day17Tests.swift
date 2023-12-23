//
//  Created by Griff on 12/23/23.
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day17Tests: XCTestCase {
    func testExample() throws {
        let city = try Self.inputParser.parse(Self.example)
        let heat = city.coolestWalk()
        XCTAssertEqual(heat, 102)
    }

    func testInput() throws {
        let city = try Self.inputParser.parse(Self.input)
        let heat = city.coolestWalk()
        XCTAssertEqual(heat, 1238)
    }

    func testUltraExample() throws {
        let city = try Self.inputParser.parse(Self.example).asUltraCrucible
        let heat = city.coolestWalk()
        XCTAssertEqual(heat, 94)
    }

    func testUltraExample2() throws {
        let example = """
        111111111111
        999999999991
        999999999991
        999999999991
        999999999991
        """

        let city = try Self.inputParser.parse(example).asUltraCrucible
        let heat = city.coolestWalk()
        XCTAssertEqual(heat, 71)
    }

    func testUltraInput() throws {
        let city = try Self.inputParser.parse(Self.input).asUltraCrucible
        let heat = city.coolestWalk(start: .init(loc: .zero, dir: .down))
        XCTAssertEqual(heat, 1362)
    }
}

extension Day17Tests {
    struct City {
        let heatMap: [[Int]]
        let isValid: (IndexRC) -> Bool
        let goal: IndexRC
        let crucibleRange: ClosedRange<Int>

        init(
            heatMap: [[Int]],
            crucibleRange: ClosedRange<Int> = 1...3
        ) {
            self.heatMap = heatMap
            self.crucibleRange = crucibleRange
            self.isValid = heatMap.indexRCRanges.isValidIndex
            self.goal = IndexRC(
                heatMap.indexRCRanges.r.last!,
                heatMap.indexRCRanges.c.last!
            )
        }

        var asUltraCrucible: Self {
            Self(heatMap: heatMap, crucibleRange: 4...10)
        }

        func coolestWalk(start: State = State(loc: IndexRC(0, 0), dir: .right)) -> Int {
            let solver = AStarSolver(
                hScorer: hScore,
                neighborGenerator: neighbors,
                stepCoster: stepCost
            )

            let path = solver.solve(
                from: start,
                minimizeScore: true,
                isAtGoal: { $0.loc == goal }
            )?.reversed()

            guard let path else { fatalError() }
            let heat = zip(path, path.dropFirst())
                .map { from, to in stepCost(from: from, to: to) }
            return heat.reduce(0,+)
        }

        struct State: Hashable {
            let loc: IndexRC
            let dir: DirectionRC
        }

        func hScore(_ state: State) -> Int {
            IndexRC.manhattanDistance(state.loc, goal) * 1
        }

        func neighbors(_ state: State) -> [State] {
            crucibleRange
                .map { i in state.loc + i * state.dir.offset }
                .filter(isValid)
                .flatMap {
                    [
                        State(loc: $0, dir: state.dir.clockwise),
                        State(loc: $0, dir: state.dir.counterClockwise)
                    ]
                }
        }

        func stepCost(from: State, to: State) -> Int {
            var heat = 0
            var cur = from.loc
            repeat {
                cur += from.dir.offset
                heat += heatMap[cur]
            } while cur != to.loc

            return heat
        }
    }
}

extension Day17Tests {
    static let input = try! dataFromResource(filename: "Day17Input.txt").asString

    static let example: String = #"""
    2413432311323
    3215453535623
    3255245654254
    3446585845452
    4546657867536
    1438598798454
    4457876987766
    3637877979653
    4654967986887
    4564679986453
    1224686865563
    2546548887735
    4322674655533
    """#

    // MARK: - parser

    static let inputParser = Parse(input: Substring.self) {
        City(heatMap: $0)
    } with: {
        Many {
            Many(1...) { Digits(1) }
        } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }
}
