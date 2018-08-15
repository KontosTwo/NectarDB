{application,gen_retry,
             [{description,"GenRetry provides utilities for retrying Elixir functions,\nwith configurable delay and backoff characteristics.\n"},
              {modules,['Elixir.GenRetry','Elixir.GenRetry.Launcher',
                        'Elixir.GenRetry.Launcher.State',
                        'Elixir.GenRetry.Options','Elixir.GenRetry.State',
                        'Elixir.GenRetry.Task',
                        'Elixir.GenRetry.Task.Supervisor',
                        'Elixir.GenRetry.Worker']},
              {registered,[]},
              {vsn,"1.0.2"},
              {applications,[kernel,stdlib,elixir,logger,exconstructor]},
              {mod,{'Elixir.GenRetry',[]}}]}.