defmodule Router do
  use Plug.Router

  plug Plug.OnMaintenance

  plug :match
  plug :dispatch

  get "/test" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "<html><body>Hello, World!</body></html>")
  end
end
