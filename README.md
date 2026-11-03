# Jacob Tomlinson's dotfiles

These are my dotfiles. There are many like them, but these are mine.

## zshrc and zshrc.d (or bashrc and bashrc.d)

When developing my `.zshrc` I found it getting unwieldy and difficult to manage. Therefore I decided to create a `.zshrc.d` directory.

My `.zshrc` is now just package management and a few lines which source all the files included in `.zshrc.d`. This makes it much easier to manage my files and separate them by program or category.

_I originally did this for my `.bashrc` but have now switched to zsh as my daily driver. However my `.bashrc` and `.bashrc.d` are still here for use on servers and lesser systems.

### Private files

Having my `.zshrc` content in separate files also allows me to create private files which may contain things like ssh aliases to private servers etc. This repository is configured to ignore any files in `.zshrc.d` which begin with the word "private", see [.zshrc.d/private_example.zsh](.zshrc.d/private_example.zsh) for an example.

This way I can keep my private aliases private.

## Installation

### Scripted

Just checkout the repo and run `./install.sh` which will create all the symlinks for you. Easy!

### Manual

Clone the repo and create symlinks for each item in this repo that you want to use to your home directory. This way when you change things you can still track the changes in git.

## Updates

If you want to update your scripts in the future when I make changes simply do a git pull on the repository.

## Disclaimer
This is how I like my terminal. Decisions about colours, layout, fonts and features are often influenced by my current project, whatever that may be. Things will change to suit my needs, this repository is to allow me to quickly put my preferred settings on a new machine as well as share it with others.

Features will come and go as I see fit, I will do my best to tag a release before making a major change to allow others to stick with a version they like. I may even make this more modular in future to allow for turning on different options.


[1]: https://github.com/jacobtomlinson/terminal-piperita

## Shared agent skills (manual only)

