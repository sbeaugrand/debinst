# ---------------------------------------------------------------------------- #
## \file install-op-ytdlp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Example :
##       yt-dlp -f 135+140/best --playlist-reverse -o "%(playlist_autonumber)s-%(title)s.%(ext)s" --restrict-filenames https://www.youtube.com/channel/UCAL3JXZSzSm8AlZyD3nQdBA/videos
# ---------------------------------------------------------------------------- #
pyver=`python3 -c '
import sys
print("{}.{}".format(sys.version_info.major, sys.version_info.minor))'`

dir=$home/.local/lib/python$pyver/site-packages/yt_dlp
if notDir $dir; then
    pip3 install --no-deps -U yt-dlp
fi
