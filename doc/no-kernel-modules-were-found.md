# Simple CDD - No kernel modules were found
```sh
sdir=...  # simple_cdd_dir
build-simple-cdd --conf simple-cdd.conf --dvd
file $sdir/tmp/cd-build/bookworm/CD1/install.amd/vmlinuz  # 6.1.0.15
cd /tmp
```
```sh
cp -r $sdir/tmp/mirror/dists/bookworm/main/installer-amd64/current/images/cdrom .
ar p $sdir/tmp/cd-build/bookworm/CD1/pool/main/l/linux-signed-amd64/linux-image-6.1.0-17-amd64_6.1.69-1_amd64.deb data.tar.xz | tar xJ ./boot/vmlinuz-6.1.0-17-amd64
cp boot/vmlinuz-6.1.0-17-amd64 vmlinuz
cp vmlinuz cdrom/
cp vmlinuz cdrom/gtk/
cp vmlinuz cdrom/xen/
```
```sh
mkdir initrd
cd initrd
zcat ../cdrom/initrd.gz | cpio -idmv
cd lib/modules
ln -s 6.1.0-15-amd64 6.1.0-17-amd64
cd -
find . | cpio -o -R root:root -H newc | gzip -9 >../initrd.gz
cd ..
cp initrd.gz cdrom/
cp initrd.gz cdrom/gtk/
cp initrd.gz cdrom/xen/
```
```sh
python3 -m http.server
vi simple-cdd.conf  # export DI_WWW_HOME=http://0.0.0.0:8000
build-simple-cdd --conf simple-cdd.conf --dvd
file $sdir/tmp/cd-build/bookworm/CD1/install.amd/vmlinuz  # 6.1.0.17
```
