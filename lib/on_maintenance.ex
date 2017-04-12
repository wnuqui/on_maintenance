defmodule Plug.OnMaintenance do
  @moduledoc """
  **Plug.OnMaintenance**, an Elixir Plug, is used to disable access to your application for some length of time.
  Putting application in maintenance mode can be done programmatically or via mix tasks.

  **Note:** This plug must be the first in pipeline of plugs.

  ## Examples
      defmodule AwesomeApp do
        plug Plug.OnMaintenance
        # ...
      end
  """
  import Plug.Conn
  import Plug.OnMaintenance.Util

  def init(opts), do: opts

  def call(conn, _opts) do
    if on_maintenance?() do
      {body, content_type} = get_body_and_content_type(conn)

      conn
      |> put_resp_header("retry-after", retry_after_header())
      |> put_resp_content_type(content_type)
      |> send_resp(503, body)
      |> halt()
    else
      conn
    end
  end

  def get_body_and_content_type(conn) do
    case get_accept_header(conn) do
      :json -> json_body_and_content_type()
      :html -> html_body_and_content_type()
      :text -> text_body_and_content_type()
    end
  end

  defp get_accept_header(conn) do
    accept = get_req_header(conn, "accept") |> to_string

    cond do
      Regex.match?(~r/application\/json/, accept) ->
        :json
      Regex.match?(~r/text\/html/, accept) ->
        :html
      Regex.match?(~r/text\/plain/, accept) ->
        :text
      Regex.match?(~r/\*\/\*/, accept) ->
        :text
    end
  end

  defp json_body_and_content_type do
    body = Poison.encode!(%{message: message()})
    {body, "application/json"}
  end

  defp html_body_and_content_type do
    {
      "<html><body>" <> message() <> "</body></html>",
      "text/html"
    }
  end

  defp text_body_and_content_type do
    {message(), "text/plain"}
  end
end
