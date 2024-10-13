use yfunc_rust::{Page, YBytes, YRes};

use crate::{FishType, ExtraInfo, Fish};

pub trait FishStorage {

    fn add_fish(
        &self, identity: String, length: i32, duplicate_count: i32, fish_type: FishType,
        preview: Option<YBytes>, data: Option<YBytes>, description: String,
        tags: Vec<String>, is_marked: bool, is_locked: bool, extra_info: ExtraInfo,
    ) -> YRes<Fish>;

    fn page_fish(
        &self, identity: Option<String>, length: Option<i32>, duplicate_count: Option<i32>,
        fish_type: Option<Vec<FishType>>, preview: Option<Option<YBytes>>,
        data: Option<Option<YBytes>>, description: Option<String>, tags: Option<Vec<String>>,
        is_marked: Option<bool>, is_locked: Option<bool>, page_num: i32, page_size: i32,
    ) -> YRes<Page<Fish>>;

}