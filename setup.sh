cd  /path/to/astra-sim
ASTRA_SIM="$PWD"
git submodule update --init --recursive

python3 -m venv chakra_env
source chakra_env/bin/activate

cd ${ASTRA_SIM}/extern/graph_frontend/chakra
git submodule update --init --recursive


pip3 install .


cd ${ASTRA_SIM}
pip3 install --upgrade 'protobuf==6.31.1'
./build/astra_analytical/build.sh
