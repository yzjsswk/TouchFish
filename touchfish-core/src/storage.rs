use yfunc_rust::{Page, YBytes, YRes};

use crate::{FishType, ExtraInfo, Fish};

pub trait FishStorage {

    fn add_fish(
        &self, identity: String, count: i32, fish_type: FishType, fish_data: YBytes,
        desc: String, tags: Vec<String>, is_marked: bool, is_locked: bool, extra_info: ExtraInfo,
    ) -> YRes<Fish>;

    fn page_fish(
        &self, fuzzy: Option<String>, identity: Option<Vec<String>>, count: Option<i32>,
        fish_type: Option<Vec<FishType>>, fish_data: Option<YBytes>, desc: Option<String>,
        tags: Option<Vec<String>>, is_marked: Option<bool>, is_locked: Option<bool>,
        page_num: i32, page_size: i32,
    ) -> YRes<Page<Fish>>;

}