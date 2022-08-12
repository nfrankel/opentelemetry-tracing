import envoy
import gleam/int

pub type Config {
  Config(
    port: Int,
    db_host: String,
    db_port: Int,
    db_user: String,
    db_password: String,
    db_name: String,
  )
}

pub fn load() -> Config {
  Config(
    port: get_env_int("PORT", 8000),
    db_host: get_env("PG_HOST", "localhost"),
    db_port: get_env_int("PG_PORT", 5432),
    db_user: get_env("PG_USER", "postgres"),
    db_password: get_env("PG_PASSWORD", ""),
    db_name: get_env("PG_DBNAME", "postgres"),
  )
}

fn get_env(key: String, default: String) -> String {
  case envoy.get(key) {
    Ok(value) -> value
    Error(_) -> default
  }
}

fn get_env_int(key: String, default: Int) -> Int {
  case envoy.get(key) {
    Ok(value) ->
      case int.parse(value) {
        Ok(int_value) -> int_value
        Error(_) -> default
      }
    Error(_) -> default
  }
}
