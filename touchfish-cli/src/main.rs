use std::{io::Write, rc::Rc};
use cli::Cli;
use touchfish_core::TouchFishCore;
use touchfish_sqlite_storage::SqliteStorage;
use yfunc_rust::prelude::*;

mod cli;

fn main() -> YRes<()> {
    let storage = SqliteStorage::connect("/Users/yzjsswk/WorkSpace/touchfish.db")?;
    let core = TouchFishCore::new(Rc::new(storage))?;
    loop {
        write!(std::io::stdout(), "> ").map_err(|e|
            err!(IOError::"write > to stdin", e)
        )?;
        std::io::stdout().flush().map_err(|e|
            err!(IOError::"flush stdout", e)
        )?;
        let mut input = String::new();
        std::io::stdin()
            .read_line(&mut input)
            .map_err(|e|
                err!(IOError::"read line from stdin", e)
            )?;
        let input = input.trim();
        if input.is_empty() {
            continue;
        }
        if input == "exit" || input == "quit" {
            break Ok(());
        }
        match Cli::handle(input, &core) {
            Ok(output) => {
                write!(std::io::stdout(), "{}\n", output).map_err(|e|
                    err!(IOError::"write output to stdin", e)
                )?;
                std::io::stdout().flush().map_err(|e|
                    err!(IOError::"flush stdout", e)
                )?;
            },
            Err(err) => {
                write!(std::io::stdout(), "{:?}\n", err).map_err(|e|
                    err!(IOError::"write error to stdin", e)
                )?;
                std::io::stdout().flush().map_err(|e|
                    err!(IOError::"flush stdout", e)
                )?;
            },
        }
    }
}
