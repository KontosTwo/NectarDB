{application,nectar_node,
             [{applications,[kernel,stdlib,elixir,logger,gproc,distillery]},
              {description,"nectar_node"},
              {modules,['Elixir.NectarNode','Elixir.NectarNode.Application',
                        'Elixir.NectarNode.Changelog',
                        'Elixir.NectarNode.DataSupervisor',
                        'Elixir.NectarNode.Memtable',
                        'Elixir.NectarNode.Oplog',
                        'Elixir.NectarNode.Recovery',
                        'Elixir.NectarNode.Server','Elixir.NectarNode.Store']},
              {registered,[]},
              {vsn,"0.1.0"},
              {extra_applications,[logger]},
              {mod,{'Elixir.NectarNode.Application',[]}}]}.
