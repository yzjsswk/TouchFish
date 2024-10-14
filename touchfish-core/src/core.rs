use std::rc::Rc;

use yfunc_rust::{Page, YBytes, YRes};

use crate::{Fish, FishService, FishStorage, FishType};

pub struct TouchFishCore<S> where S: FishStorage {
    fish_service: FishService<S>,
}

impl<S> TouchFishCore<S> where S: FishStorage {

    pub fn new(storage: Rc<S>) -> YRes<TouchFishCore<S>> {
        Ok(TouchFishCore {
            fish_service: FishService::new(storage.clone()),
        })
    }

    pub fn add_fish(
        &self, fish_type: FishType, fish_data: YBytes, description: Option<String>,
        tags: Option<Vec<String>>, is_marked: Option<bool>, is_locked: Option<bool>,
    ) -> YRes<Fish> {
        self.fish_service.add_fish(fish_type, fish_data, description, tags, is_marked, is_locked)
    }

    pub fn search_fish(
        &self, fuzzy: Option<String>, identity: Option<Vec<String>>, 
        fish_type: Option<Vec<FishType>>, desc: Option<String>,
        tags: Option<Vec<String>>, is_marked: Option<bool>, is_locked: Option<bool>, 
        page_num: Option<i32>, page_size: Option<i32>,
    ) -> YRes<Page<Fish>> {
        self.fish_service.search_fish(fuzzy, identity, fish_type, desc, tags, is_marked, is_locked, page_num, page_size)
    }

    pub fn expire_fish(&self, identity: String) -> YRes<()> {
        self.fish_service.expire_fish(identity)
    }

}