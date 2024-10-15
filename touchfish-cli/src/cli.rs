use std::str::FromStr;

use clap::{Parser, Subcommand};
use touchfish_core::{FishType, TouchFishCore};
use touchfish_sqlite_storage::SqliteStorage;
use yfunc_rust::{prelude::*, write_bytes_to_stdout, write_str_to_stdout, VariableFormat, YBytes};

#[derive(Debug, Subcommand)]
pub enum Commands {
    Add {
        fish_type: String,
        fish_data: String,
        #[arg(long = "desc")]
        desc: Option<String>,
        #[arg(long = "tags", use_value_delimiter = true)]
        tags: Option<Vec<String>>,
        #[arg(long = "mark")]
        is_marked: Option<bool>,
        #[arg(long = "lock")]
        is_locked: Option<bool>,
        #[arg(long = "extra")]
        extra_info: Option<String>,
        #[arg(short = 'f', action = clap::ArgAction::SetTrue)]
        use_file: bool,
        #[arg(short = 'b', action = clap::ArgAction::SetTrue)]
        use_binary_output: bool,
    },
    Expire {
        identity: String,
    },
    Modify {
        identity: String,
    },
    Mark {
        identity: String,
    },
    Unmark {
        identity: String,
    },
    Lock {
        identity: String,
    },
    Unlock {
        identity: String,
    },
    Pin {
        identity: String,
    },
    Search {
        #[arg(long = "fuzzy")]
        fuzzy: Option<String>,
        #[arg(long = "types", use_value_delimiter = true)]
        fish_types: Option<Vec<String>>,
        #[arg(long = "page")]
        page_num: Option<i32>,
        #[arg(long = "size")]
        page_size: Option<i32>,
    },
    Pick {
        identity: String,
    },
}

pub enum CliOutput {
    Ok,
    None,
    String(String),
    Bytes(Vec<u8>),
}

impl CliOutput {

    pub fn write_to_stdout(&self) -> YRes<()> {
        match self {
            CliOutput::Ok => write_str_to_stdout("Ok\n"),
            CliOutput::None => write_str_to_stdout("None\n"),
            CliOutput::String(s) => write_str_to_stdout(&format!("{}\n", s)),
            CliOutput::Bytes(b) => write_bytes_to_stdout(b),
        }
    }

}

#[derive(Debug, Parser)]
#[command(multicall = true)]
pub struct Cli {
    #[command(subcommand)]
    command: Commands,
}

impl Cli {

    pub fn handle(self, core: &TouchFishCore<SqliteStorage>) -> YRes<CliOutput> {
        match self.command {
            Commands::Add { 
                fish_type, fish_data, desc, 
                tags, is_marked, is_locked,
                extra_info, use_file, use_binary_output,
            } => {
                let fish_type = fish_type.Aabb();
                let fish_type = FishType::from_str(&fish_type).map_err(|e|
                    err!(ParseError::"handle add command": "parse fish_type failed", fish_type, e)
                )?;
                let fish_data: YBytes = match use_file {
                    true => {
                        YBytes::open_file(&fish_data)?
                    },
                    false => {
                        YBytes::new(fish_data.into_bytes())
                    },
                };
                let fish = core.add_fish(
                    fish_type, fish_data, desc, tags, is_marked, is_locked, extra_info,
                )?;
                if use_binary_output {
                    Ok(CliOutput::Bytes(fish.to_json_bytes()?))
                } else {
                    Ok(CliOutput::String(fish.to_json_string()?))
                }
                
            },
            Commands::Expire { identity } => {
                core.expire_fish(&identity)?;
                Ok(CliOutput::Ok)
            },
            Commands::Modify { identity } => {
                core.modify_fish(&identity, None, None, None)?;
                Ok(CliOutput::Ok)
            },
            Commands::Mark { identity } => {
                core.mark_fish(&identity)?;
                Ok(CliOutput::Ok)
            },
            Commands::Unmark { identity } => {
                core.unmark_fish(&identity)?;
                Ok(CliOutput::Ok)
            },
            Commands::Lock { identity } => {
                core.lock_fish(&identity)?;
                Ok(CliOutput::Ok)
            },
            Commands::Unlock { identity } => {
                core.unlock_fish(&identity)?;
                Ok(CliOutput::Ok)
            },
            Commands::Pin { identity } => {
                core.pin_fish(&identity)?;
                Ok(CliOutput::Ok)
            },
            Commands::Search { fuzzy, fish_types, page_num, page_size } => {
                let fish_types = match fish_types {
                    None => None,
                    Some(x) => Some(x.into_iter().map(|y| FishType::from_str(&y.Aabb()).map_err(|e|
                            err!(ParseError::"handle add command": "parse fish_type failed", y, e)
                    )).collect::<YRes<Vec<_>>>()?),
                };
                let res = core.search_fish(
                    fuzzy, None, fish_types, None, None, None, None, page_num, page_size,
                )?;
                Ok(CliOutput::String(res.to_json_string()?))
            },
            Commands::Pick { identity } => {
                let fish = core.pick_fish(&identity)?;
                match fish {
                    Some(x) => Ok(CliOutput::String(x.to_json_string()?)),
                    None => Ok(CliOutput::None),
                }
            },
        }
    }

}

