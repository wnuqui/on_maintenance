"test/support"
|> Path.join("**/*.exs")
|> Path.wildcard()
|> Enum.map(&Code.require_file/1)

ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]
ExUnit.start()
