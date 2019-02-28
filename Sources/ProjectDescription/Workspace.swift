import Foundation

// MARK: - Workspace

public class Workspace: Codable {
    /// Workspace name
    public let name: String

    /// Relative path to the primary project of the workspace.
    ///
    /// Note: The configuration of the primary project
    ///       will be shared between all projects
    ///       of the workspace.
    public let primaryProject: String?
    
    /// Relative paths to the projects.
    /// Note: The paths are relative from the folder that contains the workspace.
    public let projects: [String]

    public init(name: String,
                primaryProject: String? = nil,
                projects: [String]) {
        self.name = name
        self.projects = projects
        self.primaryProject = primaryProject
        dumpIfNeeded(self)
    }
}
