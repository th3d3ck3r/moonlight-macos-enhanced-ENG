#!/usr/bin/env python3
"""Audit shipped UI literals, language resources, and LAN permission declarations."""
import argparse
import pathlib
import plistlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
# Recognition-only literals, never labels or messages. They preserve detection of
# non-English audio device names and system diagnostics on non-English macOS.
RECOGNITION = {
    'Limelight/Stream/Connection.m': {'耳机', '音箱'},
    'Limelight/macOS/ViewControllers/HostsViewController.m': {'请求超时', '网络连接已中断', '无法连接'},
    'Limelight/macOS/ViewControllers/DebugLogParser.swift': {'tls错误', '证书无效', '网络连接已中断', '请求超时', '无法连接服务器'},
}
CJK = re.compile(r'[\u3400-\u9fff]')
LITERAL = re.compile(r'"((?:\\.|[^"\\])*)"')


def audit_source():
    errors = []
    for p in (ROOT / 'Limelight').rglob('*'):
        if not p.is_file() or p.suffix not in {'.swift', '.m', '.h', '.strings', '.storyboard', '.plist'}:
            continue
        rel = p.relative_to(ROOT).as_posix()
        # Source comments may describe upstream internals in another language.
        text = re.sub(r'/\*.*?\*/', '', p.read_text(), flags=re.S)
        for number, line in enumerate(text.splitlines(), 1):
            if line.lstrip().startswith('//'):
                continue
            for m in LITERAL.finditer(line):
                if CJK.search(m[1]) and m[1] not in RECOGNITION.get(rel, set()):
                    errors.append(f'{rel}:{number}: non-English UI literal {m[1]}')
    project = (ROOT / 'Moonlight.xcodeproj/project.pbxproj').read_text()
    if re.search(r'zh[-_]|zh\.lproj', project):
        errors.append('Chinese localization remains in macOS project')
    return errors


def audit_plist(path):
    info = plistlib.loads(path.read_bytes())
    errors = []
    if info.get('CFBundleDevelopmentRegion') != 'en' or info.get('CFBundleLocalizations') != ['en']:
        errors.append(f'{path}: bundle must explicitly use English only')
    if not info.get('NSLocalNetworkUsageDescription'):
        errors.append(f'{path}: missing Local Network permission description')
    if '_nvstream._tcp' not in info.get('NSBonjourServices', []):
        errors.append(f'{path}: missing GameStream Bonjour service')
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--app', type=pathlib.Path)
    args = parser.parse_args()
    errors = audit_source()
    plist = ROOT / 'Limelight/macOS/Supporting Files/Info.plist'
    if args.app:
        plist = args.app / 'Contents/Info.plist'
        for p in (args.app / 'Contents/Resources').rglob('*.lproj'):
            if p.name not in {'Base.lproj', 'en.lproj'}:
                errors.append(f'Unexpected localization in built bundle: {p}')
    errors += audit_plist(plist)
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print('PASS: English UI literals, English localization, Local Network description and Bonjour service')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
