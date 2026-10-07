#!/usr/bin/env python3
"""Guard the manual-update variant against known updater components and feeds."""
import argparse
import pathlib
import plistlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
UPDATER = re.compile(r'Sparkle|SUFeedURL|SUEnableAutomaticChecks|SUAutomaticallyUpdate|SUUpdater|SPUUpdater')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', type=pathlib.Path)
    args = parser.parse_args()
    errors = []
    for path in (ROOT / 'Limelight').rglob('*'):
        if path.is_file() and path.suffix in {'.m', '.h', '.swift', '.plist'}:
            text = path.read_text()
            if UPDATER.search(text):
                errors.append(f'{path}: updater component or configuration found')
    for name in ['AboutViewController.m', 'SettingsHostingController.swift']:
        text = (ROOT / 'Limelight/macOS/ViewControllers' / name).read_text()
        if 'https://github.com/skyhua0224/moonlight-macos-enhanced' in text:
            errors.append(f'{name}: original repository link remains')
        if 'th3d3ck3r/moonlight-macos-enhanced-ENG' not in text:
            errors.append(f'{name}: maintained repository link missing')
    about = (ROOT / 'Limelight/macOS/ViewControllers/AboutViewController.m').read_text()
    if 'Manual updates only.' not in about:
        errors.append('About window: manual update notice missing')
    if args.app:
        contents = args.app / 'Contents'
        info = plistlib.loads((contents / 'Info.plist').read_bytes())
        if any(UPDATER.search(key) for key in info):
            errors.append('Packaged Info.plist contains updater configuration')
        for path in contents.rglob('*'):
            if UPDATER.search(path.name):
                errors.append(f'{path}: packaged updater component found')
        binary = (contents / 'MacOS/Moonlight').read_bytes()
        if b'Sparkle.framework' in binary or b'SUFeedURL' in binary:
            errors.append('Packaged executable contains known updater dependency/feed')
        # Clang uses UTF-16 NSString constants when a literal contains Unicode.
        notice = 'Manual updates only.'
        if not any(notice.encode(encoding) in binary for encoding in ('utf-8', 'utf-16-le', 'utf-16-be')):
            errors.append('Packaged executable lacks manual-update notice')
    if errors:
        raise SystemExit('\n'.join(errors))
    print('Manual update audit passed: owned links, notice, no known updater/feed components')


if __name__ == '__main__':
    main()
