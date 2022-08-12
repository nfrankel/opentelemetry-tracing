use std::env::vars;

use itertools::Itertools;
use lazy_static::lazy_static;
use regex::Regex;

lazy_static! {
    static ref WAREHOUSE_REGEXP: Regex = Regex::new(r"^WAREHOUSE__\d__.*").unwrap();
}

pub(crate) fn get_warehouse_env_vars() -> Vec<WarehouseEnv> {
    vars()
        .filter(|(key, _)| WAREHOUSE_REGEXP.find(key.as_str()).is_some())
        .group_by(|(key, _)| key.split("__").nth(1).unwrap().to_string())
        .into_iter()
        .map(|(_, mut group)| {
            let some_endpoint = group.find(|item| item.0.ends_with("ENDPOINT"));
            println! {"Endpoint pair is: {:?}", some_endpoint};
            let endpoint = some_endpoint.unwrap().1;
            let some_country = group
                .find(|item| item.0.ends_with("COUNTRY"))
                .map(|(_, country)| country);
            println! {"Country pair is: {:?}", some_country};
            (endpoint, some_country).into()
        })
        .collect_vec()
}

impl From<(String, Option<String>)> for WarehouseEnv {
    fn from((endpoint, country): (String, Option<String>)) -> Self {
        WarehouseEnv { endpoint, country }
    }
}

#[derive(Clone)]
pub(crate) struct WarehouseEnv {
    pub(crate) endpoint: String,
    pub(crate) country: Option<String>,
}
