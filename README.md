# FungusToast

![](https://media.giphy.com/media/l41lL7byr2fvtxVHa/giphy.gif)


## Dev Workflow
To start Phoenix in Docker:
  * `docker-compose up`

Debuggering in Docker:
  * once you've run `docker-compose up`
    * `docker attach fungus_toast_web_1`

To run tests in Docker:
  * `docker-compose run --rm test`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
