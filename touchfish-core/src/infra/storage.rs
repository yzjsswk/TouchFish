use yfunc_rust::{Page, YBytes, YRes};

use crate::{DataInfo, Fish, FishType, Statistics};

pub trait FishStorage {

    fn add_fish(
        &self, identity: String, count: i32, fish_type: FishType, fish_data: YBytes, data_info: DataInfo,
        desc: String, tags: Vec<String>, is_marked: bool, is_locked: bool, extra_info: String,
    ) -> YRes<Fish>;

    fn expire_fish(&self, identity: &str) -> YRes<()>;

    fn modify_fish(
        &self, identity: &str, desc: Option<String>, tags: Option<Vec<String>>, extra_info: Option<String>,
    ) -> YRes<()>;

    fn mark_fish(&self, identity: &str) -> YRes<()>;

    fn unmark_fish(&self, identity: &str) -> YRes<()>;

    fn lock_fish(&self, identity: &str) -> YRes<()>;

    fn unlock_fish(&self, identity: &str) -> YRes<()>;

    fn pin_fish(&self, identity: &str) -> YRes<()>;

    fn increase_count(&self, identity: &str) -> YRes<()>;

    fn decrease_count(&self, identity: &str) -> YRes<()>;

    fn pick_fish(&self, identity: &str) -> YRes<Option<Fish>>;

    fn page_fish(
        &self, fuzzy: Option<String>, identity: Option<Vec<String>>, count: Option<i32>,
        fish_type: Option<Vec<FishType>>, desc: Option<String>, tags: Option<Vec<String>>, 
        is_marked: Option<bool>, is_locked: Option<bool>, page_num: i32, page_size: i32,
    ) -> YRes<Page<Fish>>;

    fn detect_fish(
        &self, fuzzy: Option<String>, identity: Option<Vec<String>>, count: Option<i32>,
        fish_type: Option<Vec<FishType>>, desc: Option<String>, tags: Option<Vec<String>>, 
        is_marked: Option<bool>, is_locked: Option<bool>,
    ) -> YRes<Vec<String>>;

    fn count_fish(&self) -> YRes<Statistics>;

}