use std::rc::Rc;

use image::GenericImageView;
use yfunc_rust::{prelude::*, Page, Unique, YBytes};

use crate::{DataInfo, Fish, FishStorage, FishType, Statistics};

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
        let identity = fish_data.md5();
        if let Some(mut existed_fish) = self.storage.pick_fish(&identity)? {
            if fish_type != existed_fish.fish_type {
                return Err(err!(BusinessError::"add fish": "fish data exists and fish type not consistent", identity))
            }
            if let Some(desc) = &desc {
                if *desc != existed_fish.desc {
                    return Err(err!(BusinessError::"add fish": "fish data exists and desc not consistent", identity))
                }
            }
            if let Some(tags) = &tags {
                let mut tags = tags.unique();
                tags.sort();
                if tags != existed_fish.tags {
                    return Err(err!(BusinessError::"add fish": "fish data exists and tags not consistent", identity))
                }
            }
            if let Some(is_marked) = is_marked {
                if is_marked != existed_fish.is_marked {
                    return Err(err!(BusinessError::"add fish": "fish data exists and is_marked not consistent", identity))
                }
            }
            if let Some(is_locked) = is_locked {
                if is_locked != existed_fish.is_locked {
                    return Err(err!(BusinessError::"add fish": "fish data exists and is_locked not consistent", identity))
                }
            }
            if let Some(extra_info) = &extra_info {
                if *extra_info != existed_fish.extra_info {
                    return Err(err!(BusinessError::"add fish": "fish data exists and extra_info not consistent", identity))
                }
            }
            self.storage.increase_count(&identity)?;
            existed_fish.count += 1;
            return Ok(existed_fish)
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
            FishType::Image => {
                let m = image::load_from_memory(&fish_data.clone().into_vec()).map_err(|e|
                    err!(ParseError::"add image fish": "parse fish_data to image failed", e)
                )?;
                let (w, h) = m.dimensions();
                data_info.width = Some(w as usize);
                data_info.height = Some(h as usize);
            },
        };
        self.storage.add_fish(
            identity, 1, fish_type, fish_data, data_info, desc, tags, is_marked, is_locked, extra_info,
        )
    }

    pub fn expire_fish(&self, identity: &str) -> YRes<()> {
        let fish = self.storage.pick_fish(identity)?;
        match fish {
            None => {
                return Err(err!(BusinessError::"expire fish": "fish not exist", identity))
            },
            Some(x) => {
                if x.is_locked {
                    return Err(err!(BusinessError::"expire fish": "fish is locked", identity))
                } else {
                    self.storage.expire_fish(identity)
                }
            }
        }
    }

    pub fn modify_fish(
        &self, identity: &str, desc: Option<String>, tags: Option<Vec<String>>, extra_info: Option<String>,
    ) -> YRes<()>  {
        let fish = self.storage.pick_fish(identity)?;
        match fish {
            None => {
                return Err(err!(BusinessError::"modify fish": "fish not exist", identity))
            },
            Some(x) => {
                if x.is_locked {
                    return Err(err!(BusinessError::"modify fish": "fish is locked", identity))
                } else {
                    self.storage.modify_fish(identity, desc, tags, extra_info)
                }
            }
        }
    }

    pub fn mark_fish(&self, identity: &str) -> YRes<()> {
        let fish = self.storage.pick_fish(identity)?;
        match fish {
            None => {
                return Err(err!(BusinessError::"mark fish": "fish not exist", identity))
            },
            Some(x) => {
                if x.is_locked {
                    return Err(err!(BusinessError::"mark fish": "fish is locked", identity))
                } else {
                    self.storage.mark_fish(identity)
                }
            }
        }
    }

    pub fn unmark_fish(&self, identity: &str) -> YRes<()> {
        let fish = self.storage.pick_fish(identity)?;
        match fish {
            None => {
                return Err(err!(BusinessError::"unmark fish": "fish not exist", identity))
            },
            Some(x) => {
                if x.is_locked {
                    return Err(err!(BusinessError::"unmark fish": "fish is locked", identity))
                } else {
                    self.storage.unmark_fish(identity)
                }
            }
        }
    }

    pub fn lock_fish(&self, identity: &str) -> YRes<()> {
        let fish = self.storage.pick_fish(identity)?;
        match fish {
            None => {
                return Err(err!(BusinessError::"lock fish": "fish not exist", identity))
            },
            Some(_) => {
                self.storage.lock_fish(identity)
            }
        }
    }

    pub fn unlock_fish(&self, identity: &str) -> YRes<()> {
        let fish = self.storage.pick_fish(identity)?;
        match fish {
            None => {
                return Err(err!(BusinessError::"unlock fish": "fish not exist", identity))
            },
            Some(_) => {
                self.storage.unlock_fish(identity)
            }
        }
    }

    pub fn pin_fish(&self, identity: &str) -> YRes<()> {
        let fish = self.storage.pick_fish(identity)?;
        match fish {
            None => {
                return Err(err!(BusinessError::"pin fish": "fish not exist", identity))
            },
            Some(x) => {
                if x.is_locked {
                    return Err(err!(BusinessError::"pin fish": "fish is locked", identity))
                } else {
                    self.storage.pin_fish(identity)
                }
            }
        }
    }

    pub fn pick_fish(&self, identity: &str) -> YRes<Option<Fish>> {
        self.storage.pick_fish(identity)
    }

    pub fn search_fish(
        &self, fuzzy: Option<String>, identity: Option<Vec<String>>, 
        fish_type: Option<Vec<FishType>>, desc: Option<String>,
        tags: Option<Vec<String>>, is_marked: Option<bool>, is_locked: Option<bool>, 
        page_num: Option<i32>, page_size: Option<i32>,
    ) -> YRes<Page<Fish>> {
        self.storage.page_fish(
            fuzzy, identity, None, fish_type, desc, tags, is_marked, is_locked,
            page_num.unwrap_or(1), page_size.unwrap_or(10),
        )
    }

    pub fn detect_fish(
        &self, fuzzy: Option<String>, identity: Option<Vec<String>>, 
        fish_type: Option<Vec<FishType>>, desc: Option<String>,
        tags: Option<Vec<String>>, is_marked: Option<bool>, is_locked: Option<bool>,
    ) -> YRes<Vec<String>> {
        self.storage.detect_fish(fuzzy, identity, None, fish_type, desc, tags, is_marked, is_locked)
    }

    pub fn count_fish(&self) -> YRes<Statistics> {
        self.storage.count_fish()
    }

}