Public skills live separately in [jacobtomlinson/skills](https://github.com/jacobtomlinson/skills),
not in these dotfiles. With Git and **Python 3.8+** installed, run:

```bash
skills-setup --dry-run
skills-setup
skills-sync --dry-run
skills-sync
```

The executable commands live in `.zsh/bin` (available with these dotfiles installed;
otherwise invoke `.zsh/bin/skills-setup` directly). Their Bash entry points work with
macOS Bash 3.2 and Linux; the shared Python standard-library helper avoids GNU-only
filesystem utilities. They do not run during dotfiles installation or shell startup,
and install no scheduler. They never execute skill scripts, commit, or push.

Setup clones or reuses `~/Projects/jacobtomlinson/skills`, verifies its `origin` is
`jacobtomlinson/skills`, and links each top-level directory containing `SKILL.md`
individually into `~/.agents/skills` and `~/.claude/skills`. Hidden directories,
`private-*` directories, and symlinked directories in the checkout are not published
as managed skills. The skill roots remain real writable directories, so agents and
installers can still create new skills there. Whole-root symlinks are refused.

`skills-sync` requires a clean checkout (including untracked files), on `main`,
fetches `origin main`, and only fast-forwards if the local HEAD is an ancestor.
It refuses dirty, local-ahead, divergent, wrong-origin or offline updates. It never
stashes, resets, rebases or force-updates. Fix the reported condition manually and
rerun. Setup can reconcile the existing checkout's links while offline.

### Creation, editing, adoption and publishing

Create a skill with its whole directory in `~/.agents/skills/new-name/`, including
`SKILL.md`, scripts, references and other resources. Alternatively create it directly
in the public checkout and rerun setup to link it. Edit an already managed skill
through either agent link or its checkout directory; both edit the same files.

Setup and sync offer an interactive import of newly discovered real skill directories
in the canonical agent root (or Claude-only real installs). Import is **not automatic**:
noninteractive runs only report candidates unless names are explicitly selected.

```bash
skills-sync --dry-run --adopt new-name
skills-sync --adopt new-name --no-prompt
# Repeat --adopt for multiple names; setup also accepts it.
```

Import copies the **entire** skill tree, including executable modes and dotfiles,
verifies content, modes and symlink text against the original, then replaces the
original with a link. Nested links escaping the skill tree, broken links, special
files, nested `.git` directories and nested `private-*` directories are refused.
Originals are moved to recoverable local `~/.local/state/dotfiles-skills/adopt-*/` backups, never destroyed. On a failed
link creation the original is restored; a verified checkout copy may remain for
inspection. An interrupted import may also leave a `.import-*` staging directory.
Inspect both locations before retrying; never discard the sole copy of your work.

Review the public checkout carefully, including third-party licenses and copied
resources, then explicitly `git add`, `git commit` and `git push` there yourself.
Until you commit or otherwise reconcile imports/edits, sync refuses the dirty checkout;
setup can still reconcile local links. Nothing publishes on your behalf.

### Globally installed `npx skills` skills

Global installs are import candidates too, not just hand-authored skills:

```bash
npx skills add vercel-labs/agent-skills -g --skill web-design-guidelines -a codex -a claude-code
skills-sync --dry-run --adopt web-design-guidelines
skills-sync --adopt web-design-guidelines
# Review and commit/push the skills checkout explicitly afterwards.
```

The current [installer source](https://github.com/vercel-labs/skills/blob/main/src/installer.ts)
and [lock implementation](https://github.com/vercel-labs/skills/blob/main/src/skill-lock.ts)
were inspected on 2026-11-03. A disposable HOME experiment with **skills 1.7.6**
confirmed global add copies the whole skill into `~/.agents/skills/<name>` and links
Claude to it. Its version-3 provenance lock is separate: `~/.agents/.skill-lock.json`,
or `$XDG_STATE_HOME/skills/.skill-lock.json` when configured. The lock is **not a skill**;
it is never moved, rewritten, or automatically copied into the public repo. Available
origin URL/source/ref metadata is retained locally in
`~/.local/state/dotfiles-skills/provenance/<name>.json`. Review and add a public
attribution yourself if desired; local provenance can contain private URLs.
`--lock-file PATH` handles alternate installer lock locations.

Canonical installer `--link` symlinks are supported only when a version-3 **local**
lock entry matches the resolved source: the source directory itself, `<source>/<name>`,
`<source>/skills/<name>`, `<source>/.agents/skills/<name>`, or a recorded skill path.
Import copies the contents rather than transplanting that external link. Matching
Claude-to-canonical aliases are reconciled during explicit adoption. Arbitrary plugin
links, missing/unknown lock schemas and ambiguous source layouts are left untouched
and reported; inspect them and explicitly copy the intended skill into a fresh real
canonical directory if you want to import it. Project-level installs are not scanned.

A subsequent `npx skills add` or `update` may replace a managed link with a fresh
real installation. The next setup/sync detects the name/content collision and preserves
**both** the repository customization and installed version. It does not silently
adopt updates over your public copy, even with `--adopt`. Compare them, merge the
changes deliberately into the checkout, then move the independent installed directory
to a safe backup outside the discovery roots and rerun setup to restore links. Or
rename the newly installed directory to a distinct skill name and explicitly adopt
that as a separate skill. Canonical and Claude real copies with different content
are likewise reported, never overwritten. Updating a managed skill through an
installer which writes through symlinks can instead dirty the checkout: review its
Git diff and resolve manually. These commands do not run `npx` themselves.

### Private skills, conflicts and link ownership

`private-*` skills stay on the local machine: never adopted, moved or pruned. Optionally
run `skills-setup --private-claude` to create missing Claude compatibility links to
canonical private skills; existing Claude entries are preserved. This links local
content only, without copying it into Git. Checkout-local `private-*/` is added to
Git's **local** `info/exclude`, not tracked `.gitignore`. Excludes do not protect files
already tracked by Git, do not defeat `git add -f`, and are not a confidentiality
boundary: remove already tracked private material from version control manually.
Private machine-local content is not synchronized between machines.

A local ownership receipt in `~/.local/state/dotfiles-skills/links.json` permits sync
to prune only unchanged symlinks it created when a public skill is deleted upstream.
Unrelated real directories and symlinks (including changed owned links) are preserved.
Already existing equivalent links are accepted but not claimed; they will not be
pruned. Do not delete the receipt unless you intend to lose automatic prune ownership.
Conflicts are printed and cause a nonzero exit; unrelated nonconflicting links may
still be reconciled. Resolve conflicts by inspecting and safely backing up the
existing entry, then rerun. There is no destructive overwrite flag.

### Paths and agent discovery

Use `--help` for `--checkout` (also `SKILLS_CHECKOUT`), `--repo`, `--branch`, `--agents`,
`--claude`, `--state`, `--no-prompt`, `--adopt`, `--private-claude` and `--dry-run`.
Use the same overrides on subsequent runs; ownership state is bound to its checkout.
`--repo` changes the expected origin as well as clone URL (useful for forks/local
remotes). Dry-run makes **no writes and no network calls**, so it cannot predict
remote additions/deletions until a real sync fetches them. No credentials are handled.

Codex and Pi use `~/.agents/skills`. OpenClaw normally discovers that canonical
location too; an alternate `OPENCLAW_STATE_DIR`, a different service HOME or runtime
configuration may change discovery. Verify the running instance's discovered skills
rather than assuming that your shell's HOME is the service HOME. If needed, explicitly
create individual compatibility links from its configured skills directory to the
canonical skill directories (or choose `--agents` appropriately). Do not replace the
whole canonical root with a symlink. OpenClaw bundled/plugin skills are separate and
must not be imported just because they are visible to an agent. Claude uses
`~/.claude/skills` (override `--claude` for an alternate configuration directory).

### Verification

```bash
python3 -m unittest discover -s tests -v
# Opt-in network proof: Node/npm required; all installer state stays in disposable HOME.
RUN_NPX_SKILLS_TEST=1 python3 -m unittest discover -s tests -v
```

Tests use temporary HOME directories and local Git remotes for setup/idempotence,
whole-tree adoption, Claude aliases, private preservation, collisions, owned pruning,
offline/dirty/divergent/ahead checkouts, installer provenance/symlinks and failure data
preservation. The opt-in test actually runs global `npx skills@1.7.6 add`, imports the
whole skill, then reinstalls changed content and checks that customizations survive.
