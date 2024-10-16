mod core;
mod domain;
mod infra;
mod service;

pub use core::TouchFishCore;
pub use domain::*;
pub use infra::FishStorage;
pub use service::FishService;
