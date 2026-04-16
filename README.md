# Election Transparency

Performance tests for Election Transparency prototype, a project to increase transparency in elections.



[Link to article]

## 📦 Requirements

- 1 Ubuntu machine to act as the LogServer
  - Tested environment:  DO-Premium-AMD, 2vCPU, 8GB RAM, Ubuntu 22.04 LTS, Docker version 27.3.1, Python 3.10.12
- 1 Ubuntu machine to act as the Client
  - Tested environment:  Intel Xeon Platinum 8168, 2vCPU, 4GB RAM, Ubuntu 22.04 LTS, Docker version 27.3.1, Python 3.10.12



## Setup

In each machine, clone the repository and install the dependencies

```bash
git clone https://github.com/larc-logs-transparentes/access.git
cd access
bash ./setup.sh
```



## Demo execution

A fast demo execution. It will instantiate the Election Transparency modules and populate them with 74 poll tapes from the 2022 Brazilian Election. The user interface can be accessed through the browser in localhost:3000, and it communicates with the backend through port 8080.

```bash
cd logserver
docker compose up -d
sleep 10
docker run --rm --network host --pull always ghcr.io/larc-logs-transparentes/bu-utils:gh-73
```


## Test operations performance

Evaluate the performance of the main verifications in Election Transparency (Table II).

##### Log Server
Create the trees with 1k, 10k, 100k, 500k, and 1M of leaves. It takes ~2 hours in the tested environment.

```bash
cd logserver
docker compose up -d
sleep 10

cd populate_operation_performance
bash ./start.sh
```

##### Client
On another machine, install the dependencies and run the tests. For 50 samples, it takes ~50 minutes on the tested environment.  Wait for the LogServer to create all trees.

```bash
# activate the Python virtual environment. 
cd access/
source .venv/bin/activate

#  Run the tests. Substitute the <Logserver-IP> with the IP of the LogServer.
cd client
LOGSERVER_IP=<LOGSERVER-IP> python3 test_verifications.py --sample_size=50
```


## Test with 2022 Brazilian presidential elections 

Recalculate the results of the 2022 Brazilian presidential elections using published poll tapes. Evaluate the performance of analysis operations (Table III).

##### Log Server
Populate the LogServer with the ~500k poll tapes from the 2022 elections. It takes ~18 hours on the tested environment.

```bash
# Reset docker compose state
cd logserver
docker compose down
docker compose up -d
sleep 10

# start script
cd populate_2022_election
bash ./start.sh
```

##### Client
On another machine, install the dependencies and run the tests. For 50 samples, it takes ~5 hrs on the tested environment. Wait for the LogServer to insert all poll tapes.

```bash
# activate the Python virtual environment. 
cd access/
source .venv/bin/activate

#  Run the tests. Substitute the <Logserver-IP> with the IP of the LogServer.
cd client
LOGSERVER_IP=<LOGSERVER-IP> python3 test_analysis.py --sample_size=50
```

To print the results of 2022 Brazilian Elections, run the following script. It takes ~10min on the tested environment.

```bash
#  Substitute the <Logserver-IP> with the IP of the LogServer.
LOGSERVER_IP=<LOGSERVER-IP> python3 calculate_2022_results.py
```




