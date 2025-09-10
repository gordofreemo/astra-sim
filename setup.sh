cd  /path/to/astra-sim
ASTRA_SIM="$PWD"
git submodule update --init --recursive

python3 -m venv chakra_env
source chakra_env/bin/activate

cd ${ASTRA_SIM}/extern/graph_frontend/chakra
git submodule update --init --recursive


pip3 install .
pip3 install --upgrade 'protobuf>=6.31.1'
apt update && apt install -y graphviz


cd ${ASTRA_SIM}/..
git clone https://github.com/astra-sim/symbolic_tensor_graph
cd symbolic_tensor_graph/

python3 -m venv symb_env
source symb_env/bin/activate
pip install numpy sympy python-graphviz protobuf pandas 
deactivate

cd ${ASTRA_SIM}
./build/astra_analytical/build.sh
