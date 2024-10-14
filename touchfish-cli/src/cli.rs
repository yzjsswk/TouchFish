use std::str::FromStr;

use clap::{Parser, Subcommand};
use touchfish_core::{FishType, TouchFishCore};
use touchfish_sqlite_storage::SqliteStorage;
use yfunc_rust::{prelude::*, VariableFormat, YBytes};

#[derive(Debug, Subcommand)]
pub enum Commands {
    Add {
        fish_type: String,
        fish_data: String,
    },
    Search {
        #[arg(short = 'f', long = "fuzzy")]
        fuzzy: Option<String>,
        #[arg(short = 't', long = "type", use_value_delimiter = true)]
        fish_types: Option<Vec<String>>,
        #[arg(short = 'p', long = "page")]
        page_num: Option<i32>,
        #[arg(short = 's', long = "size")]
        page_size: Option<i32>,
    }
}

#[derive(Debug, Parser)]
#[command(multicall = true)]
pub struct Cli {
    #[command(subcommand)]
    command: Commands,
}

impl Cli {

    pub fn handle(input: &str, core: &TouchFishCore<SqliteStorage>) -> YRes<String> {
        let words = input.split_ascii_whitespace();
        match Cli::try_parse_from(words) {
            Ok(cli) => {
                match cli.command {
                    Commands::Add { fish_type, fish_data } => {
                        let fish_type = fish_type.Aabb();
                        let fish_type = FishType::from_str(&fish_type).map_err(|e|
                            err!(ParseError::"handle add command": "parse fish_type failed", fish_type, e)
                        )?;
                        let fish = core.add_fish(fish_type, YBytes::new(fish_data.into_bytes()), None, None, None, None)?;
                        Ok(fish.to_json_string()?)
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
                        Ok(res.to_json_string()?)
                    },
                }
            },
            Err(err) => Ok(err.to_string()),
        }
    }

}

