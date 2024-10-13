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
                        let fish_type = FishType::from_str(&fish_type).map_err(|err|
                            err!(ParseError::"handle add command": "parse fish_type failed", fish_type, err)
                        )?;
                        let fish = core.add_fish(fish_type, YBytes::new(fish_data.into_bytes()), None, None, None, None)?;
                        Ok(fish.to_json_string()?)
                    }
                }
            },
            Err(err) => Ok(err.to_string()),
        }
    }

}

