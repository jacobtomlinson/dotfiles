"""Isolated local-remotes tests; never reads or writes the operator's installation."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

PROJECT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('skills', PROJECT / '.zsh/lib/skills.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class SkillsTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='dotfiles-skills-test-')
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.home = self.base / 'home'
        self.home.mkdir()
        self.env = dict(os.environ, HOME=str(self.home), GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1', GIT_AUTHOR_NAME='Test', GIT_AUTHOR_EMAIL='test@example.invalid', GIT_COMMITTER_NAME='Test', GIT_COMMITTER_EMAIL='test@example.invalid')
        self.env.pop('XDG_STATE_HOME', None)
        self.source = self.base / 'source'
        self.source.mkdir()
        self.git(self.source, 'init', '-b', 'main')
        self.skill(self.source / 'one')
        self.git(self.source, 'add', '.')
        self.git(self.source, 'commit', '-m', 'initial')
        self.remote = self.base / 'remote.git'
        self.git(self.base, 'clone', '--bare', str(self.source), str(self.remote))
        self.git(self.source, 'remote', 'add', 'origin', str(self.remote))
        self.checkout = self.home / 'Projects/jacobtomlinson/skills'
        self.agents = self.home / '.agents/skills'
        self.claude = self.home / '.claude/skills'
        self.state = self.home / '.local/state/dotfiles-skills'

    def git(self, cwd, *args):
        return subprocess.check_output(['git', '-c', 'commit.gpgsign=false', '-C', str(cwd), *args], env=self.env, stderr=subprocess.STDOUT).decode().strip()

    def skill(self, path, content='example'):
        path.mkdir(parents=True)
        (path / 'SKILL.md').write_text('---\nname: ' + path.name + '\ndescription: Test\n---\n' + content)
        (path / 'scripts').mkdir()
        (path / 'scripts/run.sh').write_text('echo must-not-run\n')
        (path / 'scripts/run.sh').chmod(0o755)
        (path / 'references').mkdir()
        (path / 'references/data.md').write_text('reference\n')

    def run_cli(self, command='setup', *args, ok=True):
        r = subprocess.run([str(PROJECT / '.zsh/bin' / ('skills-' + command)), '--repo', str(self.remote), '--no-prompt', *args], env=self.env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        self.assertEqual(r.returncode == 0, ok, r.stdout)
        return r.stdout

    def publish(self):
        self.git(self.source, 'add', '-A')
        self.git(self.source, 'commit', '-m', 'update')
        self.git(self.source, 'push', 'origin', 'main')

    def test_setup_idempotent_dry_run_identity_private(self):
        self.run_cli('setup', '--dry-run')
        self.assertFalse(self.checkout.exists())
        self.assertFalse(self.state.exists())
        self.run_cli()
        self.assertTrue((self.agents / 'one').is_symlink())
        original = (self.state / 'links.json').read_bytes()
        self.run_cli()
        self.assertEqual(original, (self.state / 'links.json').read_bytes())
        self.skill(self.agents / 'private-local')
        self.skill(self.checkout / 'private-repo')
        self.run_cli('setup', '--private-claude', '--adopt', 'private-local', ok=False)
        self.assertFalse((self.checkout / 'private-local').exists())
        self.assertFalse((self.agents / 'private-repo').exists())
        self.assertTrue((self.claude / 'private-local').is_symlink())
        self.assertEqual(self.git(self.checkout, 'status', '--porcelain'), '')
        self.git(self.checkout, 'remote', 'set-url', 'origin', str(self.base / 'other'))
        self.assertIn('identity mismatch', self.run_cli(ok=False))

    def test_whole_tree_adoption_and_claude_alias_backup(self):
        self.run_cli()
        self.skill(self.agents / 'new')
        (self.claude / 'new').symlink_to('../../.agents/skills/new')
        lock = self.home / '.agents/.skill-lock.json'
        metadata = {'version': 3, 'skills': {'new': {'sourceType': 'github', 'sourceUrl': 'https://github.com/example/skills', 'ref': 'v1'}}}
        lock.write_text(json.dumps(metadata))
        self.run_cli('sync')
        self.assertFalse((self.checkout / 'new').exists())
        self.run_cli('sync', '--adopt', 'new', '--dry-run')
        self.assertFalse((self.checkout / 'new').exists())
        self.run_cli('sync', '--adopt', 'new')
        self.assertTrue((self.agents / 'new').is_symlink())
        self.assertEqual((self.checkout / 'new/references/data.md').read_text(), 'reference\n')
        self.assertEqual((self.checkout / 'new/scripts/run.sh').stat().st_mode & 0o777, 0o755)
        self.assertEqual(json.loads(lock.read_text()), metadata)
        self.assertEqual(json.loads((self.state / 'provenance/new.json').read_text()), metadata['skills']['new'])
        self.assertEqual(len(list(self.state.glob('adopt-*/new'))), 2)
        self.assertIn('dirty', self.run_cli('sync', ok=False))

    def test_collision_and_installer_drift_never_overwrite(self):
        self.run_cli()
        (self.agents / 'one').unlink()
        self.skill(self.agents / 'one', 'installer replaced link')
        before = (self.checkout / 'one/SKILL.md').read_bytes()
        self.assertIn('content drift', self.run_cli('sync', '--adopt', 'one', ok=False))
        self.assertEqual((self.checkout / 'one/SKILL.md').read_bytes(), before)
        self.assertFalse((self.agents / 'one').is_symlink())
        self.skill(self.agents / 'two', 'canonical')
        self.skill(self.claude / 'two', 'different')
        self.assertIn('contents differ', self.run_cli('setup', '--adopt', 'two', ok=False))
        self.assertFalse((self.checkout / 'two').exists())

    def test_prune_only_owned_exact_links(self):
        self.run_cli()
        (self.claude / 'one').unlink()
        unrelated = self.home / 'unrelated'
        self.skill(unrelated)
        (self.claude / 'one').symlink_to(unrelated)
        self.skill(self.agents / 'private-secret')
        self.run_cli('setup', '--private-claude', ok=False)
        shutil.rmtree(str(self.source / 'one'))
        self.skill(self.source / 'two')
        self.publish()
        self.run_cli('sync')
        self.assertFalse(os.path.lexists(str(self.agents / 'one')))
        self.assertEqual((self.claude / 'one').resolve(), unrelated)
        self.assertTrue((self.claude / 'private-secret').is_symlink())
        self.assertTrue((self.agents / 'two').is_symlink())

    def test_dirty_offline_local_ahead_and_divergence(self):
        self.run_cli()
        (self.checkout / 'untracked').write_text('local')
        self.assertIn('dirty', self.run_cli('sync', ok=False))
        (self.checkout / 'untracked').unlink()
        moved = self.remote.with_name('offline.git')
        self.remote.rename(moved)
        self.run_cli('sync', ok=False)
        self.assertTrue((self.agents / 'one/SKILL.md').exists())
        self.run_cli()  # setup reuses local checkout offline
        moved.rename(self.remote)
        (self.checkout / 'local').write_text('local')
        self.git(self.checkout, 'add', '.')
        self.git(self.checkout, 'commit', '-m', 'local')
        before = self.git(self.checkout, 'rev-parse', 'HEAD')
        self.run_cli('sync', ok=False)  # no hidden push/rebase of unpublished local commits
        (self.source / 'remote').write_text('remote')
        self.publish()
        self.run_cli('sync', ok=False)
        self.assertEqual(self.git(self.checkout, 'rev-parse', 'HEAD'), before)
        self.assertEqual((self.checkout / 'local').read_text(), 'local')

    def assert_ignored_update_refused(self, original, expected):
        head = self.git(self.checkout, 'rev-parse', 'HEAD')
        receipts = (self.state / 'links.json').read_bytes()
        self.assertEqual(self.git(self.checkout, 'status', '--porcelain'), '')
        self.assertIn('ignored local content', self.run_cli('sync', ok=False))
        self.assertEqual(original.read_bytes(), expected)
        self.assertEqual(self.git(self.checkout, 'rev-parse', 'HEAD'), head)
        self.assertEqual((self.state / 'links.json').read_bytes(), receipts)

    def test_sync_preserves_private_ignored_file_incoming_same_path(self):
        self.run_cli()
        self.skill(self.checkout / 'private-local', 'private original')
        original = self.checkout / 'private-local/SKILL.md'
        expected = original.read_bytes()
        self.skill(self.source / 'private-local', 'upstream replacement')
        self.publish()
        self.assert_ignored_update_refused(original, expected)

    def test_sync_preserves_arbitrary_ignored_directory_replaced_by_file(self):
        self.run_cli()
        exclude = self.checkout / '.git/info/exclude'
        exclude.write_text(exclude.read_text() + '\ncache/\n')
        original = self.checkout / 'cache/subdir/data with space\nand newline'
        original.parent.mkdir(parents=True)
        original.write_bytes(b'ignored original')
        (self.source / 'cache').write_text('upstream file replaces directory')
        self.publish()
        self.assert_ignored_update_refused(original, b'ignored original')

    def test_sync_preserves_ignored_symlink_replaced_by_directory(self):
        self.run_cli()
        exclude = self.checkout / '.git/info/exclude'
        exclude.write_text(exclude.read_text() + '\nlinked-cache\n')
        outside = self.home / 'outside'
        outside.write_bytes(b'outside original')
        original = self.checkout / 'linked-cache'
        original.symlink_to(outside)
        (self.source / 'linked-cache').mkdir()
        (self.source / 'linked-cache/data').write_text('upstream file')
        self.publish()
        self.assert_ignored_update_refused(original, b'outside original')
        self.assertTrue(original.is_symlink())
        self.assertEqual(outside.read_bytes(), b'outside original')

    def test_merge_guard_preserves_ignored_content_created_after_preflight(self):
        self.run_cli()
        self.skill(self.source / 'private-race', 'upstream replacement')
        self.publish()
        head = self.git(self.checkout, 'rev-parse', 'HEAD')
        original = self.checkout / 'private-race/SKILL.md'
        preflight = MODULE.protect_ignored
        def concurrent_creation(root):
            preflight(root)
            original.parent.mkdir()
            original.write_bytes(b'created after preflight')
        args = ['skills.py', 'sync', '--repo', str(self.remote), '--no-prompt']
        with patch.dict(os.environ, self.env, clear=True), patch('sys.argv', args), patch.object(MODULE, 'protect_ignored', side_effect=concurrent_creation):
            with self.assertRaises(subprocess.CalledProcessError):
                MODULE.main()
        self.assertEqual(original.read_bytes(), b'created after preflight')
        self.assertEqual(self.git(self.checkout, 'rev-parse', 'HEAD'), head)

    def test_sync_allows_unrelated_update_while_preserving_ignored_private(self):
        self.run_cli()
        self.skill(self.checkout / 'private-local', 'private original')
        original = self.checkout / 'private-local/SKILL.md'
        expected = original.read_bytes()
        self.skill(self.source / 'two')
        self.publish()
        self.run_cli('sync')
        self.assertEqual(original.read_bytes(), expected)
        self.assertTrue((self.agents / 'two').is_symlink())

    def test_supported_local_installer_link_and_unrelated_link(self):
        self.run_cli()
        source = self.base / 'installer-source'
        self.skill(source / 'linked')
        (self.agents / 'linked').symlink_to(source / 'linked')
        (self.agents / 'plugin').symlink_to(source / 'linked')
        (self.home / '.agents/.skill-lock.json').write_text(json.dumps({'version': 3, 'skills': {'linked': {'sourceType': 'local', 'sourceUrl': str(source)}}}))
        self.run_cli('sync', '--adopt', 'linked')
        self.assertEqual((self.agents / 'linked').resolve(), self.checkout / 'linked')
        self.assertEqual((self.agents / 'plugin').resolve(), source / 'linked')
        self.assertTrue((source / 'linked/SKILL.md').exists())

    def test_escaping_link_rejected_without_loss(self):
        self.run_cli()
        self.skill(self.agents / 'unsafe')
        secret = self.home / 'secret'
        secret.write_text('not public')
        (self.agents / 'unsafe/escape').symlink_to(secret)
        self.run_cli('sync', '--adopt', 'unsafe', ok=False)
        self.assertFalse((self.checkout / 'unsafe').exists())
        self.assertFalse((self.agents / 'unsafe').is_symlink())
        self.assertEqual(secret.read_text(), 'not public')

    @unittest.skipUnless(os.environ.get('RUN_NPX_SKILLS_TEST') == '1', 'opt-in network installer proof')
    def test_real_global_npx_install_then_import(self):
        self.run_cli()
        source = self.base / 'npx-source'
        self.skill(source / 'installed')
        env = dict(self.env, XDG_STATE_HOME=str(self.home / '.state'), npm_config_cache=str(self.base / 'npm-cache'), DISABLE_TELEMETRY='1', DO_NOT_TRACK='1')
        subprocess.run(['npx', '--yes', 'skills@1.7.6', 'add', str(source), '-g', '-a', 'codex', '-a', 'claude-code', '-y'], env=env, cwd=str(self.base), check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
        lock = self.home / '.state/skills/.skill-lock.json'
        # Older published releases use the default instead of XDG_STATE_HOME.
        if not lock.exists():
            lock = self.home / '.agents/.skill-lock.json'
        before = lock.read_bytes()
        self.assertFalse((self.agents / 'installed').is_symlink())
        self.run_cli('sync', '--lock-file', str(lock))
        self.assertFalse((self.checkout / 'installed').exists())
        self.run_cli('sync', '--lock-file', str(lock), '--adopt', 'installed')
        self.assertEqual(lock.read_bytes(), before)
        self.assertTrue((self.agents / 'installed').is_symlink())
        self.assertTrue((self.checkout / 'installed/scripts/run.sh').exists())
        self.assertTrue((self.checkout / 'installed/references/data.md').exists())
        self.git(self.checkout, 'add', 'installed')
        self.git(self.checkout, 'commit', '-m', 'accept import')
        # A subsequent global installer add replaces our canonical symlink.
        (source / 'installed/references/data.md').write_text('upstream changed')
        subprocess.run(['npx', '--yes', 'skills@1.7.6', 'add', str(source), '-g', '-a', 'codex', '-a', 'claude-code', '-y'], env=env, cwd=str(self.base), check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
        self.assertFalse((self.agents / 'installed').is_symlink())
        self.assertIn('content drift', self.run_cli('setup', '--adopt', 'installed', ok=False))
        self.assertEqual((self.checkout / 'installed/references/data.md').read_text(), 'reference\n')
        self.assertEqual((self.agents / 'installed/references/data.md').read_text(), 'upstream changed')

    def test_failed_copy_verification_preserves_original(self):
        self.run_cli()
        self.skill(self.agents / 'new')
        real_copy = shutil.copytree
        def corrupt_copy(src, dst, *args, **kwargs):
            result = real_copy(src, dst, *args, **kwargs)
            if (Path(dst) / 'references/data.md').exists():
                (Path(dst) / 'references/data.md').write_text('corrupted copy')
            return result
        args = ['skills.py', 'sync', '--repo', str(self.remote), '--no-prompt', '--adopt', 'new']
        with patch.dict(os.environ, self.env, clear=True), patch('sys.argv', args), patch.object(MODULE.shutil, 'copytree', side_effect=corrupt_copy), contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, 'verification failed'):
                MODULE.main()
        self.assertFalse((self.checkout / 'new').exists())
        self.assertFalse((self.agents / 'new').is_symlink())
        self.assertEqual((self.agents / 'new/references/data.md').read_text(), 'reference\n')

    def test_nested_private_directory_is_not_imported(self):
        self.run_cli()
        self.skill(self.agents / 'new')
        (self.agents / 'new/private-data').mkdir()
        (self.agents / 'new/private-data/secret').write_text('local only')
        self.run_cli('sync', '--adopt', 'new', ok=False)
        self.assertFalse((self.checkout / 'new').exists())
        self.assertEqual((self.agents / 'new/private-data/secret').read_text(), 'local only')

    def test_failed_link_rolls_back_original_and_keeps_verified_copy(self):
        self.run_cli()
        self.skill(self.agents / 'new')
        args = ['skills.py', 'sync', '--repo', str(self.remote), '--no-prompt', '--adopt', 'new']
        with patch.dict(os.environ, self.env, clear=True), patch('sys.argv', args), patch.object(Path, 'symlink_to', side_effect=OSError('injected link failure')), contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(OSError, 'injected'):
                MODULE.main()
        self.assertFalse((self.agents / 'new').is_symlink())
        self.assertTrue((self.agents / 'new/references/data.md').exists())
        self.assertTrue((self.checkout / 'new/references/data.md').exists())

    def test_claude_only_adoption_and_unowned_links_preserved(self):
        self.run_cli()
        self.skill(self.claude / 'claude-only')
        self.run_cli('sync', '--adopt', 'claude-only')
        self.assertTrue((self.agents / 'claude-only').is_symlink())
        self.assertTrue((self.claude / 'claude-only').is_symlink())


if __name__ == '__main__':
    unittest.main()
