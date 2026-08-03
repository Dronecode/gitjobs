# Dronecode theming

This fork tracks `cncf/gitjobs` and we do not intend to maintain our own copy of
the UI. Everything here exists to keep that possible: theming is confined to the
one place upstream almost never touches, so `git merge upstream/main` stays
clean.

## Why it is shaped this way

Measured against the repo's own history (285 commits):

| Surface | Upstream commits | Verdict |
|---|---|---|
| `@theme` block in `styles.src.css` | **1** | Safe to own |
| `static/images/*` brand assets | **1** each | Safe to overwrite in place |
| `header.html` | 38 | Do not touch |
| 482 hardcoded `stone-*` classes in templates | n/a | Do not touch |

So:

- **Colours live in `@theme`.** That block defines `--color-primary-50` through
  `--color-primary-950`, and every `bg-primary-*`, `text-primary-*` and
  `border-primary-*` utility across all 57 templates derives from it. Rewriting
  it re-themes the whole application without touching a single template.
- **Logos are swapped in place**, keeping the upstream filename. Editing
  `header.html` to point at a differently named file would mean conflicting with
  the churniest file in the repo on every merge, to no benefit.
- **The neutral palette is not find-and-replaced.** There are 482 hardcoded
  `stone-*` classes. Rewriting them would create 482 permanent conflict points.
  Tailwind v4 allows redefining built-in palettes, so `--color-stone-*` can be
  overridden in the same `@theme` block if the greys ever need to change.

## Usage

```sh
python3 dronecode-theme/theme.py list
python3 dronecode-theme/theme.py verify --all
python3 dronecode-theme/theme.py apply <name>
cargo build -p gitjobs-server      # Tailwind runs from build.rs
```

`apply` rewrites only the `@theme` block. Switching themes is one command and
one file in the diff.

## Accessibility is enforced, not advisory

`apply` refuses to write a theme that fails, because the failures are not
hypothetical: these pairings are compiled into the component classes and cannot
be adjusted without editing templates.

| Pairing | Minimum | Where it comes from |
|---|---|---|
| white on `primary-600` | 4.5:1 | `.btn-primary` |
| white on `primary-900` | 4.5:1 | `.btn-primary` hover |
| `primary-900` on `primary-50` | 4.5:1 | `.btn-secondary` |
| `primary-900` on `primary-100` | 4.5:1 | `.btn-secondary` hover |
| `primary-600` on white | 4.5:1 | links |

The ramp is also checked for monotonic lightness, since a scale whose steps
collapse into one another looks broken in real interface chrome even when every
contrast pair passes.

Worth knowing: the upstream CNCF palette **fails two of these**, with both the
primary button and links at 4.11:1. It is kept as `cncf-original` for
comparison and rollback, and it is the reason `apply` validates rather than
trusts.

## A note on the brand colours

The Dronecode logo greens are light. Measured against white:

| Colour | Ratio | Usable as a button? |
|---|---|---|
| `#27B373` brand green | 2.70:1 | No |
| `#5DC4CD` teal | 2.05:1 | No |
| `#1E8756` dark green | 4.51:1 | Only just |

So the vivid brand green cannot be `primary-600`. It belongs mid-ramp around
step 400–500, with the darker steps derived from it. Any theme that puts the
literal logo green on a button produces unreadable white text.
