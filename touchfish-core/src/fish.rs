use serde::{Deserialize, Serialize};
use serde_json::json;
use serde_with::skip_serializing_none;
use strum_macros::{Display, EnumString};
use yfunc_rust::{YBytes, YTime, prelude::*};

#[derive(Serialize, Debug)]
pub struct Fish {
    pub identity: String,
    pub count: i32,
    pub fish_type: FishType,
    // #[serde(skip_serializing)] 
    pub fish_data: YBytes,
    pub data_info: DataInfo,
    pub desc: String,
    pub tags: Vec<String>,
    pub is_marked: bool,
    pub is_locked: bool,
    pub extra_info: String,
    pub create_time: YTime,
    pub update_time: YTime,
}

impl Fish {

    pub fn to_json_string(&self) -> YRes<String> {
        serde_json::to_string(self).map_err(|e|
            err!(ParseError::"parse fish to json string", e)
        )
    }

    pub fn to_json_bytes(&self) -> YRes<Vec<u8>> {
        let v = json!(self);
        serde_json::to_vec(&v).map_err(|e|
            err!(ParseError::"parse fish to json bytes", e)
        )
    }

}

#[derive(Serialize, Debug, EnumString, Display, PartialEq, Eq, Hash, Clone, Copy)]
pub enum FishType {
    Text,
    Image,
}

#[skip_serializing_none]
#[derive(Serialize, Deserialize, Debug)]
pub struct DataInfo {
    pub byte_count: Option<usize>,
    // Text
    pub char_count: Option<usize>,
    pub word_count: Option<usize>,
    pub row_count: Option<usize>,
    // Image
    pub width: Option<usize>,
    pub height: Option<usize>,
}

impl DataInfo {

    pub fn new() -> DataInfo {
        DataInfo { 
            byte_count: None, 
            char_count: None, word_count: None, row_count: None,
            width: None, height: None,
        }
    }

}
