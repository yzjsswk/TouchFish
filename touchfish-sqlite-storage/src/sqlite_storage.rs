use diesel::prelude::*;
use diesel::{r2d2::ConnectionManager, SqliteConnection};
use r2d2::Pool;
use touchfish_core::{Fish, FishStorage};
use yfunc_rust::{ctx, err, Page, YError, YRes};

use crate::model::{FishInserter, FishModel, FishPager, FishUpdater};
use crate::schema::{fish, fish_expired};

pub struct SqliteStorage {
    pool: Pool<ConnectionManager<SqliteConnection>>,
}

impl SqliteStorage {

    pub fn connect(db_url: &str) -> YRes<Self> {
        let manager = ConnectionManager::<SqliteConnection>::new(db_url);
        let pool = r2d2::Pool::builder()
            .build(manager)
            .map_err(|err| err!(DataBaseError::"connect to sqlite": "build connection pool failed", db_url, err))?;
        Ok(SqliteStorage { pool })
    }

    pub fn fish__insert(&self, inserter: &FishInserter) -> YRes<Fish> {
        let mut conn = self.pool.get().map_err(
            |err| err!(DataBaseError::"insert fish": "fetch connection from pool failed", err),
        )?;
        let inserted = diesel::insert_into(fish::table)
            .values(inserter)
            .returning(FishModel::as_returning())
            .get_result(&mut conn)
            .map_err(|err| err!(DataBaseError::"insert fish", err))?;
        Ok(Fish::try_from(inserted)?)
    }

    pub fn fish__page(&self, pager: &FishPager) -> YRes<Vec<Fish>> {
        let mut conn = self.pool.get().map_err(
            |err| err!(DataBaseError::"page fish": "fetch connection from pool failed", err),
        )?;
        let mut query = fish::dsl::fish.into_boxed();
        if let Some(identity) = &pager.identity {
            query = query.filter(fish::identity.eq(identity));
        }
        if let Some(length) = pager.length {
            query = query.filter(fish::length.eq(length));
        }
        if let Some(duplicate_count) = pager.duplicate_count {
            query = query.filter(fish::duplicate_count.eq(duplicate_count));
        }
        if let Some(fish_type) = &pager.fish_type {
            query = query.filter(fish::fish_type.eq_any(fish_type));
        }
        if let Some(desc) = &pager.description {
            query = query.filter(fish::fish_type.like(desc));
        }
        if let Some(tags) = &pager.tags {
            query = query.filter(fish::tags.like(tags));
        }
        if let Some(is_marked) = pager.is_marked {
            query = query.filter(fish::is_marked.eq(is_marked));
        }
        if let Some(is_locked) = pager.is_locked {
            query = query.filter(fish::is_locked.eq(is_locked));
        }
        query = query.limit(pager.limit);
        query = query.offset(pager.offset);
        let selected: Vec<FishModel> = query
            .select(FishModel::as_select())
            .load(&mut conn)
            .map_err(|err| err!(DataBaseError::"page fish", err))?;
        let res = selected
            .into_iter()
            .map(|x| Fish::try_from(x))
            .collect::<YRes<Vec<_>>>()?;
        Ok(res)
    }

    pub fn fish__count(&self, pager: &FishPager) -> YRes<i64> {
        let mut conn = self.pool.get().map_err(
            |err| err!(DataBaseError::"page fish": "fetch connection from pool failed", err),
        )?;
        let mut query = fish::dsl::fish.into_boxed();
        if let Some(identity) = &pager.identity {
            query = query.filter(fish::identity.eq(identity));
        }
        if let Some(length) = pager.length {
            query = query.filter(fish::length.eq(length));
        }
        if let Some(duplicate_count) = pager.duplicate_count {
            query = query.filter(fish::duplicate_count.eq(duplicate_count));
        }
        if let Some(fish_type) = &pager.fish_type {
            query = query.filter(fish::fish_type.eq_any(fish_type));
        }
        if let Some(desc) = &pager.description {
            query = query.filter(fish::fish_type.like(desc));
        }
        if let Some(tags) = &pager.tags {
            query = query.filter(fish::tags.like(tags));
        }
        if let Some(is_marked) = pager.is_marked {
            query = query.filter(fish::is_marked.eq(is_marked));
        }
        if let Some(is_locked) = pager.is_locked {
            query = query.filter(fish::is_locked.eq(is_locked));
        }
        query = query.limit(pager.limit);
        query = query.offset(pager.offset);
        let cnt: i64 = query
            .count()
            .get_result(&mut conn)
            .map_err(|err| err!(DataBaseError::"count fish", err))?;
        Ok(cnt)
    }

}

impl FishStorage for SqliteStorage {

    fn add_fish(
        &self, identity: String, length: i32, duplicate_count: i32, fish_type: touchfish_core::FishType,
        preview: Option<yfunc_rust::YBytes>, data: Option<yfunc_rust::YBytes>, description: String,
        tags: Vec<String>, is_marked: bool, is_locked: bool, extra_info: touchfish_core::ExtraInfo,
    ) -> YRes<Fish> {
        let fish = self.fish__insert(&FishInserter::new(
            identity, length, duplicate_count, fish_type, 
            preview, data, description, tags, is_marked, is_locked, extra_info
        )?)?;
        Ok(fish)
    }

    fn page_fish(
        &self, identity: Option<String>, length: Option<i32>, duplicate_count: Option<i32>,
        fish_type: Option<Vec<touchfish_core::FishType>>, preview: Option<Option<yfunc_rust::YBytes>>,
        data: Option<Option<yfunc_rust::YBytes>>, description: Option<String>, tags: Option<Vec<String>>,
        is_marked: Option<bool>, is_locked: Option<bool>, page_num: i32, page_size: i32,
    ) -> YRes<Page<Fish>> {
        let pager = FishPager::new(
            identity, length, duplicate_count, fish_type, preview, data, 
            description, tags, is_marked, is_locked, page_num, page_size
        )?;
        let total_count = self.fish__count(&pager)?;
        let fish_list = self.fish__page(&pager)?;
        Ok(Page {
            total_count,
            page_num,
            page_size,
            data: fish_list,
        })
    }

}

