use std::str::FromStr;

use diesel::prelude::*;
use touchfish_core::{FishType, ExtraInfo, Fish};
use yfunc_rust::{ctx, err, Trace, Unique, YBytes, YError, YRes, YTime};

use crate::schema;

#[derive(Queryable, Selectable)]
#[diesel(table_name = schema::fish)]
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
#[derive(Debug, Clone)]
pub struct FishModel {
    pub id: i32,
    pub identity: String,
    pub length: i32,
    pub duplicate_count: i32,
    pub fish_type: String,
    pub preview: Option<Vec<u8>>,
    pub data: Option<Vec<u8>>,
    pub description: String,
    pub tags: String,
    pub is_marked: bool,
    pub is_locked: bool,
    pub extra_info: String,
    pub create_time: String,
    pub update_time: String,
}

impl TryFrom<FishModel> for Fish {

    type Error = YError;

    fn try_from(model: FishModel) -> YRes<Self> {
        let fish_type = FishType::from_str(&model.fish_type).map_err(|err|
            err!(ParseError::"try from FishModel to Fish": "parse fish_type failed", model.fish_type, model.id, err)
        )?;
        let preview = match model.preview {
            Some(x) => Some(YBytes::new(x)),
            None => None,
        };
        let data = match model.data {
            Some(x) => Some(YBytes::new(x)),
            None => None,
        };
        let tags = if model.tags.len() > 0 {
            model.tags.split(',').map(String::from).collect()
        } else {
            vec![]
        };
        let extra_info: ExtraInfo = serde_json::from_str(&model.extra_info).map_err(|err|
            err!(ParseError::"try from FishModel to Fish": "parse extra_info failed", model.extra_info, model.id, err)
        )?;
        let create_time = YTime::from_str(&model.create_time).trace(
            ctx!("try from FishModel to Fish": "parse create_time failed", model.create_time, model.id)
        )?;
        let update_time = YTime::from_str(&model.update_time).trace(
            ctx!("try from FishModel to Fish": "parse update_time failed", model.update_time, model.id)
        )?;
        Ok(Fish {
            identity: model.identity, length: model.length, duplicate_count: model.duplicate_count,
            fish_type, preview, data, description: model.description, tags, is_marked: model.is_marked,
            is_locked: model.is_locked, extra_info, create_time, update_time,
        })
    }

}

#[derive(Insertable)]
#[diesel(table_name = schema::fish)]
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
#[derive(Debug)]
pub struct FishInserter {
    pub identity: String,
    pub length: i32,
    pub duplicate_count: i32,
    pub fish_type: String,
    pub preview: Option<Vec<u8>>,
    pub data: Option<Vec<u8>>,
    pub description: String,
    pub tags: String,
    pub is_marked: bool,
    pub is_locked: bool,
    pub extra_info: String,
    pub create_time: String,
    pub update_time: String,
}

impl FishInserter {

    pub fn new(
        identity: String, length: i32, duplicate_count: i32, fish_type: FishType,
        preview: Option<YBytes>, data: Option<YBytes>, description: String, tags: Vec<String>,
        is_marked: bool, is_locked: bool, extra_info: ExtraInfo,
    ) -> YRes<FishInserter> {
        let fish_type = fish_type.to_string();
        let preview = preview.map(|x| x.into_vec());
        let data = data.map(|x| x.into_vec());
        let mut tags = tags.unique();
        tags.sort();
        let tags = tags.join(",");
        let extra_info = serde_json::to_string(&extra_info).map_err(
            |_| err!(ParseError::"build fish inserter", "parse extra_info to string failed"),
        )?;
        let create_time = YTime::now().to_str();
        let update_time = YTime::now().to_str();
        Ok(FishInserter {
            identity, length, duplicate_count,
            fish_type, preview, data, description,
            tags, is_marked, is_locked, extra_info,
            create_time, update_time,
        })
    }

}

#[derive(AsChangeset)]
#[diesel(table_name = schema::fish)]
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
#[derive(Debug)]
pub struct FishUpdater {
    pub identity: Option<String>,
    pub length: Option<i32>,
    pub duplicate_count: Option<i32>,
    pub fish_type: Option<String>,
    pub preview: Option<Option<Vec<u8>>>,
    pub data: Option<Option<Vec<u8>>>,
    pub description: Option<String>,
    pub tags: Option<String>,
    pub is_marked: Option<bool>,
    pub is_locked: Option<bool>,
    pub extra_info: Option<String>,
    pub update_time: String,
}

impl FishUpdater {

    pub fn new(
        identity: Option<String>, length: Option<i32>, duplicate_count: Option<i32>,
        fish_type: Option<FishType>, preview: Option<Option<YBytes>>,
        data: Option<Option<YBytes>>, description: Option<String>, tags: Option<Vec<String>>,
        is_marked: Option<bool>, is_locked: Option<bool>, extra_info: Option<ExtraInfo>,
    ) -> YRes<FishUpdater> {
        let fish_type = match fish_type {
            Some(x) => Some(x.to_string()),
            None => None,
        };
        let preview = preview.map(|x| x.map(|y| y.into_vec()));
        let data = data.map(|x| x.map(|y| y.into_vec()));
        let tags = match tags {
            Some(x) => {
                let mut x = x.unique();
                x.sort();
                Some(x.join(","))
            }
            None => None,
        };
        let extra_info = match extra_info {
            Some(x) => Some(serde_json::to_string(&x).map_err(
                |_| err!(ParseError::"build fish updater", "parse extra_info to string failed"),
            )?),
            None => None,
        };
        let update_time = YTime::now().to_str();
        Ok(FishUpdater {
            identity, length, duplicate_count, fish_type,
            preview, data, description, tags, is_marked,
            is_locked, extra_info, update_time,
        })
    }

}

pub struct FishPager {
    pub identity: Option<String>,
    pub length: Option<i32>,
    pub duplicate_count: Option<i32>,
    pub fish_type: Option<Vec<String>>,
    pub preview: Option<Option<Vec<u8>>>,
    pub data: Option<Option<Vec<u8>>>,
    pub description: Option<String>,
    pub tags: Option<String>,
    pub is_marked: Option<bool>,
    pub is_locked: Option<bool>,
    pub limit: i64,
    pub offset: i64,
}

impl FishPager {
    
    pub fn new(
        identity: Option<String>, length: Option<i32>, duplicate_count: Option<i32>,
        fish_type: Option<Vec<FishType>>, preview: Option<Option<YBytes>>,
        data: Option<Option<YBytes>>, description: Option<String>, tags: Option<Vec<String>>,
        is_marked: Option<bool>, is_locked: Option<bool>, page_num: i32, page_size: i32,
    ) -> YRes<FishPager> {
        let fish_type = match fish_type {
            Some(x) => Some(x.into_iter().map(|x| x.to_string()).collect()),
            None => None,
        };
        let preview = preview.map(|x| x.map(|y| y.into_vec()));
        let data = data.map(|x| x.map(|y| y.into_vec()));
        let description = match description {
            Some(x) => Some(format!("%{}%", x)),
            None => None,
        };
        let tags = match tags {
            Some(x) => {
                if x.is_empty() {
                    Some("".to_string())
                } else {
                    let mut x = x.unique();
                    x.sort();
                    let keyword = x.join("%");
                    Some(format!("%{}%", keyword))
                }
            }
            None => None,
        };
        let limit = page_num.into();
        let offset = ((page_num-1) * page_size).into();
        Ok(FishPager {
            identity, length, duplicate_count, fish_type,
            preview, data, description, tags, is_marked,
            is_locked, limit, offset,
        })
    }

}

