use std::collections::HashMap;

use serde::Serialize;
use yfunc_rust::prelude::*;

use super::FishType;

#[derive(Serialize, Debug)]
pub struct Statistics {
    pub count__active: i32,
    pub count__expired: i32,
    pub count__by_type: HashMap<FishType, i32>,
    pub count__by_tag: HashMap<String, i32>,
    pub count__marked: i32,
    pub count__unmarked: i32,
    pub count__locked: i32,
    pub count__unlocked: i32,
    pub count__by_day: HashMap<String, i32>,
}

impl Statistics {

    pub fn to_json(&self, pretty: bool) -> YRes<String> {
        if pretty {
            serde_json::to_string_pretty(self).map_err(|e|
                err!(ParseError::"parse statistics to pretty json string", e)
            )
        } else {
            serde_json::to_string(self).map_err(|e|
                err!(ParseError::"parse statistics to json string", e)
            )
        }
    }

}

