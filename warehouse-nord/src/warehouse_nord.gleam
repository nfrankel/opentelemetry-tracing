import gleam/erlang/process
import gleam/int
import gleam/io
import mist
import warehouse_nord/config
import warehouse_nord/database
import warehouse_nord/routes

@external(erlang, "application", "ensure_all_started")
fn ensure_all_started(app: Atom) -> Result(List(Atom), Tuple)

type Atom

type Tuple

@external(erlang, "erlang", "binary_to_atom")
fn binary_to_atom(binary: String) -> Atom

pub fn main() {
  // Start required applications for OpenTelemetry and all their dependencies
  io.println("Starting OpenTelemetry dependencies...")
  // ensure_all_started will recursively start all dependencies
  case ensure_all_started(binary_to_atom("opentelemetry_exporter")) {
    Ok(_) -> io.println("OpenTelemetry exporter started successfully")
    Error(_) -> io.println("Warning: OpenTelemetry exporter startup had issues")
  }
  case ensure_all_started(binary_to_atom("opentelemetry")) {
    Ok(_) -> io.println("OpenTelemetry started successfully")
    Error(_) -> io.println("Warning: OpenTelemetry startup had issues")
  }

  // Load configuration
  let cfg = config.load()

  io.println("Starting warehouse-nord service...")
  io.println("Connecting to database at " <> cfg.db_host <> ":" <> int.to_string(
    cfg.db_port,
  ))

  // Connect to database
  let assert Ok(db) = database.connect(cfg)
  io.println("Successfully connected to database")

  // Start HTTP server
  let port_str = int.to_string(cfg.port)
  io.println("Starting HTTP server on port " <> port_str <> "...")

  let assert Ok(_) =
    mist.new(routes.handle_request(db))
    |> mist.bind("0.0.0.0")
    |> mist.port(cfg.port)
    |> mist.start

  io.println("Server started successfully on http://0.0.0.0:" <> port_str)
  io.println("Endpoints:")
  io.println("  GET /stocks       - Get all stock levels")
  io.println("  GET /stocks/:id   - Get stock levels for product ID")

  // Keep the process alive
  process.sleep_forever()
}
