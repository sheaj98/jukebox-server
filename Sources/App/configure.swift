import FluentMySQL
import Vapor

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
    let databaseConfig = MySQLDatabaseConfig(
        hostname: "localhost",
        username: "vapor",
        password: "password",
        database: "vapor")
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    var migrations = MigrationConfig()
    // 4
    migrations.add(model: Song.self, database: .mysql)
    migrations.add(model: Party.self, database: .mysql)
    services.register(migrations)
}
