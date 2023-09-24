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
View Layer Properies =>  Crease Angle 179
Render => Render Image

cp /tmp/out.svg0001.svg out.svg
gpicview .
make
mupdf build/out.pdf
```
