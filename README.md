### NectarDB
## Description
An in-memory distributed key-value store implemented in Elixir prioritizing availability and partition-tolerance over consistency
Not meant to be a serious implementation of a full-fledged database, but instead a learning experience to get practice with Agents, Tasks, Genservers,
Supervisors, and Nodes in Elixir

Note: NectarDB only works on OSX (Macs)

## Installation
1. Clone the repository by executing `git clone https://github.com/KontosTwo/NectarDB.git`
2. Navigate to NectarDB/bin
3. Execute `chmod +x nectar_node.sh` and `chmod +x nectar_api.sh`

## Usage
# Starting the API
1. Open a terminal session and navigate to NectarDB/bin
2. Execute `./nectar_api.sh` and wait for a message in the format of "NectarAPI started at node <name of the api node>"
3. You may have to allow beam.smp and other apps to allow connections
  
# Starting a node
1. Open a terminal session and navigate to NectarDB/bin
2. Execute `./nectar_node.sh <unique name> <name of the api node>` and wait for a message in the format of "NectarNode started at node <name of the node>"
3. You may have to allow beam.smp and other apps to allow connections

# Querying through REST API
1. Write data with the following POST request to localhost:4000/write, Content-Type set to application/json. You may have as many writes and deletes as you want. 
```json
{
	"writes" : [
		{
			"type": "write",
			"key": 1,
			"value": 2
		},
    {
			"type": "delete",
			"key": 1
		},
	]
}
```
If the write is successful you will get a message
```json
{
  "message": "Successful write!"
}
```
2. Read data with the following POST request to localhost:4000/read, Content-Type set to application/json. You may have as many reads as you want
```json
{
	"reads" : [
		{
			"type": "read",
			"key": 1
		},
    {
			"type": "read",
			"key": 2
		}
	]
}
```
Depending on if an individual read succeeds, it will appear in either the "successes" or "failures" category
```json
{
  "successes": [
    {
      "key": 1,
      "result": 2
    }
  ],
  "failures": [
    {
      "key" 2,
      "result": "nodes_unresponsive"
    }
  ]
}
```  

# Fault Tolerance
Kill, restart, and add nodes as you please.

# Future features
 - Nodes can be added even after data has begun flowing in
 - API nodes can be restarted after crashing
 
# Closing words
If there are any problems running NectarDB, please shoot me an email
