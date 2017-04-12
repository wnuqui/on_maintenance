defmodule Mix.Tasks.Maintenance.Enable do
  use Mix.Task

  @shortdoc "Enable maintenance mode for application."
  @recursive true

  @moduledoc """
  Sets an application to maintenance mode.
  It can accept `--retry-after` as argument.

      mix maintenance.enable [--retry-after]

  ## Options
    * `--retry-after` - integer value in seconds.
      This will be set as "retry_after" for a 503 response.
      This will tell the client how much time it will wait before the application
      can be used again.
  ## Examples
      mix maintenance.enable # Just enable maintenance mode on. Waiting time is indefinite.
  With `--retry-after` (in seconds)

      mix maintenance.enable --retry-after=300 # Maintenace mode will last for 5 minutes.
  """

  @switches [retry_after: :string]

  def run(argv) do
    {opts, _argv} =
      case OptionParser.parse(argv, strict: @switches) do
        {opts, argv, []} ->
          {opts, argv}
        {_opts, _argv, [switch | _]} ->
          {name, nil} = switch
          Mix.raise "Invalid option: " <> name
      end

    retry_after = Keyword.get(opts, :retry_after, "300")
    Plug.OnMaintenance.Util.enable_maintenance(retry_after)
  end
end
