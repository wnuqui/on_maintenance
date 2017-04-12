# Plug.OnMaintenance

_Enable maintenance mode for your Plug based Elixir applications._

**Plug.OnMaintenance**, an Elixir Plug, is used to disable access to your application for some length of time. Putting application in maintenance mode can be done programmatically or via mix tasks.

## Contents

- [Installation](#installation)
- [Setup](#setup)
- ["retry-after" response header](#retry-after-response-header)
- [Example 503 responses (default)](#example-responses)
- [Custom 503 Message](#custom-503-message)
- [License](#license)

## Installation

For whatever reason, you want your Plug based Elixir application to be in maintenance mode for some length of time. `Plug.OnMaintenance` is what you need.

Add `on_maitnenance` to your project dependencies in mix.exs:

```exs
defp deps do
  [
    ...
    {:on_maintenance, "~> 0.5"}
  ]
end
```

and do

```bash
mix deps.get
```

In case of error, you may want to do

```bash
mix deps.update --all
```

## Setup

Now that you have `on_maintenance` as your dependency, plug `Plug.OnMaintenance` in your `router.ex`. Let us say we have a Phoenix application.

```elixir
pipeline :api do
  plug Plug.OnMaintenance
  # ...
end
```

Then run this mix task

```bash
mix maintenance.init_config_store # creates sqlite db and add initial state of application (which is "not in maintenance mode")
```

Then run the application

```bash
mix phoenix.server # just in local
```

You can enable/disable maintenance mode for your application via mix tasks below

```bash
mix maintenance.enable
mix maintenance.disable
```

Or programmatically using these convenience methods below

```elixir
import Plug.OnMaintenance.Util

on_maintenance?()     # will check if application is in maintenance mode
enable_maintenance()  # put application in maintenance mode
disable_maintenance() # disable maintenance mode
```

## **retry-after** response header
`503` response code should have a `retry-after` [header](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html).

You can enable maintenance mode for your application and can
specify how long it would take via `--retry-after` option!

```bash
mix maintenance.enable --retry-after=300 # application will be on maintenance for 5 minutes.
```

## Example 503 responses (default)

When in maintenance mode, your application will respond 503 to all http requests. The default message is _"application on scheduled maintenance."_. Examples:

### text/html response
```html
<html>
  <body>Application on scheduled maintenance.</body>
</html>
```

### application/json response
```json
{"message": "Application on scheduled maintenance."}
```

### text/plain response
```text
Application on scheduled maintenance.
```

## Custom 503 Message

Default message can be updated via `config.exs`

```elixir
use Mix.Config

# ...

config :on_maintenance,
  message: "Service is currently in maintenance mode. Give us few minutes. Thanks!"
```

## License

(The MIT license)

Copyright (c) Wilfrido T. Nuqui Jr.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
