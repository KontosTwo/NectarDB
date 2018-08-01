# NectarDB
An in-memory distributed key-value store implemented in Elixir prioritizing availability and partition-tolerance over consistency
Not meant to be a serious implementation of a full-fledged database, but instead a learning experience to get practice with Agents, Tasks, Genservers,
Supervisors, and Nodes in Elixir

You need to allow epmd to receive incoming connections on a Mac. epmd is located at /usr/local/Cellar/erlang/20.3.6/lib/erlang/erts-9.3.1/bin
(substitute your version in the path) if you installed erlang using homebrew. Open System Preferences and navigate to Firewall options. Add epmd
to the list of trusted applications. If this does not work, run 'iex :a@localhost --sname' and when the prompt opens up allow epmd to receive incoming connections