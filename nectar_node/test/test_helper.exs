exclude =
  if Node.alive?, do: [], else: [distributed: true]
ExUnit.configure(timeout: :infinity)
ExUnit.start(exclude: exclude)
