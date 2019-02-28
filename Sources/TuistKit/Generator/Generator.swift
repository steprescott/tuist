import Basic
import Foundation
import TuistCore

struct GeneratorConfig {
    static let `default` = GeneratorConfig()

    var options: GenerationOptions
    var directory: GenerationDirectory

    init(options: GenerationOptions = GenerationOptions(),
         directory: GenerationDirectory = .manifest) {
        self.options = options
        self.directory = directory
    }
    
    func with(options: GenerationOptions) -> GeneratorConfig {
        return GeneratorConfig(options: options,
                               directory: directory)
    }
}

protocol Generating {
    func generateProject(at path: AbsolutePath, config: GeneratorConfig) throws -> AbsolutePath
    func generateWorkspace(at path: AbsolutePath, config: GeneratorConfig) throws -> AbsolutePath
}

/// Convenince helper that leverages the manifests to invoke the
/// the appropriate generator method.
///
/// A `Workspace.swift` is searched for first, followed by `Project.swift`
extension Generating {
    func generate(at path: AbsolutePath,
                  config: GeneratorConfig,
                  manifestLoader: GraphManifestLoading) throws -> AbsolutePath {
        let manifests = manifestLoader.manifests(at: path)
        if manifests.contains(.workspace) {
            let workspaceJson = try manifestLoader.load(.workspace, path: path)
            let primaryProject: String? = try? workspaceJson.get("primaryProject")
            let primaryProjectPath = primaryProject.map { path.appending(RelativePath($0)) }
            let generationOptions = GenerationOptions(primaryProject: primaryProjectPath)
            let updatedConfig = config.with(options: generationOptions)
            return try generateWorkspace(at: path, config: updatedConfig)
        } else if manifests.contains(.project) {
            let generationOptions = GenerationOptions(primaryProject: path)
            let updatedConfig = config.with(options: generationOptions)
            return try generateProject(at: path, config: updatedConfig)
        } else {
            throw GraphManifestLoaderError.manifestNotFound(path)
        }
    }
}

class Generator: Generating {
    private let graphLoader: GraphLoading
    private let workspaceGenerator: WorkspaceGenerating
    private let modelLoader: GeneratorModelLoading
    init(system: Systeming = System(),
         printer: Printing = Printer(),
         resourceLocator: ResourceLocating = ResourceLocator(),
         fileHandler: FileHandling = FileHandler(),
         modelLoader: GeneratorModelLoading) {
        self.modelLoader = modelLoader
        graphLoader = GraphLoader(printer: printer, modelLoader: modelLoader)
        workspaceGenerator = WorkspaceGenerator(system: system,
                                                printer: printer,
                                                resourceLocator: resourceLocator,
                                                projectDirectoryHelper: ProjectDirectoryHelper(),
                                                fileHandler: fileHandler)
    }

    func generateProject(at path: AbsolutePath, config: GeneratorConfig) throws -> AbsolutePath {
        let graph = try graphLoader.loadProject(path: path)
        let sharedConfigurations = loadSharedConfiguration(graph: graph, options: config.options)
        return try workspaceGenerator.generate(path: path,
                                               graph: graph,
                                               options: config.options,
                                               sharedConfigurations: sharedConfigurations,
                                               directory: config.directory)
    }

    func generateWorkspace(at path: AbsolutePath, config: GeneratorConfig) throws -> AbsolutePath {
        let graph = try graphLoader.loadWorkspace(path: path)
        let sharedConfigurations = loadSharedConfiguration(graph: graph, options: config.options)
        return try workspaceGenerator.generate(path: path,
                                               graph: graph,
                                               options: config.options,
                                               sharedConfigurations: sharedConfigurations,
                                               directory: config.directory)
    }
    
    private func loadSharedConfiguration(graph: Graph, options: GenerationOptions) -> ConfigurationList? {
        let primaryProject = options.primaryProject.flatMap { graph.project(at: $0) }
        let configurations = primaryProject?.settings?.configurations
        return configurations.map { ConfigurationList($0) }
    }
}
