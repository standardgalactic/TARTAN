#!/usr/bin/env bash
set -e
REPLACEMENT="Flyxion"
LOG_FILE="flyxion_corrections.log"
CANDIDATE_FILE="flyxion_candidates.tmp"
VIM_SCRIPT="$(mktemp)"
PATTERN='Flexion|Flixian|Flixing|Fliction|Flippshen|Flexumian|Fletchian|Flicksheen|Flyzion|Flyxen|Flyxian|Flyxionn|Flyxionne|Flykshun|Flykshion|Flikshun|Flikzion|Flikxion|Fleksion|Fleksian|Flextion|Flicksion|Flickzion|Flickxion|Fleksheen|Flekshun|Flekzion|Flixion|Flixyon|Flixxon|Flixionne|Flyxionu'

echo "" >> "$LOG_FILE"
echo "Flyxion normalization log - $(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
: > "$CANDIDATE_FILE"

cat > "$VIM_SCRIPT" <<EOF
g/\v\c${PATTERN}/echo expand('%:p') . ':' . line('.') . ': ' . getline('.')
%s/\v\c${PATTERN}/${REPLACEMENT}/gi
%s/\v\c(in|of|af|am|an|at|to)(flyxion)/\1 Flyxion/gi
wq!
EOF

find . -type f -print0 | while IFS= read -r -d '' file; do
  case "$file" in
    *.json|*.srt|*.tsv|*.txt|*.vtt)
      tmp_log="$file.tmp.$$.log"
      vim -Es "$file" -S "$VIM_SCRIPT" > "$tmp_log" 2>/dev/null || true
      if [ -s "$tmp_log" ]; then
        cat "$tmp_log" >> "$LOG_FILE"
      fi
      rm -f "$tmp_log"
      echo "Updated: $file"
      python3 -c '
import sys, difflib, re
target = "flyxion"
threshold = 0.74
filename = sys.argv[1]
with open(filename, "r", errors="ignore") as fh:
    for line in fh:
        for w in re.findall("[A-Za-z]+", line):
            lw = w.lower()
            if (
                lw != target
                and abs(len(lw) - len(target)) <= 2
                and difflib.SequenceMatcher(None, lw, target).ratio() >= threshold
                and (
                    lw.startswith("flyxion")
                    or "xion" in lw
                    or "xen" in lw
                    or "zion" in lw
                )
            ):
                print(lw)
' "$file" >> "$CANDIDATE_FILE"
      ;;
  esac
done

echo "" >> "$LOG_FILE"
echo "---- Candidate Variants (aggregated) ----" >> "$LOG_FILE"
sort "$CANDIDATE_FILE" | uniq -c | sort -nr >> "$LOG_FILE"
rm -f "$CANDIDATE_FILE" "$VIM_SCRIPT"
echo "----------------------------------------" >> "$LOG_FILE"
echo "Done." >> "$LOG_FILE"