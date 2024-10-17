use diesel::{sql_types::{Integer, Text}, QueryableByName};
use serde::Deserialize;

#[derive(QueryableByName, Debug, Deserialize)]
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
pub struct CountByTag {
    #[diesel(sql_type = Text)]
    pub tag: String,
    #[diesel(sql_type = Integer)]
    pub count: i32,
}

#[derive(QueryableByName, Debug, Deserialize)]
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
pub struct CountByType {
    #[diesel(sql_type = Text)]
    pub fish_type: String,
    #[diesel(sql_type = Integer)]
    pub count: i32,
}

#[derive(QueryableByName, Debug, Deserialize)]
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
pub struct CountByDay {
    #[diesel(sql_type = Text)]
    pub day: String,
    #[diesel(sql_type = Integer)]
    pub count: i32,
}
