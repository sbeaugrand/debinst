#convert -size 664x1128 xc:white -fill black -draw "roundrectangle 0 0 663 1127 16 16" 0rectangle.png
list=`ls -1 [a-z]*.png`
i=0
j=1
for f in $list; do
    echo $f
    convert -units PixelsPerInch $f -resize 664x1128! -density 300 tmp.png
    convert tmp.png 0rectangle.png -compose Screen -composite +repage $j$f
    if ((++i == 6)); then
        ((i = 0))
        ((++j))
    fi
done
rm tmp.png
for ((i = 0; i < j; ++i)); do
    echo 0$i.png
    montage $i[a-z]*.png -mode Concatenate -tile 3x2 0$i.png
done
