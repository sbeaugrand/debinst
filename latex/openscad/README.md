# scad to SVG with gl2ps (experimental)
```
git clone https://github.com/Open-Cascade-SAS/gl2ps.git
git clone https://github.com/openscad/openscad.git
vi openscad/scripts/uni-get-dependencies.sh +/get_debian_8_deps
equivs-build openscad-control
sudo apt install ./openscad-build-deps_1.0_all.deb

cd openscad
git submodule update --init --recursive
git apply openscad.patch
mkdir build
cd build
cmake ..
make
sudo make install
LANG=C openscad
File => Export => Export as Image

# This works for the table-de-jardin.scad example
# (only 2 triangles in each face) :
../faces2edges.py -f out.svg >edges.svg
make
mupdf build/edges.pdf

# Without edges, with colors :
sed 's/fill="#000000" points/fill="white" points/' out.svg >faces.svg
make
mupdf build/faces.pdf

sudo apt remove openscad-build-deps
sudo apt autoremove
```

# scad to SVG with blender
```
cd models
make
cd
tar xJf blender-3.6.3-linux-x64.tar.xz
blender-3.6.3-linux-x64/blender
Edit => Preferencies => Add-ons => Render: Freestyle SVG Exporter

Cube => Delete
File => Import => Stl
Scale
Toggle the camera view
Scale / Move
Render Properties => Freestyle SVG Export + Freestyle
Output Properties => /tmp/out.svg
View Layer Properies => Crease Angle 179
Render => Render Image

cd models
cp /tmp/out.svg0001.svg out.svg
make
mupdf build/out.pdf
```
