use regex::Regex;
use std::env::{var, vars, VarError};
use std::sync::LazyLock;

static REGEXP_WAREHOUSE_ENDPOINT: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"^WAREHOUSE__(?<index>\d)__ENDPOINT.*").unwrap());

pub(crate) fn get_warehouse_env_vars() -> Vec<WarehouseEnv> {
    vars()
        .filter(|(key, _)| REGEXP_WAREHOUSE_ENDPOINT.find(key.as_str()).is_some())
        .map(|(key, endpoint)| {
            let some_warehouse_index = REGEXP_WAREHOUSE_ENDPOINT.captures(key.as_str()).unwrap();
            println!("some_warehouse_index: {:?}", some_warehouse_index);
            let index = some_warehouse_index.name("index").unwrap().as_str();
            let country_key = format!("WAREHOUSE__{}__COUNTRY", index);
            let some_country = var(country_key);
            println!("endpoint: {}", endpoint);
            (endpoint, some_country).into()
        })
        .collect::<Vec<_>>()
}

impl From<(String, Result<String, VarError>)> for WarehouseEnv {
    fn from((endpoint, country): (String, Result<String, VarError>)) -> Self {
        WarehouseEnv {
            endpoint,
            country: country.ok(),
        }
    }
}

#[derive(Clone)]
pub(crate) struct WarehouseEnv {
    pub(crate) endpoint: String,
    pub(crate) country: Option<String>,
}
