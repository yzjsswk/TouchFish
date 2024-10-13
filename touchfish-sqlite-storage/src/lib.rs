#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]

mod model;
mod schema;
mod sqlite_storage;

#[cfg(test)]
mod tests {

    use model::{FishInserter, FishPager};
    use sqlite_storage::SqliteStorage;
    use touchfish_core::{FishType, ExtraInfo};
    use yfunc_rust::YRes;

    use super::*;

    #[test]
    fn insert_fish() -> YRes<()> {
       let storage = SqliteStorage::connect("/Users/yzjsswk/WorkSpace/touchfish.db")?;
       let res = storage.fish__insert(FishInserter::new(
        "123".to_string(), 1, 1, FishType::Text, None, None, "desc".to_string(), vec![], false, false, ExtraInfo{}
        )?)?;
        println!("{:?}", res);
        Ok(())
    }

    #[test]
    fn search_fish() -> YRes<()> {
        let storage = SqliteStorage::connect("/Users/yzjsswk/WorkSpace/touchfish.db")?;
        let res = storage.fish__page(FishPager {
            identity: None,
            length: None,
            duplicate_count: None,
            fish_type: None,
            preview: None,
            data: None,
            description: None,
            tags: None,
            is_marked: None,
            is_locked: None,
            limit: 10,
            offset: 0,
        })?;
        println!("{:?}", res);
        Ok(())
    }

}