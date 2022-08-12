use std::env::vars;

use itertools::Itertools;
use lazy_static::lazy_static;
use regex::Regex;

lazy_static! {
    static ref WAREHOUSE_REGEXP: Regex = Regex::new(r"^WAREHOUSE__\d__.*").unwrap();
}

pub(crate) fn get_warehouse_endpoints() -> Vec<WarehouseEnv> {
    vars()
        .filter(|(key, _)| WAREHOUSE_REGEXP.find(key.as_str()).is_some())
        .group_by(|(key, _)| key.split("__").nth(1).unwrap().to_string())
        .into_iter()
        .map(|(_, mut group)| {
            let endpoint = group.find(|item| item.0.ends_with("ENDPOINT")).unwrap().1;
            let some_country = group.find(|item| item.0.ends_with("COUNTRY"));
            match some_country {
                Some((_, country)) => WarehouseEnv {
                    endpoint,
                    country: Some(country),
                },
                None => WarehouseEnv {
                    endpoint,
                    country: None,
                },
            }
        })
        .collect::<Vec<WarehouseEnv>>()
}

pub(crate) struct WarehouseEnv {
    pub(crate) endpoint: String,
    pub(crate) country: Option<String>,
}
