import Basic
import Foundation

struct GenerationOptions {
    var primaryProject: AbsolutePath?
    public init(primaryProject: AbsolutePath? = nil) {
        self.primaryProject = primaryProject
    }
}
