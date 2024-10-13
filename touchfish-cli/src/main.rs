use std::io::Write;
use cli::Cli;
use yfunc_rust::prelude::*;

mod cli;

fn main() -> YRes<()> {
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
        match Cli::handle(input) {
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
