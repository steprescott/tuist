import Basic
import Foundation
import TuistCore
@testable import TuistKit

final class MockWorkspaceGenerator: WorkspaceGenerating {
    var generateStub: ((AbsolutePath, Graphing, GenerationOptions, ConfigurationList?, GenerationDirectory) throws -> AbsolutePath)?

    func generate(path: AbsolutePath, graph: Graphing, options: GenerationOptions, sharedConfigurations: ConfigurationList?, directory: GenerationDirectory) throws -> AbsolutePath {
        return (try generateStub?(path, graph, options, sharedConfigurations, directory)) ?? AbsolutePath("/test")
    }
}
