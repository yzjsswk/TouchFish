use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumString};
use yfunc_rust::{YBytes, YTime};

#[derive(Debug)]
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

#[derive(Debug, EnumString, Display, PartialEq, Eq, Hash, Clone, Copy)]
pub enum FishType {
    Text,
    Image,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ExtraInfo {

}
