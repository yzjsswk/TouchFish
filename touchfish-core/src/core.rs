use std::rc::Rc;

use yfunc_rust::{YBytes, YRes};

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

}