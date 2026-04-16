# Download 2022 election data (adapted from https://bit.ly/3NXoUyT)
mkdir data
cd data
wget -O 2022_round_2.zip https://github.com/larc-logs-transparentes/access/releases/download/v0.0.1-dev/2022_round_2.zip
unzip 2022_round_2.zip 
cd ../


# Activate Python virtual environment
cd ../../
source .venv/bin/activate
cd -

# populate election data
python populate_db.py
