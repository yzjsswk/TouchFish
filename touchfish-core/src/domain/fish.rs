use std::str::FromStr;

use serde::{Deserialize, Serialize};
use serde_with::skip_serializing_none;
use strum_macros::{Display, EnumString};
use yfunc_rust::{YBytes, YTime, prelude::*};

#[derive(Serialize, Debug)]
pub struct Fish {
    pub identity: String,
    pub count: i32,
    pub fish_type: FishType,
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

    pub fn json_with_data(&self) -> YRes<String> {
        serde_json::to_string(self).map_err(|e|
            err!(ParseError::"parse fish to json string", e)
        )
    }

    pub fn json_with_preview(&self) -> YRes<String> {
        serde_json::to_string_pretty(&FishPreview::from_fish(self)?).map_err(|e|
            err!(ParseError::"parse fish preview to json string", e)
        )
    }

}

#[derive(Serialize, Debug)]
pub struct FishPreview {
    pub identity: String,
    pub count: i32,
    pub fish_type: FishType,
    pub data_preview: Option<String>,
    pub data_info: DataInfo,
    pub desc: String,
    pub tags: Vec<String>,
    pub is_marked: bool,
    pub is_locked: bool,
    pub extra_info: String,
    pub create_time: String,
    pub update_time: String,
}

impl FishPreview {

    pub fn from_fish(fish: &Fish) -> YRes<FishPreview> {
        let data_preview = match fish.fish_type {
            FishType::Text => {
                let preview = fish.fish_data.to_str()?;
                Some(preview.chars().take(80).collect())
            },
            _ => None,
        };
        let create_time = fish.create_time.east8();
        let update_time = fish.update_time.east8();
        Ok(FishPreview { 
            identity: fish.identity.clone(), count: fish.count, fish_type: fish.fish_type,
            data_preview, data_info: fish.data_info.clone(), desc: fish.desc.clone(), tags: fish.tags.clone(),
            is_marked: fish.is_marked, is_locked: fish.is_locked, extra_info: fish.extra_info.clone(),
            create_time, update_time,
        })
    }

}

#[derive(Serialize, Deserialize, Debug, EnumString, Display, PartialEq, Eq, Hash, Clone, Copy)]
pub enum FishType {
    Text,
    Image,
    Other,
}

impl FishType {

    pub fn new(s: &str) -> YRes<FishType> {
        FishType::from_str(s).map_err(|e|
            err!(ParseError::"build FishType from str", s, e)
        )
    }

}

#[skip_serializing_none]
#[derive(Serialize, Deserialize, Debug, Clone)]
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
