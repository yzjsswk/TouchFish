use clap::{Parser, Subcommand};
use yfunc_rust::prelude::*;

#[derive(Debug, Subcommand)]
pub enum Commands {
    Ping,
    Hello {
        name: String,
        score: Option<i32>,
    },
}

#[derive(Debug, Parser)]
#[command(multicall = true)]
pub struct Cli {
    #[command(subcommand)]
    command: Commands,
}

impl Cli {

    pub fn handle(input: &str) -> YRes<String> {
        let words = input.split_ascii_whitespace();
        match Cli::try_parse_from(words) {
            Ok(cli) => {
                match cli.command {
                    Commands::Ping => Ok("Pong".to_string()),
                    Commands::Hello { name , score } => Ok(format!("{} {}", name, score.unwrap_or(0))),
                }
            },
            Err(err) => Ok(err.to_string()),
        }
    }

}

