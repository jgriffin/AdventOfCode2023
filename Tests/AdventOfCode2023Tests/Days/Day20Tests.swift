import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day20Tests: XCTestCase {
    func testParseSimpleExample() throws {
        let modules = try Self.inputParser.parse(Self.simpleExample)
        var machine = Machine(modules: modules)
        1000.times {
            machine.pressButton()
        }
        XCTAssertEqual(machine.lowsTimesHighs, 32_000_000)
    }

    func testParseInput() throws {
        let modules = try Self.inputParser.parse(Self.input)
        var machine = Machine(modules: modules)
        print(machine.state.fullDescription)
        1000.times {
            machine.pressButton()
        }
        XCTAssertEqual(machine.lowsTimesHighs, 711_650_489)
    }

    func testTilLowInput() throws {
        let modules = try Self.inputParser.parse(Self.input)
        var machine = Machine(modules: modules)
        var i = 0
        repeat {
            i += 1
            machine.pressButton()
        } while !machine.didOutputLow
        XCTAssertEqual(i, -1)
    }
}

extension Day20Tests {
    struct Machine {
        let modules: [Module.Name: Module]
        let inputs: [Module.Name: [Module.Name]]
        var pulses: [Pulse] = []
        var nextPulse: Int = 0
        var didOutputLow = false

        var state: State

        init(modules: [Module]) {
            self.modules = Dictionary(uniqueKeysWithValues: modules.map { ($0.name, $0) })
            self.inputs = modules.reduce(into: [Module.Name: [Module.Name]]()) { result, module in
                module.outputs.forEach { output in
                    result[output, default: []].append(module.name)
                }
            }
            print(inputs.description)
            state = Self.initialStateFrom(modules, inputs)
        }

        static func initialStateFrom(_ modules: [Module], _ inputs: [Module.Name: [Module.Name]]) -> State {
            let flipFlops = modules.reduce(into: [Module.Name: Bool]()) { result, module in
                guard case let .flipFlop(name, _) = module else { return }
                result[name] = false
            }
            let conjunctions = modules.reduce(into: [Module.Name: [Module.Name: Bool]]()) { result, module in
                guard case let .conjunction(name, _) = module else { return }
                result[name] = Dictionary(uniqueKeysWithValues: inputs[name]!.map { ($0, false) })
            }
            return State(
                flipFlops: flipFlops,
                conjunctions: conjunctions
            )
        }

        var lowsTimesHighs: Int {
            let highs = pulses.filter(\.isHigh).count
            let lows = pulses.count - highs
            return lows * highs
        }

        mutating func pressButton() {
            pulses.append(Pulse(isHigh: false, from: "button", to: "broadcaster"))
            processPulses()
            print(state)
        }

        mutating func processPulses() {
            while nextPulse < pulses.count {
                let pulse = pulses[nextPulse]
                processPulse(pulse)
                nextPulse += 1
            }
        }

        mutating func processPulse(_ pulse: Pulse) {
            guard let toModule = modules[pulse.to] else {
                if !pulse.isHigh {
                    didOutputLow = true
                }
                return
            }

            switch toModule {
            case let .broadcaster(outputs):
                outputs.prefix(1).forEach { output in
                    pulses.append(.init(isHigh: pulse.isHigh, from: toModule.name, to: output))
                }
            case let .flipFlop(name, outputs: outputs):
                guard !pulse.isHigh else {
                    break
                }

                let wasOn = state.flipFlops[name]!
                state.flipFlops[name] = !wasOn

                outputs.forEach { output in
                    pulses.append(.init(isHigh: !wasOn, from: name, to: output))
                }

            case let .conjunction(name, outputs: outputs):
                state.conjunctions[name]![pulse.from] = pulse.isHigh

                let allHigh = state.conjunctions[name]!.allSatisfy(\.value)

                outputs.forEach { output in
                    pulses.append(.init(isHigh: !allHigh, from: name, to: output))
                }
            }
        }
    }

    struct State: CustomStringConvertible {
        var flipFlops: [Module.Name: Bool]
        var conjunctions: [Module.Name: [Module.Name: Bool]]

        var fullDescription: String {
            let ff = flipFlops.sorted(by: \.key).map { "\($0.key)\($0.value ? "+" : "-")" }.joined(separator: " ")
            let cjs = conjunctions.map { cj in
                let inputs = cj.value.sorted(by: \.key).map { "\($0.key)\($0.value ? "+" : "-")" }.joined(separator: " ")
                return "\(cj.key)  \(inputs)"
            }.joinedByNewlines
            return "\(ff)\n\(cjs)\n"
        }

        var description: String {
            let ff = flipFlops.sorted(by: \.key).map { $0.value ? "+" : "-" }.joined()
            let cjs = conjunctions.map { cj in
                cj.value.sorted(by: \.key).map { $0.value ? "+" : "-" }.joined()
            }.joined(separator: " ")
            return "\(ff)\t\(cjs)"
        }
    }

    enum Module: Equatable {
        typealias Name = Substring

        case broadcaster(outputs: [Name])
        case flipFlop(Name, outputs: [Name])
        case conjunction(Name, outputs: [Name])

        var name: Name {
            switch self {
            case .broadcaster: "broadcaster"
            case let .flipFlop(name, _): name
            case let .conjunction(name, _): name
            }
        }

        var outputs: [Name] {
            switch self {
            case let .broadcaster(outputs): outputs
            case let .flipFlop(_, outputs): outputs
            case let .conjunction(_, outputs): outputs
            }
        }

        static let parser = OneOf {
            Parse {
                Module.broadcaster(outputs: $0)
            } with: {
                "broadcaster -> "
                Many { nameParser } separator: { ", " }
            }

            Parse {
                Module.flipFlop($0, outputs: $1)
            } with: {
                "%"; nameParser; " -> "
                Many { nameParser } separator: { ", " }
            }

            Parse {
                Module.conjunction($0, outputs: $1)
            } with: {
                "&"; nameParser; " -> "
                Many { nameParser } separator: { ", " }
            }
        }

        static let nameParser = Parse { CharacterSet.letters }
    }

    struct Pulse: CustomStringConvertible {
        let isHigh: Bool
        let from: Module.Name
        let to: Module.Name

        var description: String {
            "\(from) \(isHigh) -> \(to)"
        }
    }

    // MARK: - parser

    static let inputParser = Parse {
        Many { Module.parser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }
}

extension Day20Tests {
    static let input = try! dataFromResource(filename: "Day20Input.txt").asString

    static let simpleExample = """
    broadcaster -> a, b, c
    %a -> b
    %b -> c
    %c -> inv
    &inv -> a
    """

    static let example: String = #"""
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
    """#
}
