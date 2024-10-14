use diesel::dsl::sql;
use diesel::prelude::*;
use diesel::result::Error;
use diesel::sql_types::{Bool, Text};
use diesel::{r2d2::ConnectionManager, SqliteConnection};
use r2d2::Pool;
use touchfish_core::{Fish, FishStorage};
use yfunc_rust::{Page, prelude::*};

use crate::model::{FishExpiredInserter, FishExpiredModel, FishInserter, FishModel, FishPager, FishUpdater};
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

    pub fn fish__insert(&self, conn: &mut SqliteConnection, inserter: &FishInserter) -> Result<FishModel, Error> {
        let inserted = diesel::insert_into(fish::table)
            .values(inserter)
            .returning(FishModel::as_returning())
            .get_result(conn)?;
        Ok(inserted)
    }

    pub fn fish__delete(&self, conn: &mut SqliteConnection, id: i32) -> Result<usize, Error> {
        let cnt = diesel::delete(fish::table.filter(fish::id.eq(id))).execute(conn)?;
        Ok(cnt)
    }

    pub fn fish__pick(&self, conn: &mut SqliteConnection, identity: &str) -> Result<Vec<FishModel>, Error> {
        let selected: Vec<FishModel> = fish::dsl::fish
            .filter(fish::identity.eq(identity))
            .select(FishModel::as_select())
            .load(conn)?;
        Ok(selected)
    }

    pub fn fish__page(&self, conn: &mut SqliteConnection, pager: &FishPager) -> Result<Vec<FishModel>, Error> {
        let mut query = fish::dsl::fish.into_boxed();
        if let Some(fuzzy) = &pager.fuzzy {
            query = query.filter(fish::desc.like(fuzzy).or(sql::<Bool>("fish_data LIKE ").bind::<Text, _>(fuzzy)))
        }
        if let Some(identity) = &pager.identity {
            query = query.filter(fish::identity.eq_any(identity));
        }
        if let Some(count) = pager.count {
            query = query.filter(fish::count.eq(count));
        }
        if let Some(fish_type) = &pager.fish_type {
            query = query.filter(fish::fish_type.eq_any(fish_type));
        }
        if let Some(desc) = &pager.desc {
            query = query.filter(fish::desc.like(desc));
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
        // println!("{}", diesel::debug_query::<diesel::sqlite::Sqlite, _>(&query));
        let selected: Vec<FishModel> = query
            .select(FishModel::as_select())
            .load(conn)?;
        Ok(selected)
    }

    pub fn fish__count(&self, conn: &mut SqliteConnection, pager: &FishPager) -> Result<i64, Error> {
        let mut query = fish::dsl::fish.into_boxed();
        if let Some(fuzzy) = &pager.fuzzy {
            query = query.filter(fish::desc.like(fuzzy).or(sql::<Bool>("fish_data LIKE ").bind::<Text, _>(fuzzy)))
        }
        if let Some(identity) = &pager.identity {
            query = query.filter(fish::identity.eq_any(identity));
        }
        if let Some(count) = pager.count {
            query = query.filter(fish::count.eq(count));
        }
        if let Some(fish_type) = &pager.fish_type {
            query = query.filter(fish::fish_type.eq_any(fish_type));
        }
        if let Some(desc) = &pager.desc {
            query = query.filter(fish::desc.like(desc));
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
        let cnt: i64 = query
            .count()
            .get_result(conn)?;
        Ok(cnt)
    }

    pub fn fish_expired__insert(&self, conn: &mut SqliteConnection, inserter: &FishExpiredInserter) -> Result<FishExpiredModel, Error> {
        let inserted = diesel::insert_into(fish_expired::table)
            .values(inserter)
            .returning(FishExpiredModel::as_returning())
            .get_result(conn)?;
        Ok(inserted)
    }

}

impl FishStorage for SqliteStorage {

    fn add_fish(
        &self, identity: String, count: i32, fish_type: touchfish_core::FishType, fish_data: yfunc_rust::YBytes,
        desc: String, tags: Vec<String>, is_marked: bool, is_locked: bool, extra_info: touchfish_core::ExtraInfo,
    ) -> YRes<Fish> {
        let mut conn = self.pool.get().map_err(
            |e| err!(DataBaseError::"add fish": "fetch connection from pool failed", e),
        )?;
        let fish = self.fish__insert(&mut conn, &FishInserter::new(
            identity, count, fish_type, fish_data, desc, tags, is_marked, is_locked, extra_info
        )?).map_err(|e| err!(DataBaseError::"add fish", e))?;
        Ok(Fish::try_from(fish)?)
    }

    fn expire_fish(&self, identity: String) -> YRes<()> {
        let mut conn = self.pool.get().map_err(
            |e| err!(DataBaseError::"expire fish": "fetch connection from pool failed", e),
        )?;
        let to_expire_fish = self.fish__pick(&mut conn, &identity).map_err(|e| 
            err!(DataBaseError::"expire fish": "query to delete fish failed", identity, e)
        )?;
        if to_expire_fish.is_empty() {
            return Err(err!(DataBaseError::"expire fish": "too delete fish not exist", identity));
        }
        if to_expire_fish.len() > 1 {
            return Err(err!(DataBaseError::"expire fish": "too delete fish more than one", identity));
        }
        let to_expire_fish = to_expire_fish.into_iter().next().unwrap();
        let to_expire_fish_id = to_expire_fish.id;
        let expired_fish_inserter = FishExpiredInserter::new(to_expire_fish)?;
        conn.transaction::<_, Error, _>(|conn| {
            let cnt = self.fish__delete(conn, to_expire_fish_id)?;
            if cnt != 1 {
                return Err(Error::RollbackTransaction)
            }
            self.fish_expired__insert(conn, &expired_fish_inserter)?;
            Ok(())
        }).map_err(|e| err!(DataBaseError::"expire fish": "execute transaction failed", e))
    }

    fn page_fish(
        &self, fuzzy: Option<String>, identity: Option<Vec<String>>, count: Option<i32>,
        fish_type: Option<Vec<touchfish_core::FishType>>, fish_data: Option<yfunc_rust::YBytes>, desc: Option<String>,
        tags: Option<Vec<String>>, is_marked: Option<bool>, is_locked: Option<bool>,
        page_num: i32, page_size: i32,
    ) -> YRes<Page<Fish>> {
        let mut conn = self.pool.get().map_err(
            |e| err!(DataBaseError::"page fish": "fetch connection from pool failed", e),
        )?;
        let pager = FishPager::new(
            fuzzy, identity, count, fish_type, fish_data, 
            desc, tags, is_marked, is_locked, page_num, page_size
        )?;
        let total_count = self.fish__count(&mut conn, &pager)
            .map_err(|e| err!(DataBaseError::"page fish", e))?;
        let fish_list = self.fish__page(&mut conn, &pager)
            .map_err(|e| err!(DataBaseError::"page fish", e))?;
        let data = fish_list
            .into_iter()
            .map(|x| Fish::try_from(x))
            .collect::<YRes<Vec<_>>>()?;
        Ok(Page { total_count, page_num, page_size, data })
    }

}

