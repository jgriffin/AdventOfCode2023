import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day19Tests: XCTestCase {
    func testParseExample() throws {
        let (workflows, parts) = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(workflows.workflows.count, 11)
        XCTAssertEqual(parts.count, 5)

        let accepted = parts.filter(workflows.isAccepted)
        let ratings = accepted.map(\.rating)
        let rating = ratings.reduce(0,+)
        XCTAssertEqual(rating, 19114)
    }

    func testParseInput() throws {
        let (workflows, parts) = try Self.inputParser.parse(Self.input)
        XCTAssertEqual(workflows.workflows.count, 552)
        XCTAssertEqual(parts.count, 200)

        let accepted = parts.filter(workflows.isAccepted)
        let ratings = accepted.map(\.rating)
        let rating = ratings.reduce(0,+)
        XCTAssertEqual(rating, 362_930)
    }

    func testAcceptedPartRangesExample() throws {
        let (workflows, _) = try Self.inputParser.parse(Self.example)

        let acceptedRanges = workflows.acceptedPartRangesFrom(
            .workflow("in"),
            PartRange(x: 1 ..< 4001, m: 1 ..< 4001, a: 1 ..< 4001, s: 1 ..< 4001)
        )
        let count = acceptedRanges.map { xmas in
            xmas.x.count * xmas.m.count * xmas.a.count * xmas.s.count
        }.reduce(0,+)
        XCTAssertEqual(count, 167_409_079_868_000)
    }

    func testAcceptedPartRangesInput() throws {
        let (workflows, _) = try Self.inputParser.parse(Self.input)

        let acceptedRanges = workflows.acceptedPartRangesFrom(
            .workflow("in"),
            PartRange(x: 1 ..< 4001, m: 1 ..< 4001, a: 1 ..< 4001, s: 1 ..< 4001)
        )
        let count = acceptedRanges.map { xmas in
            xmas.x.count * xmas.m.count * xmas.a.count * xmas.s.count
        }.reduce(0,+)
        XCTAssertEqual(count, 116_365_820_987_729)
    }
}

extension Day19Tests {
    struct Workflows {
        let workflows: [Substring: Workflow]

        init(_ workflows: [Workflow]) {
            self.workflows = Dictionary(uniqueKeysWithValues: workflows.map { ($0.name, $0) })
        }

        func isAccepted(_ part: Part) -> Bool {
            var current: State = .workflow("in")
            while true {
                switch current {
                case .accept: return true
                case .reject: return false
                case let .workflow(name):
                    guard let workflow = workflows[name] else {
                        fatalError()
                    }
                    current = workflow.nextStateFor(part)
                }
            }
        }

        func acceptedPartRangesFrom(_ state: State, _ partRange: PartRange) -> [PartRange] {
            switch state {
            case .accept:
                return [partRange]
            case .reject:
                return []
            case let .workflow(workflowName):
                guard let workflow = workflows[workflowName] else { fatalError() }

                // break ranges on rule value boundaries
                let splitRanges = workflow.rules.reduce([partRange]) { result, rule -> [PartRange] in
                    result.flatMap { pr -> [PartRange] in
                        pr.splitAt(rule.property, value: rule.splitValue)
                    }
                }

                // find nextState for each splitRange
                let nextStateAndRange = splitRanges.map { pr -> (State, PartRange) in
                    let next = workflow.nextStateFor(.init(x: pr.x.first!, m: pr.m.first!, a: pr.a.first!, s: pr.s.first!))
                    return (next, pr)
                }

                return nextStateAndRange.flatMap { state, pr in
                    acceptedPartRangesFrom(state, pr)
                }
            }
        }
    }

    struct Workflow {
        let name: Substring
        let rules: [Rule]
        let orState: State

        func nextStateFor(_ part: Part) -> State {
            guard let rule = rules.first(where: { $0.passes(part) }) else {
                return orState
            }
            return rule.result
        }

        static let parser = Parse(Workflow.init) {
            CharacterSet.letters
            "{"
            Many(1...) { Rule.parser } separator: { "," }
            ","
            State.parser
            "}"
        }
    }

    struct Rule {
        let property: Property
        let op: Operation
        let value: Int
        let result: State

        var splitValue: Int {
            switch op {
            case .gt: value + 1
            case .lt: value
            }
        }

        func passes(_ part: Part) -> Bool {
            let partValue = part.valueOf(property)
            return switch op {
            case .lt: partValue < value
            case .gt: partValue > value
            }
        }

        static let parser = ParsePrint(.memberwise(Rule.init)) {
            Property.parser
            Operation.parser
            Digits()
            ":"
            State.parser
        }

        enum Operation: ParserPrinterStringConvertible {
            case lt, gt

            static let parser = OneOf {
                "<".map { Operation.lt }
                ">".map { Operation.gt }
            }.eraseToAnyParserPrinter()
        }
    }

