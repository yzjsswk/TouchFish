use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumString};
use yfunc_rust::{YBytes, YTime, prelude::*};

#[derive(Serialize, Debug)]
pub struct Fish {
    pub identity: String,
    pub length: i32,
    pub duplicate_count: i32,
    pub fish_type: FishType,
    pub preview: Option<YBytes>,
    pub data: Option<YBytes>,
    pub description: String,
    pub tags: Vec<String>,
    pub is_marked: bool,
    pub is_locked: bool,
    pub extra_info: ExtraInfo,
    pub create_time: YTime,
    pub update_time: YTime,
}

impl Fish {

    pub fn to_json_string(&self) -> YRes<String> {
        serde_json::to_string(self).map_err(|e|
            err!(ParseError::"parse fish to json string", e)
        )
    }

}

#[derive(Serialize, Debug, EnumString, Display, PartialEq, Eq, Hash, Clone, Copy)]
pub enum FishType {
    Text,
    Image,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ExtraInfo {
    // Text
    #[serde(skip_serializing_if = "Option::is_none")]
    pub char_count: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub word_count: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub row_count: Option<usize>,
    // Image
    #[serde(skip_serializing_if = "Option::is_none")]
    pub width: Option<usize>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub height: Option<usize>,
}

impl ExtraInfo {

    pub fn new() -> ExtraInfo {
        ExtraInfo { 
            char_count: None, word_count: None, row_count: None, width: None, height: None,
        }
    }

}
