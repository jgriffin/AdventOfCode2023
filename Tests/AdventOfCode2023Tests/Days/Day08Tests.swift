//
// Created by John Griffin on 12/8/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day08Tests: XCTestCase {
    func testExample() throws {
        let (instructions, nodes) = try Self.inputParser.parse(Self.example)
        let stepCount = steps(instructions, nodes)
        XCTAssertEqual(stepCount, 2)
    }
    
    func testExample2() throws {
        let (instructions, nodes) = try Self.inputParser.parse(Self.example2)
        let stepCount = steps(instructions, nodes)
        XCTAssertEqual(stepCount, 6)
    }
    
    func testInput() throws {
        let (instructions, nodes) = try Self.inputParser.parse(Self.input)
        let stepCount = steps(instructions, nodes)
        XCTAssertEqual(stepCount, 24253)
    }
    
    func testGhostExample() throws {
        let example = """
        LR

        11A = (11B, XXX)
        11B = (XXX, 11Z)
        11Z = (11B, XXX)
        22A = (22B, XXX)
        22B = (22C, 22C)
        22C = (22Z, 22Z)
        22Z = (22B, 22B)
        XXX = (XXX, XXX)
        """
        
        let (instructions, nodes) = try Self.inputParser.parse(example)
        let stepCount = ghostSteps(instructions, nodes)
        XCTAssertEqual(stepCount, 6)
    }
    
    func testGhostInput() throws {
        let (instructions, nodes) = try Self.inputParser.parse(Self.input)
        let stepCount = ghostSteps(instructions, nodes)
        XCTAssertEqual(stepCount, 12357789728873)
    }
}

extension Day08Tests {
    func steps(_ instructions: [Direction], _ nodes: [Node]) -> Int {
        let nodeMap = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        let isExitNode = { (node: Node.ID) in node == "ZZZ" }
        let nextExitFrom = makeNextExitFrom(isExitNode: isExitNode, instructions, nodeMap)
        
        let start = State(node: "AAA", step: 0)
        let exit = nextExitFrom(start)
        return exit.stepCount
    }
    
    func ghostSteps(_ instructions: [Direction], _ nodes: [Node]) -> Int {
        let nodeMap = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        let isExitNode = { (node: Node.ID) in node.last == "Z" }
        let nextExitFrom = makeNextExitFrom(isExitNode: isExitNode, instructions, nodeMap)
        
        let ghostStarts = nodes.map(\.id).filter { $0.hasSuffix("A") }.map {
            State(node: $0, step: 0)
        }
        let ghostExits = ghostStarts.map {
            stableGhostExit(StateAndCount(state: $0, stepCount: 0), nextExitFrom)
        }
        print(ghostExits.description)
        let stepsNeeded = LCM(ghostExits.map(\.repeating.stepCount))
        return stepsNeeded
    }
    
    // MARK: - next exit
    
    func stableGhostExit(_ start: StateAndCount, _ nextExitFrom: NextExitFrom) -> (pre: StateAndCount, repeating: StateAndCount) {
        var history = [StateAndCount]()
        var next = start
        repeat {
            history.append(next)
            next = nextExitFrom(next.state)
        } while !history.contains(where: { $0.state == next.state })
        
        let repeatingIndex = history.firstIndex(where: { $0.state == next.state })!
        let preList = history[..<repeatingIndex]
        let repeatingList = history[repeatingIndex...]
        
        let pre = StateAndCount(
            state: preList.last!.state,
            stepCount: preList.map(\.stepCount).reduce(0,+)
        )
        let repeating = StateAndCount(
            state: repeatingList.last!.state,
            stepCount: repeatingList.map(\.stepCount).reduce(0,+)
        )
                                  
        return (pre, repeating)
    }
    
    struct State: Hashable, CustomStringConvertible {
        let node: Node.ID
        let step: Int
        
        var description: String { "\(node) \(step)" }
    }
    
    struct StateAndCount: Equatable, CustomStringConvertible {
        var state: State
        var stepCount: Int
        
        static func += (lhs: inout StateAndCount, rhs: StateAndCount) {
            lhs = lhs + rhs
        }
        
        static func + (lhs: StateAndCount, rhs: StateAndCount) -> StateAndCount {
            StateAndCount(state: rhs.state, stepCount: lhs.stepCount + rhs.stepCount)
        }
        
        var description: String { "\(state) - \(stepCount)" }
    }
    
    typealias NextExitFrom = (State) -> StateAndCount
    
    func makeNextExitFrom(
        isExitNode: @escaping (Node.ID) -> Bool,
        _ instructions: [Direction],
        _ nodeMap: [Node.ID: Node]
    ) -> NextExitFrom {
        Memoizer.memoizedFn { (state: State) in
            var stepCount = 0
            var current = state
            
            repeat {
                let direction = instructions[current.step]
                stepCount += 1
                current = State(
                    node: nodeMap[current.node]!.next(direction),
                    step: (current.step + 1) % instructions.count
                )
            } while !isExitNode(current.node)
            
            let result = StateAndCount(state: current, stepCount: stepCount)
            // print("new stride: \(result)")
            return result
        }
    }
}

extension Day08Tests {
    struct Node: ParserPrinterStringConvertible {
        typealias ID = Substring
        let id: ID
        let left: ID
        let right: ID

        func next(_ direction: Direction) -> ID {
            switch direction {
            case .l: left
            case .r: right
            }
        }
        
        static let start: ID = "AAA"
        static let goal: ID = "ZZZ"

        static let parser = ParsePrint(input: Substring.self, .memberwise(Node.init)) {
            Prefix(3)
            " = ("
            Prefix(3)
            ", "
            Prefix(3)
            ")"
        }
    }
    
    enum Direction: ParserPrinterStringConvertible {
        case l, r
        
        static let parser = ParsePrint {
            OneOf {
                "L".map { Direction.l }
                "R".map { Direction.r }
            }
        }
    }
    
    static let input = try! dataFromResource(filename: "Day08Input.txt").asString
    
    static let example: String = """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
    """
    
    static let example2: String = """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
    """
    
    // MARK: - parser
    
    static let inputParser = Parse {
        Many { Direction.parser }
        "\n\n"
        Many { Node.parser } separator: { "\n" }
        Skip { Optionally { "\n" }}
    }.eraseToAnyParser()
    
    func testParseExample() throws {
        let (instructions, nodes) = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(instructions, [.r, .l])
        XCTAssertEqual(nodes.count, 7)
    }
    
    func testParseInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        XCTAssertNotNil(input)
    }
}
