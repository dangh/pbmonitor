//
//  pbmonitor
//  A simple CLI tool for macOS to monitor clipboard changes and output the contents as stream
//  Based on klipsustreamer by Toni Lähdekorpi. All rights reserved.
//

import AppKit
import ArgumentParser

@propertyWrapper struct DelimiterSequence: ExpressibleByArgument {
    var wrappedValue: String {
        didSet {}
    }

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    init?(argument: String) {
        self.wrappedValue = argument
    }

    public var defaultValueDescription: String {
        self.wrappedValue == "\0"
            ? "NUL"
            : self.wrappedValue
    }
}

struct PbMonitor: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "pbmonitor")

    @Option(name: [.short, .long], help: ArgumentHelp("Delimiter string to print between clipboard", valueName: "string"))
    @DelimiterSequence var delimiter: String = "\0"

    @Option(name: [.short, .long], help: ArgumentHelp("Polling interval in seconds", valueName: "seconds"))
    var interval: Double = 0.1

    mutating func run() {
        Self.watch(delimiter: delimiter, interval: interval)
        while RunLoop.current.run(mode: RunLoop.Mode.default, before: .distantFuture) { }
    }

    static var count = 0
    static var content = ""

    static func watch(delimiter: String, interval: Double) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            if count != NSPasteboard.general.changeCount {
                count = NSPasteboard.general.changeCount
                
                if let str = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string) {
                    if content != str {
                        content = str
                        
                        print(content, terminator: delimiter)
                        fflush(stdout)
                    }
                }
            }
        })
    }
}

PbMonitor.main()
