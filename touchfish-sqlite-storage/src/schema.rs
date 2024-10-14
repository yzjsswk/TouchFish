// @generated automatically by Diesel CLI.

diesel::table! {
    fish (id) {
        id -> Integer,
        identity -> Text,
        count -> Integer,
        fish_type -> Text,
        fish_data -> Binary,
        data_info -> Text,
        desc -> Text,
        tags -> Text,
        is_marked -> Bool,
        is_locked -> Bool,
        extra_info -> Text,
        create_time -> Text,
        update_time -> Text,
    }
}

diesel::table! {
    fish_expired (id) {
        id -> Integer,
        identity -> Text,
        count -> Integer,
        fish_type -> Text,
        fish_data -> Binary,
        data_info -> Text,
        desc -> Text,
        tags -> Text,
        is_marked -> Bool,
        is_locked -> Bool,
        extra_info -> Text,
        create_time -> Text,
        update_time -> Text,
        expire_time -> Text,
    }
}

diesel::allow_tables_to_appear_in_same_query!(
    fish,
    fish_expired,
);
