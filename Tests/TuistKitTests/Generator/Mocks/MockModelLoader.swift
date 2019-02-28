
import Foundation
import Basic
@testable import TuistKit

enum MockModelLoaderError: Error {
    case missingModel(AbsolutePath)
}

class MockModelLoader: GeneratorModelLoading {
    var projectsCache: [AbsolutePath: Project] = [:]
    var workspaceCache: [AbsolutePath: Workspace] = [:]
    
    func loadProject(at path: AbsolutePath) throws -> Project {
        guard let project = projectsCache[path] else {
            throw MockModelLoaderError.missingModel(path)
        }
        
        return project
    }
    
    func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
        guard let workspace = workspaceCache[path] else {
            throw MockModelLoaderError.missingModel(path)
        }
        
        return workspace
    }
}
