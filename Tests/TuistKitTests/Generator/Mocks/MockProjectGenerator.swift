import Basic
import Foundation
import TuistCore
@testable import TuistKit

final class MockProjectGenerator: ProjectGenerating {

    var generateStub: ((Project, GenerationOptions, Graphing, ConfigurationList?, AbsolutePath?) throws -> GeneratedProject)?

    func generate(project: Project,
                  options: GenerationOptions,
                  graph: Graphing,
                  sharedConfigurations: ConfigurationList?,
                  sourceRootPath: AbsolutePath?) throws -> GeneratedProject {
        return try generateStub?(project, options, graph, sharedConfigurations, sourceRootPath) ?? GeneratedProject.test()
    }
}
