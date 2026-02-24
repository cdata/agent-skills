# circle-crop — Detect a circular frame in an image and crop to it with alpha transparency.
#
# Usage: circle-crop <input> <output>
#
# The input image should contain a bright circular frame on a dark background.
# The script detects the frame boundary by sampling pixel brightness along four
# cardinal axes, computes the circle center and radius, then applies a hard
# circular alpha mask. Output is always WebP with alpha.
#
# Dependencies: ImageMagick 7+ (magick)

if [[ $# -lt 2 ]]; then
  echo "Usage: circle-crop <input> <output>" >&2
  exit 1
fi

input="$1"
output="$2"
threshold="0.20"

width=$(magick "$input" -format "%w" info:)
height=$(magick "$input" -format "%h" info:)
cx=$(( width / 2 ))
cy=$(( height / 2 ))

# sample_brightness x y — print the grayscale brightness [0,1] at a pixel
sample_brightness() {
  magick "$input" -colorspace Gray -format "%[fx:u.p{$1,$2}]" info:
}

# scan_edge start end step fixed_coord axis — walk pixels along an axis and
# return the coordinate of the first pixel that exceeds $threshold.
#   axis=h  →  vary x from start→end at y=fixed_coord
#   axis=v  →  vary y from start→end at x=fixed_coord
scan_edge() {
  local pos="$1" end="$2" step="$3" fixed="$4" axis="$5"
  while (( step > 0 ? pos <= end : pos >= end )); do
    if [[ "$axis" == "h" ]]; then
      val=$(sample_brightness "$pos" "$fixed")
    else
      val=$(sample_brightness "$fixed" "$pos")
    fi
    if awk "BEGIN{exit(!($val > $threshold))}"; then
      echo "$pos"
      return
    fi
    pos=$(( pos + step ))
  done
  echo "$pos"
}

# Detect frame edges along four cardinal directions through the center
left=$(scan_edge  0            "$cx"            5  "$cy" h)
right=$(scan_edge "$((width-1))" "$cx"         -5  "$cy" h)
top=$(scan_edge   0            "$cy"            5  "$cx" v)
bottom=$(scan_edge "$((height-1))" "$cy"       -5  "$cx" v)

# Derive circle geometry
center_x=$(( (left + right) / 2 ))
center_y=$(( (top + bottom) / 2 ))
radius_x=$(( (right - left) / 2 ))
radius_y=$(( (bottom - top) / 2 ))
radius=$(( (radius_x + radius_y) / 2 ))

# The edge pixel on the circle for the -draw "circle" command
edge_x=$(( center_x + radius ))

echo "Detected circle: center=($center_x,$center_y) radius=$radius" >&2

# Create circular mask and apply as alpha channel
magick -size "${width}x${height}" xc:black \
  -fill white -draw "circle $center_x,$center_y $edge_x,$center_y" \
  miff:- \
| magick "$input" - -alpha off -compose CopyOpacity -composite "$output"

echo "Wrote $output" >&2
