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
        } while !machine.outputs.contains(where: { $0.isHigh == false })
        XCTAssertEqual(i, -1)
    }
}

extension Day20Tests {
    struct Machine {
        var modules: [Module.Name: Module] = [:]
        var pulses: [Pulse] = []
        var nextPulse: Int = 0
        var outputs: [Pulse] = []

        init(modules: [Module]) {
            for module in modules {
                self.modules[module.name] = module
            }

            let inputsByModuleName = modules.reduce(into: [Module.Name: [Module.Name]]()) { result, module in
                module.outputs.forEach { output in
                    result[output, default: []].append(module.name)
                }
            }
            for module in modules {
                guard case let .conjunction(name, _, outputs) = module else { continue }
                let withInputs = Module.conjunction(
                    name,
                    inputs: Dictionary(uniqueKeysWithValues: inputsByModuleName[name]!.map { ($0, false) }),
                    outputs: outputs
                )
                self.modules[name] = withInputs
            }
        }

        var lowsTimesHighs: Int {
            let highs = pulses.filter(\.isHigh).count
            let lows = pulses.count - highs
            return lows * highs
        }

        mutating func pressButton() {
            pulses.append(Pulse(isHigh: false, from: "button", to: "broadcaster"))
            processPulses()
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
                outputs.append(pulse)
                return
            }

            switch toModule {
            case let .broadcaster(outputs):
                outputs.forEach { output in
                    pulses.append(.init(isHigh: pulse.isHigh, from: toModule.name, to: output))
                }
            case let .flipFlop(name, wasOn, outputs: outputs):
                guard !pulse.isHigh else {
                    break
                }
                modules[name] = .flipFlop(name, isOn: !wasOn, outputs: outputs)

                outputs.forEach { output in
                    pulses.append(.init(isHigh: !wasOn, from: name, to: output))
                }

            case let .conjunction(name, inputs, outputs: outputs):
                var inputs = inputs
                inputs[pulse.from] = pulse.isHigh

                let allHigh = inputs.allSatisfy(\.value)

                outputs.forEach { output in
                    pulses.append(.init(isHigh: !allHigh, from: name, to: output))
                }
            }
        }
    }

    struct Pulse: CustomStringConvertible {
        let isHigh: Bool
        let from: Module.Name
        let to: Module.Name

        var description: String {
            "\(from) \(isHigh) -> \(to)"
        }
    }

    enum Module: Equatable {
        typealias Name = Substring

        case broadcaster(outputs: [Name])
        case flipFlop(Name, isOn: Bool, outputs: [Name])
        case conjunction(Name, inputs: [Name: Bool], outputs: [Name])

        var name: Name {
            switch self {
            case .broadcaster: "broadcaster"
            case let .flipFlop(name, _, _): name
            case let .conjunction(name, _, _): name
            }
        }

        var outputs: [Name] {
            switch self {
            case let .broadcaster(outputs): outputs
            case let .flipFlop(_, _, outputs): outputs
            case let .conjunction(_, _, outputs): outputs
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
                Module.flipFlop($0, isOn: false, outputs: $1)
            } with: {
                "%"; nameParser; " -> "
                Many { nameParser } separator: { ", " }
            }

            Parse {
                Module.conjunction($0, inputs: [:], outputs: $1)
            } with: {
                "&"; nameParser; " -> "
                Many { nameParser } separator: { ", " }
            }
        }

        static let nameParser = Parse { CharacterSet.letters }
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
