defmodule Mix.Tasks.Maintenance.Disable do
  use Mix.Task

  @shortdoc "Disables maintenance mode for application."

  @moduledoc """
  Disables maintenance mode for application..

      mix maintenance.disable
  """

  def run(_args) do
    Plug.OnMaintenance.Util.disable_maintenance()
  end
end
