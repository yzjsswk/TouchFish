use std::rc::Rc;

use yfunc_rust::{Unique, YBytes, prelude::*};

use crate::{ExtraInfo, Fish, FishStorage, FishType};

const FISH_DATA_LEN_LIMIT: usize = 10485760;

pub struct FishService<S> where S: FishStorage {
    storage: Rc<S>,
}

impl<S> FishService<S> where S: FishStorage {

    pub fn new(storage: Rc<S>) -> FishService<S> {
        FishService { storage }
    }

    pub fn add_fish(
        &self, fish_type: FishType, fish_data: YBytes, description: Option<String>,
        tags: Option<Vec<String>>, is_marked: Option<bool>, is_locked: Option<bool>,
    ) -> YRes<Fish> {
        if fish_data.length() > FISH_DATA_LEN_LIMIT {
            return Err(err!(BusinessError::"add fish": "fish data too long", fish_data.length(), FISH_DATA_LEN_LIMIT))
        }
        let description = description.unwrap_or("".to_string());
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
        let (preview, extra_info): (Option<YBytes>, ExtraInfo) = match fish_type {
            FishType::Text => {
                let mut extra_info = ExtraInfo::new();
                let s= fish_data.to_str().trace(
                    ctx!("add text fish": "parse fish_data to string failed")
                )?;
                extra_info.char_count = Some(s.len());
                extra_info.word_count = Some(s.split_whitespace().collect::<Vec<_>>().len());
                extra_info.row_count = Some(s.split('\n').collect::<Vec<_>>().len());
                (Some(fish_data.clone()), extra_info)
            },
            FishType::Image => (None, ExtraInfo::new()),
        };
        self.storage.add_fish(
            fish_data.md5(), fish_data.length() as i32, 1, fish_type, 
            preview, Some(fish_data), description, tags, is_marked, is_locked, extra_info,
        )
    }

}

