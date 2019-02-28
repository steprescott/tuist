
import XCTest
import Basic
import TuistCore
@testable import TuistCoreTesting
@testable import TuistKit

class GeneratorIntegrationTests: XCTestCase {
    
    var path: AbsolutePath!
    var fileHandler: MockFileHandler!
    var subject: Generator!
    var modelLoader: MockModelLoader!
    
    override func setUp() {
        do {
            fileHandler = try MockFileHandler()
            path = fileHandler.currentPath
            modelLoader = MockModelLoader()
            
            subject = Generator(system: System(),
                                printer: MockPrinter(),
                                resourceLocator: MockResourceLocator(),
                                fileHandler: fileHandler,
                                modelLoader: modelLoader)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // MARK: - Tests
    
    func test_generate_sharedConfigurations() throws {
        // Given
        let settings = Settings(base: ["base": "base"],
                                configurations: [
                                    .debug(name: "Debug"),
                                    .release(name: "Release"),
                                    .release(name: "Release"),
                                    ])
        
        let projectA = try createProject(name: "ProjectA", settings: settings)
        _ = try createProject(name: "ProjectB")
        
        // When
        let workspace = try subject.generateProject(at: projectA.path,
                                                    config: .default)
        
        // Then
        let resolvedSettings = try extractResolvedBuildSettings(workspacePath: workspace, scheme: "ProjectATarget")
        XCTAssertTrue(resolvedSettings.contain(settings: ["base": "base"]))
    }
    
    // MARK: - Helpers
    
    func createFiles(paths: [AbsolutePath]) throws {
        try paths.forEach {
            try fileHandler.createFolder($0.removingLastComponent())
            try fileHandler.touch($0)
        }
    }
    
    func createProject(name: String,
                       settings: Settings? = nil) throws -> Project {
        let projectPath = path.appending(RelativePath(name))
        let infoPlist = projectPath.appending(component: "Info.plist")
        
        let target = Target.test(name: "\(name)Target",
                                infoPlist: infoPlist,
                                entitlements: nil,
                                settings: nil,
                                sources: [],
                                resources: [])
        let project = Project.test(path: projectPath,
                                   name: name,
                                   settings: settings,
                                   targets: [
                                    target,
                                  ])
        
        try createFiles(paths: [
            infoPlist,
            projectPath.appending(component: "Project.swift")
        ])
        
        modelLoader.projectsCache[projectPath] = project
        return project
    }
    
    func extractResolvedBuildSettings(workspacePath: AbsolutePath, scheme: String) throws -> ExtractedBuildSettings {
        let arguments = [
            "/usr/bin/xcrun",
            "xcodebuild",
            "-workspace",
            workspacePath.asString,
            "-scheme",
            scheme,
            "-showBuildSettings"
        ]
        
        let rawBuildSettings = try Basic.Process.checkNonZeroExit(arguments: arguments)
        return ExtractedBuildSettings(rawBuildSettings: rawBuildSettings)
    }
    
    struct ExtractedBuildSettings {
        let rawBuildSettings: String
        func contain(settings: [String: String]) -> Bool {
            for (key, value) in settings {
                if !rawBuildSettings.contains("\(key) = \(value)\n") {
                    return false
                }
            }
            return true
        }
    }
    
}
