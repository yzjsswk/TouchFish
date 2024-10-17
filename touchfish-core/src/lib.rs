#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]

mod core;
mod domain;
mod infra;
mod service;

pub use core::TouchFishCore;
pub use domain::*;
pub use infra::FishStorage;
pub use service::FishService;
