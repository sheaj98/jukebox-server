import FluentMySQL
import Vapor
import SwiftyBeaverVapor
import SwiftyBeaver

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws {
    // 2
    try services.register(FluentMySQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    let loggingDestination = SBPlatformDestination(appID: "k6POqE", appSecret: "Qsm7uhkfzkivo3lkeznazhbjmvgi7gcF", encryptionKey: "omBc4pbe7gaIns3WjXapkouvvjiivci4")
    let consoleDestination = ConsoleDestination()
    let file = FileDestination()  // log to file
    file.logFileURL = URL(string: "file:///tmp/VaporLogs.log")!
    try services.register(SwiftyBeaverProvider(destinations: [loggingDestination, consoleDestination, file]))
    
    config.prefer(SwiftyBeaverVapor.self, for: Logger.self)
    
    let websockets = NIOWebSocketServer.default()
    sockets(websockets)
    services.register(websockets, as: WebSocketServer.self)
    
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    services.register(middlewares)
    
    var databases = DatabasesConfig()
    // 3
    let hostname = Environment.get("DATABASE_HOSTNAME")
        ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD")
        ?? "password"
    // 3
    let databaseConfig = MySQLDatabaseConfig(
        hostname: hostname,
        username: username,
        password: password,
        database: databaseName)
    // 4
    
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    var migrations = MigrationConfig()
    // 4
    migrations.add(model: Song.self, database: .mysql)
    migrations.add(model: Party.self, database: .mysql)
    //migrations.add(migration: AddSpotifyTokenToParty.self, database: .mysql)
    
    services.register(migrations)
}
