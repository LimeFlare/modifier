import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
le