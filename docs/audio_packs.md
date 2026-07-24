# Pre-generated Czech audio packs

Curriculum audio is looked up by normalized-text SHA-256 in the manifest stored
in the public, client-read-only Supabase Storage bucket `course-audio`. If an
entry or file is unavailable, `CzechTts` automatically falls back to its cached
device TTS path. Dynamic chat text therefore continues to work without being
included in the pack.

## Check coverage first

`tool/audio_coverage.py` reports how many curriculum utterances already have
audio and writes the exact missing list (with a character-count cost proxy):

```sh
python3 tool/audio_coverage.py \
  --bucket-url 'https://<ref>.supabase.co/storage/v1/object/public/course-audio/manifest.json' \
  --write-missing build/audio_missing.txt
```

## Generate the pack

Create an Azure Speech resource, then keep its credentials in your shell (never
in the repository):

```sh
export AZURE_SPEECH_KEY='...'
export AZURE_SPEECH_REGION='westeurope'
python3 tool/generate_audio_pack.py --dry-run
python3 tool/generate_audio_pack.py --gender female
python3 tool/generate_audio_pack.py --gender male
```

The generator extracts vocabulary words/examples plus every lesson dictation,
pronunciation target, and spoken Czech question. It is deterministic and
resumable: existing MP3s are not requested again, so re-running only fills the
gap reported above. The default voice is `cs-CZ-VlastaNeural`; `--gender male`
selects `cs-CZ-AntoninNeural`. The manifest retains both variants, and the
learner can switch between them in Settings. The files under `assets/audio` are
generation artifacts and are deliberately excluded from the Flutter application
bundle.

Use `--limit 10` with each gender for a small device-test pack before generating
the catalog.
Regenerate after curriculum changes; unused old MP3s may then be removed after
confirming they are absent from the new manifest.

## Upload to the bucket

`tool/upload_audio_pack.py` uploads every MP3 the manifest references (bucket
root, by basename — the app downloads by basename) and then the manifest last,
so the app never loads a manifest ahead of its files. Idempotent (upsert), so
an interrupted run can be repeated:

```sh
export SUPABASE_URL='https://<ref>.supabase.co'
export SUPABASE_SERVICE_ROLE_KEY='...'   # service role; storage write
python3 tool/upload_audio_pack.py --dry-run
python3 tool/upload_audio_pack.py
```

Re-run `tool/audio_coverage.py --bucket-url ...` afterward to confirm the
deployed manifest reports 100% coverage.

## Runtime behavior

1. A matching neural MP3 already downloaded to permanent device storage plays.
2. Otherwise it downloads from Supabase Storage, is retained, and plays.
3. Otherwise a previously cached platform-synthesized file is played.
4. Otherwise platform TTS synthesizes/caches the text, or speaks directly.

The speed preference is applied during neural MP3 playback, so normal and slow
replay share the same file. `Clear audio cache` removes downloaded neural audio,
the cached manifest, and generated platform cache files.
