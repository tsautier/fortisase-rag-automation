#!/usr/bin/env python3
"""
Discover Terraform resources in the repo, check whether each resource exists in the current
Terraform state, and generate a JUnit-format XML report (for Jenkins Test Results Analyzer).
"""

import argparse
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from datetime import datetime
from typing import List, Tuple
try:
    from datetime import UTC
except ImportError:
    from datetime import timezone
    UTC = timezone.utc

TF_GLOB_PATHS = ["modules/**/*.tf", "main.tf"]

RESOURCE_RE = re.compile(r'^resource\s+"([^"]+)"\s+"([^"]+)"')
MODULE_PATH_RE = re.compile(r'modules/([^/]+)/')


def discover_resources(repo_root: str) -> List[Tuple[str, str, str]]:
    """Return a list of (module, resource_type, resource_name) discovered in .tf files.

    Only files under `modules/<module>/` and `main.tf` are scanned. Resources in root
    `main.tf` are returned with module 'root'.
    """
    resources = []

    # Walk the repo for .tf files in modules/ or main.tf
    for root, dirs, files in os.walk(repo_root):
        for fname in files:
            if not fname.endswith('.tf'):
                continue
            fpath = os.path.join(root, fname)

            # We only include files under modules/ or the repo root main.tf
            rel = os.path.relpath(fpath, repo_root)
            module = None
            m = MODULE_PATH_RE.search(rel)
            if m:
                module = m.group(1)
            elif os.path.basename(rel) == 'main.tf' and os.path.dirname(rel) in ('.', ''):
                module = 'root'
            else:
                # Skip other .tf files (like provider files in modules root or nested)
                continue

            try:
                with open(fpath, 'r', encoding='utf-8') as fh:
                    for line in fh:
                        line = line.strip()
                        mres = RESOURCE_RE.match(line)
                        if mres:
                            rtype, rname = mres.group(1), mres.group(2)
                            resources.append((module, rtype, rname))
            except Exception as e:
                print(f"Warning: could not read {fpath}: {e}", file=sys.stderr)
    return resources


def build_terraform_target(module: str, rtype: str, rname: str) -> str:
    """Return the terraform-target-like string we expect in `terraform state list`.

    For resources inside modules, Terraform state entries normally look like:
      module.<module>.<resource_type>.<resource_name>

    For root resources, return `<resource_type>.<resource_name>`
    """
    if module == 'root':
        return f"{rtype}.{rname}"
    else:
        return f"module.{module}.{rtype}.{rname}"


def get_terraform_state_list() -> List[str]:
    """Run `terraform state list` and return lines. If terraform is not available, raise.
    """
    try:
        completed = subprocess.run(["terraform", "state", "list"], capture_output=True, text=True, check=True)
        lines = [ln.strip().split("[",1)[0] for ln in completed.stdout.splitlines() if ln.strip()]
        return lines
    except FileNotFoundError:
        raise RuntimeError("terraform binary not found in PATH")
    except subprocess.CalledProcessError as e:
        # If the working directory isn't a terraform workspace or no state exists, state list returns non-zero
        # We'll return empty list in that case, but surface a message
        print("Note: `terraform state list` failed. This likely means no terraform state exists in this directory.", file=sys.stderr)
        print(f"terraform stdout: {e.stdout}", file=sys.stderr)
        print(f"terraform stderr: {e.stderr}", file=sys.stderr)
        return []


def resource_exists_in_state(target: str, state_list: List[str]) -> bool:
    return target in state_list


def write_junit_xml(results: List[Tuple[str, str, str, bool]], output_path: str):
    """Write a JUnit XML with one testcase per resource.

    results: list of (module, rtype, rname, exists)
    """
    testsuite = ET.Element('testsuite')
    testsuite.set('name', 'terraform-resource-existence')
    testsuite.set('tests', str(len(results)))
    failures = sum(0 if r[3] else 1 for r in results)
    testsuite.set('failures', str(failures))
    testsuite.set('timestamp', datetime.now(UTC).isoformat() + 'Z')

    for module, rtype, rname, exists in results:
        tc = ET.SubElement(testsuite, 'testcase')
        tc.set('classname', f"terraform.{module}.{rtype}")
        tc.set('name', rname)
        if not exists:
            failure = ET.SubElement(tc, 'failure')
            failure.set('message', 'Resource not present in terraform state')
            failure.text = f"Resource module={module} type={rtype} name={rname} not found in state"

    tree = ET.ElementTree(testsuite)
    os.makedirs(os.path.dirname(output_path) or '.', exist_ok=True)
    tree.write(output_path, encoding='utf-8', xml_declaration=True)
    print(f"JUnit XML written to: {output_path}")


def main():
    parser = argparse.ArgumentParser(description='Discover TF resources, check state, emit JUnit XML')
    parser.add_argument('--repo-root', default='.', help='Root of repository to scan (default: .)')
    parser.add_argument('--output', default='./test_results.xml', help='Output JUnit XML path')

    args = parser.parse_args()

    resources = discover_resources(args.repo_root)
    if not resources:
        print('No resources discovered. Exiting.')
        sys.exit(0)

    print(f"Discovered {len(resources)} resources. Checking presence...")

    state_list = []
    try:
        state_list = get_terraform_state_list()
    except RuntimeError as e:
        print(f"Error obtaining terraform state: {e}", file=sys.stderr)
        sys.exit(2)

    results = []
    for module, rtype, rname in resources:
        target = build_terraform_target(module, rtype, rname)
        exists = False
        exists = resource_exists_in_state(target, state_list)
        results.append((module, rtype, rname, exists))
        status = 'OK' if exists else 'MISSING'
        print(f"{status}: {target}")

    write_junit_xml(results, args.output)


if __name__ == '__main__':
    main()
