# Questions

## Getting started

* Running the phoenix web server: `docker compose up web`
* Access the docker container `docker compose run --rm web bash`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

**To test your application:**

* Access the docker container `docker compose run --rm test bash`
* Run ExUnit for staled tests `mix test --stale`
* Test coverage: `mix coveralls`

**Static analysis, linter and security checker**

* Static analysis with **credo**: `mix credo --strict`
* Format your code with: `mix format`
* Check if your code is formatted: `mix format --check-formatted`
* Security analysis: `mix sobelow`

**Create an admin user**
``docker compose run --rm web bash``
``iex -S mix``
``Questions.Accounts.register(%{name: "Your name", role: "admin", email: "email@mail.com", password: "password"})``

## Directories structure

* config/: Runtime configuration for the mix application
* lib/: Source code of our application
* lib/teaching/: Domain code
* lib/teaching_web/: Application code to handle HTTP communication
* test/: ExUnit test suite
* test/support/: This directory usually contains helpers and fixtures modules
* priv/: Code that isn't used in runtime, like database migrations, seeds and scripts
* priv/migrations/: Database structure migrations. We don't migrate any kind of data here
* deps/: Directory with all dependencies downloaded by `mix deps.get`
* _build/: Compiled code by `mix compile`

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
