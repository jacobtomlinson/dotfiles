"""Manual, conservative skill checkout/link maintenance. Never executes skills."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def git(root, *args):
    return subprocess.check_output(['git', '-C', str(root), *args], stderr=subprocess.STDOUT).decode().strip()


def identity(url):
    url = url.rstrip('/')
    for prefix in ('https://github.com/', 'ssh://git@github.com/', 'git@github.com:'):
        if url.startswith(prefix):
            repo = url[len(prefix):]
            if repo.endswith('.git'):
                repo = repo[:-4]
            return 'github.com/' + repo.lower()
    return os.path.realpath(url) if '://' not in url else url


def exists(path):
    return os.path.lexists(str(path))


def fingerprint(root):
    """Hash complete tree, modes and link text. Reject escaping/broken links."""
    root = root.resolve(strict=True)
    result = []
    for base, dirs, files in os.walk(str(root), followlinks=False):
        for name in sorted(dirs + files):
            p = Path(base) / name
            rel = str(p.relative_to(root))
            mode = p.lstat().st_mode & 0o777
            if p.is_symlink():
                target = p.resolve(strict=True)
                if root != target and root not in target.parents:
                    raise ValueError('escaping symlink: ' + str(p))
                data = ('link', os.readlink(str(p)))
            elif p.is_file():
                data = ('file', hashlib.sha256(p.read_bytes()).hexdigest())
            elif p.is_dir():
                data = ('dir', '')
            else:
                raise ValueError('unsupported special file: ' + str(p))
            if name.startswith('private-') and p.is_dir():
                raise ValueError('private directory inside skill; import refused: ' + str(p))
            if name == '.git':
                raise ValueError('nested .git is not importable: ' + str(p))
            result.append((rel, mode, data))
    return sorted(result)


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + '.tmp')
    tmp.write_text(json.dumps(value, indent=2) + '\n')
    os.replace(str(tmp), str(path))


def main():
    parser = argparse.ArgumentParser(description=__doc__, epilog='No commits, pushes, scheduling or skill execution. Collisions are never overwritten.')
    parser.add_argument('command', choices=['setup', 'sync'])
    parser.add_argument('--checkout', default=os.environ.get('SKILLS_CHECKOUT', '~/Projects/jacobtomlinson/skills'))
    parser.add_argument('--repo', default='https://github.com/jacobtomlinson/skills.git', help='expected origin and clone URL (local remotes supported)')
    parser.add_argument('--branch', default='main')
    parser.add_argument('--agents', default='~/.agents/skills')
    parser.add_argument('--claude', default='~/.claude/skills')
    parser.add_argument('--state', default='~/.local/state/dotfiles-skills')
    parser.add_argument('--lock-file', help='global npx lock override; default respects XDG_STATE_HOME')
    parser.add_argument('--adopt', action='append', default=[], metavar='NAME', help='explicitly import this unmanaged skill (repeatable); never replaces repo content')
    parser.add_argument('--no-prompt', action='store_true', help='report candidates without asking (explicit --adopt still works)')
    parser.add_argument('--private-claude', action='store_true', help='link local private-* skills into Claude without importing')
    parser.add_argument('--dry-run', action='store_true', help='read-only local plan; does not clone/fetch or prompt')
    a = parser.parse_args()
    root, agents, claude, state = [Path(x).expanduser().absolute() for x in (a.checkout, a.agents, a.claude, a.state)]
    if agents.is_symlink() or claude.is_symlink():
        raise ValueError('skill roots must be real writable directories, not whole-root symlinks')
    roots = (root, agents, claude, state)
    for i, x in enumerate(roots):
        for y in roots[i + 1:]:
            if x.resolve() == y.resolve() or x.resolve() in y.resolve().parents or y.resolve() in x.resolve().parents:
                raise ValueError('checkout, agent roots and state must not overlap')
    if not root.exists():
        if a.command != 'setup':
            raise ValueError('checkout missing; run skills-setup first')
        if a.dry_run:
            print('Would clone', a.repo, 'to', root)
            return
        root.parent.mkdir(parents=True, exist_ok=True)
        subprocess.check_call(['git', 'clone', '--branch', a.branch, '--', a.repo, str(root)])
    if Path(git(root, 'rev-parse', '--show-toplevel')).resolve() != root.resolve():
        raise ValueError('checkout must be the Git root')
    if identity(git(root, 'remote', 'get-url', 'origin')) != identity(a.repo):
        raise ValueError('origin identity mismatch; refusing checkout')
    manifest = state / 'links.json'
    old = json.loads(manifest.read_text()) if manifest.exists() else {}
    # Do not use another checkout's ownership receipts.
    if old and old.get('checkout') != str(root):
        raise ValueError('state belongs to a different checkout')
    links = old.get('links', {})
    failures = []
    if a.command == 'sync':
        if git(root, 'status', '--porcelain', '--untracked-files=all'):
            raise ValueError('checkout dirty (including untracked files); commit/reconcile manually before sync')
        if git(root, 'branch', '--show-current') != a.branch:
            raise ValueError('checkout is not on requested branch')
        if a.dry_run:
            print('Would fetch origin and fast-forward only; remote additions/deletions not yet known')
        else:
            git(root, 'fetch', 'origin', a.branch)
            git(root, 'merge-base', '--is-ancestor', 'HEAD', 'FETCH_HEAD')
            git(root, 'merge', '--ff-only', 'FETCH_HEAD')
    if not a.dry_run:
        for p in (agents, claude, state):
            p.mkdir(parents=True, exist_ok=True)
        exclude = Path(git(root, 'rev-parse', '--git-path', 'info/exclude'))
        if not exclude.is_absolute():
            exclude = root / exclude
        exclude.parent.mkdir(parents=True, exist_ok=True)
        content = exclude.read_text() if exclude.exists() else ''
        if 'private-*/' not in content.splitlines():
            exclude.write_text(content + '\nprivate-*/\n')
    lock_path = Path(a.lock_file).expanduser() if a.lock_file else (Path(os.environ['XDG_STATE_HOME']) / 'skills/.skill-lock.json' if os.environ.get('XDG_STATE_HOME') else Path.home() / '.agents/.skill-lock.json')
    lock = {}
    if lock_path.exists():
        try:
            raw = json.loads(lock_path.read_text())
            if isinstance(raw, dict) and raw.get('version') == 3 and isinstance(raw.get('skills'), dict):
                lock = {name: entry for name, entry in raw['skills'].items() if isinstance(entry, dict)}
            else:
                print('Unsupported npx lock schema; external symlinks will not be imported')
        except (ValueError, OSError):
            print('Unreadable npx lock; external symlinks will not be imported')
    requested = set(a.adopt)
    found = set()
    # Canonical entries first. Claude-only real copies are also candidates.
    candidates = {}
    for base in (agents, claude):
        if base.exists():
            for p in sorted(base.iterdir()):
                if p.name.startswith(('.', 'private-')) or not p.is_dir() or not (p / 'SKILL.md').is_file():
                    continue
                if p.is_symlink():
                    if p.resolve() == (root / p.name).resolve():
                        continue
                    # Agent links to canonical npx installs are aliases, not sources.
                    if base == claude and p.resolve() == (agents / p.name).resolve():
                        if p.name in candidates:
                            candidates[p.name].append(p)
                        continue
                    # npx --link can point canonical directly to its original source.
                    # A matching v3 local lock entry is required; arbitrary plugin links stay put.
                    entry = lock.get(p.name, {})
                    url = entry.get('sourceUrl', '')
                    if not isinstance(url, str):
                        url = ''
                    source = url[7:] if url.startswith('file://') else url
                    source_path = Path(source).expanduser()
                    supported = [source_path, source_path / p.name, source_path / 'skills' / p.name, source_path / '.agents/skills' / p.name]
                    skill_path = entry.get('skillPath')
                    if isinstance(skill_path, str) and not Path(skill_path).is_absolute() and '..' not in Path(skill_path).parts:
                        supported.append(source_path / Path(skill_path).parent)
                    if base != agents or entry.get('sourceType') != 'local' or not source_path.is_absolute() or not any(x.resolve() == p.resolve() for x in supported):
                        print('Unmanaged/ambiguous symlink left untouched:', p)
                        continue
                candidates.setdefault(p.name, []).append(p)
    for name, paths in candidates.items():
        found.add(name)
        dest = root / name
        print('Import candidate:', ', '.join(map(str, paths)))
        if exists(dest):
            print('COLLISION/content drift:', name, '- repository copy preserved; compare/merge manually')
            failures.append(name)
            continue
        if len(paths) > 1 and fingerprint(paths[0]) != fingerprint(paths[1]):
            print('COLLISION: canonical and Claude contents differ:', name)
            failures.append(name)
            continue
        selected = name in requested
        if not selected and not a.no_prompt and not a.dry_run and sys.stdin.isatty():
            selected = input('Import whole skill %s into PUBLIC checkout? [y/N] ' % name).lower() == 'y'
        if not selected:
            print('Not imported; use --adopt', name)
            continue
        if a.dry_run:
            print('Would verify, copy and back up before linking:', name)
            continue
        expected = fingerprint(paths[0])
        staging = Path(tempfile.mkdtemp(prefix='.import-', dir=str(root)))
        try:
            copy = staging / name
            shutil.copytree(str(paths[0].resolve()), str(copy), symlinks=True)
            if fingerprint(copy) != expected or fingerprint(paths[0]) != expected:
                raise ValueError('copy/source verification failed: ' + name)
            # Rename only into a destination that remains absent.
            if exists(dest):
                raise ValueError('destination appeared during import: ' + name)
            os.rename(str(copy), str(dest))
            provenance = lock.get(name)
            if provenance:
                # Keep installer metadata local: may contain private source URLs.
                save(state / 'provenance' / (name + '.json'), provenance)
            for p in paths:
                if fingerprint(p) != expected:
                    raise ValueError('source changed during import: ' + str(p))
                backup_dir = Path(tempfile.mkdtemp(prefix='adopt-', dir=str(state)))
                backup = backup_dir / p.name
                os.rename(str(p), str(backup))
                try:
                    p.symlink_to(dest, target_is_directory=True)
                    links[str(p)] = str(dest)
                    save(manifest, {'checkout': str(root), 'links': links})
                except BaseException:
                    if p.is_symlink():
                        p.unlink()
                    os.rename(str(backup), str(p))
                    raise
                print('Imported', p, '; recoverable original:', backup)
        finally:
            shutil.rmtree(str(staging))
    for name in requested - found:
        if not (root / name / 'SKILL.md').is_file() or not (agents / name).is_symlink():
            print('Requested import not found or unsupported:', name)
            failures.append(name)
    desired = {}
    for p in sorted(root.iterdir()):
        if not p.name.startswith(('.', 'private-')) and p.is_dir() and not p.is_symlink() and (p / 'SKILL.md').is_file():
            for base in (agents, claude):
                desired[str(base / p.name)] = str(p)
    if a.private_claude and agents.exists():
        for p in agents.glob('private-*'):
            if p.is_dir() and (p / 'SKILL.md').is_file():
                desired[str(claude / p.name)] = str(p)
    for link, target in list(links.items()):
        p = Path(link)
        if link not in desired and not p.name.startswith('private-'):
            if p.is_symlink() and os.readlink(str(p)) == target:
                print('Prune owned link:', p)
                if not a.dry_run:
                    p.unlink()
            # Changed entries remain untouched and lose ownership.
            if not a.dry_run:
                del links[link]
    for link, target in desired.items():
        p = Path(link)
        if exists(p):
            if p.is_symlink() and p.resolve() == Path(target).resolve():
                # Do not claim pre-existing links; only our own receipts authorize pruning.
                continue
            if p.name.startswith('private-'):
                print('Private local entry preserved:', p)
            else:
                print('COLLISION: leave existing entry untouched:', p)
                failures.append(link)
            continue
        print('Link:', p, '->', target)
        if not a.dry_run:
            p.symlink_to(target, target_is_directory=True)
            links[link] = target
            save(manifest, {'checkout': str(root), 'links': links})
    if not a.dry_run:
        save(manifest, {'checkout': str(root), 'links': links})
    if failures:
        raise ValueError('unresolved collisions/imports; no existing content overwritten')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print('skills: ' + str(error), file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.output:
            print(error.output.decode(), file=sys.stderr)
        sys.exit(1)
