use std::rc::Rc;

use yfunc_rust::{prelude::*, Page, Unique, YBytes};

use crate::{DataInfo, Fish, FishStorage, FishType};

const FISH_DATA_LEN_LIMIT: usize = 10485760;

pub struct FishService<S> where S: FishStorage {
    storage: Rc<S>,
}

impl<S> FishService<S> where S: FishStorage {

    pub fn new(storage: Rc<S>) -> FishService<S> {
        FishService { storage }
    }

    pub fn add_fish(
        &self, fish_type: FishType, fish_data: YBytes, desc: Option<String>, tags: Option<Vec<String>>,
        is_marked: Option<bool>, is_locked: Option<bool>, extra_info: Option<String>,
    ) -> YRes<Fish> {
        if fish_data.length() > FISH_DATA_LEN_LIMIT {
            return Err(err!(BusinessError::"add fish": "fish data too long", fish_data.length(), FISH_DATA_LEN_LIMIT))
        }
        let desc = desc.unwrap_or("".to_string());
        let extra_info = extra_info.unwrap_or("".to_string());
        let tags = match tags {
            Some(x) => {
                let mut t = x.unique();
                t.sort();
                t
            },
            None => vec![],
        };
        let is_marked = is_marked.unwrap_or(false);
        let is_locked = is_locked.unwrap_or(false);
        let mut data_info = DataInfo::new();
        data_info.byte_count = Some(fish_data.length());
        match fish_type {
            FishType::Text => {
                let s= fish_data.to_str().trace(
                    ctx!("add text fish": "parse fish_data to string failed")
                )?;
                data_info.char_count = Some(s.len());
                data_info.word_count = Some(s.split_whitespace().collect::<Vec<_>>().len());
                data_info.row_count = Some(s.split('\n').collect::<Vec<_>>().len());
            },
            FishType::Image => {},
        };
        self.storage.add_fish(
            fish_data.md5(), 1, fish_type, fish_data, data_info, desc, tags, is_marked, is_locked, extra_info,
        )
    }

    pub fn search_fish(
        &self, fuzzy: Option<String>, identity: Option<Vec<String>>, 
        fish_type: Option<Vec<FishType>>, desc: Option<String>,
        tags: Option<Vec<String>>, is_marked: Option<bool>, is_locked: Option<bool>, 
        page_num: Option<i32>, page_size: Option<i32>,
    ) -> YRes<Page<Fish>> {
        self.storage.page_fish(
            fuzzy, identity, None, fish_type, None, desc, tags, is_marked, is_locked,
            page_num.unwrap_or(1), page_size.unwrap_or(10),
        )
    }

    pub fn expire_fish(&self, identity: String) -> YRes<()> {
        self.storage.expire_fish(identity)
    }

}

