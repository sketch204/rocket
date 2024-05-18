import ArgumentParser
import Foundation
import FrontMatterKit
import PathKit
import HTMLConversion
import Stencil
import TOMLKit

@main
struct Rocket: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility to put together websites",
        subcommands: [Build.self],
        defaultSubcommand: Build.self
    )
}