    enum State: Equatable, CustomStringConvertible {
        case accept, reject, workflow(Substring)

        static let parser = ParsePrint(
            .convert(
                apply: { State($0) },
                unapply: { $0.description[...] }
            )
        ) {
            CharacterSet.letters
        }

        init(_ s: Substring) {
            switch s {
            case "A": self = .accept
            case "R": self = .reject
            default: self = .workflow(s)
            }
        }

        var description: String {
            switch self {
            case .accept: "A"
            case .reject: "R"
            case let .workflow(workflow): workflow.asString
            }
        }
    }

    struct PartRange: Hashable, CustomStringConvertible {
        let x: Range<Int>
        let m: Range<Int>
        let a: Range<Int>
        let s: Range<Int>

        var description: String {
            "(x: \(x.lowerBound)-\(x.upperBound - 1)  m: \(m.lowerBound)-\(m.upperBound - 1)  a: \(a.lowerBound)-\(a.upperBound - 1)  s: \(s.lowerBound)-\(s.upperBound - 1))"
        }

        // value goes in the upper range
        func splitAt(_ property: Property, value: Int) -> [PartRange] {
            switch property {
            case .x:
                guard x.contains(value),
                      case let (lower, upper) = (x.lowerBound ..< value, value ..< x.upperBound),
                      !lower.isEmpty, !upper.isEmpty
                else { return [self] }
                return [
                    PartRange(x: lower, m: m, a: a, s: s),
                    PartRange(x: upper, m: m, a: a, s: s),
                ]
            case .m:
                guard m.contains(value),
                      case let (lower, upper) = (m.lowerBound ..< value, value ..< m.upperBound),
                      !lower.isEmpty, !upper.isEmpty
                else { return [self] }
                return [
                    PartRange(x: x, m: lower, a: a, s: s),
                    PartRange(x: x, m: upper, a: a, s: s),
                ]
            case .a:
                guard a.contains(value),
                      case let (lower, upper) = (a.lowerBound ..< value, value ..< a.upperBound),
                      !lower.isEmpty, !upper.isEmpty
                else { return [self] }
                return [
                    PartRange(x: x, m: m, a: lower, s: s),
                    PartRange(x: x, m: m, a: upper, s: s),
                ]
            case .s:
                guard s.contains(value),
                      case let (lower, upper) = (s.lowerBound ..< value, value ..< s.upperBound),
                      !lower.isEmpty, !upper.isEmpty
                else { return [self] }
                return [
                    PartRange(x: x, m: m, a: a, s: lower),
                    PartRange(x: x, m: m, a: a, s: upper),
                ]
            }
        }

        func ruleApplies(_ rule: Rule) -> Bool {
            switch rule.property {
            case .x:
                x.contains(rule.value)
            case .m:
                m.contains(rule.value)
            case .a:
                a.contains(rule.value)
            case .s:
                s.contains(rule.value)
            }
        }
    }

    struct Part {
        let x: Int
        let m: Int
        let a: Int
        let s: Int

        func valueOf(_ property: Property) -> Int {
            switch property {
            case .x: x
            case .m: m
            case .a: a
            case .s: s
            }
        }

        var rating: Int {
            x + m + a + s
        }

        static let parser = ParsePrint(.memberwise(Part.init)) {
            "{"
            "x="; Digits()
            ",m="; Digits()
            ",a="; Digits()
            ",s="; Digits()
            "}"
        }
    }

    enum Property: CaseIterable, ParserPrinterStringConvertible {
        case x, m, a, s

        static let parser = OneOf {
            "x".map { Property.x }
            "m".map { Property.m }
            "a".map { Property.a }
            "s".map { Property.s }
        }.eraseToAnyParserPrinter()
    }
}

extension Day19Tests {
    static let input = try! dataFromResource(filename: "Day19Input.txt").asString

    static let example: String = #"""
    px{a<2006:qkq,m>2090:A,rfg}
    pv{a>1716:R,A}
    lnx{m>1548:A,A}
    rfg{s<537:gd,x>2440:R,A}
    qs{s>3448:A,lnx}
    qkq{x<1416:A,crn}
    crn{x>2662:A,R}
    in{s<1351:px,qqz}
    qqz{s>2770:qs,m<1801:hdj,R}
    gd{a>3333:R,R}
    hdj{m>838:A,pv}

    {x=787,m=2655,a=1222,s=2876}
    {x=1679,m=44,a=2067,s=496}
    {x=2036,m=264,a=79,s=2244}
    {x=2461,m=1339,a=466,s=291}
    {x=2127,m=1623,a=2188,s=1013}
    """#

    // MARK: - parser

    static let inputParser = Parse { workflows, parts in
        (Workflows(workflows), parts)
    } with: {
        Many { Workflow.parser } separator: { "\n" }
        "\n\n"
        Many { Part.parser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }.eraseToAnyParser()
}
