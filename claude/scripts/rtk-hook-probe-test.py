#!/usr/bin/env python3
"""Regression tests for rtk-hook-probe.py. Run directly: no dependencies.

    ./claude/scripts/rtk-hook-probe-test.py

The probe answers one question -- will Claude Code run `rtk hook claude` on a
Bash command? -- and has been wrong about it three times: once by trusting a
file rtk never writes, once by ignoring the matcher, and once by matching the
matcher with the wrong rule. Each fix asserted the property the previous defect
violated. These cases pin the whole property instead.
"""

import json
import os
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import importlib.util

_spec = importlib.util.spec_from_file_location(
    "rtk_hook_probe",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "rtk-hook-probe.py"),
)
probe = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(probe)


def registration(command, matcher="Bash", event="PreToolUse"):
    entry = {"hooks": [{"type": "command", "command": command}]}
    if matcher is not None:
        entry["matcher"] = matcher
    return {"hooks": {event: [entry]}}


class MatcherSemantics(unittest.TestCase):
    """Claude Code's own rules, from the matcher table in its hooks docs."""

    def test_match_all_forms(self):
        for matcher in (None, "", "*"):
            self.assertTrue(probe.matches_bash(matcher), matcher)

    def test_exact_name(self):
        self.assertTrue(probe.matches_bash("Bash"))
        self.assertFalse(probe.matches_bash("Edit"))
        self.assertFalse(probe.matches_bash("NotebookEdit"))

    def test_exact_list_pipe_and_comma(self):
        # Both separators are exact-match lists, not alternation patterns.
        for matcher in ("Bash|Edit", "Edit|Bash", "Bash, Edit", "Edit,Bash",
                        "Edit , Bash"):
            self.assertTrue(probe.matches_bash(matcher), matcher)
        for matcher in ("Edit|Write", "Edit, Write"):
            self.assertFalse(probe.matches_bash(matcher), matcher)

    def test_regex_is_unanchored(self):
        # The defect this file exists for: `ash.*` is a live registration.
        for matcher in ("ash.*", "^Bash$", ".*", "Ba.h", "(Bash)"):
            self.assertTrue(probe.matches_bash(matcher), matcher)
        for matcher in ("^Edit$", "Note.*"):
            self.assertFalse(probe.matches_bash(matcher), matcher)

    def test_hyphen_stays_on_the_exact_path(self):
        # A hyphen is in the exact-match set, so this is a name, not a pattern.
        self.assertFalse(probe.matches_bash("code-reviewer"))

    def test_uncompilable_pattern_is_not_a_match(self):
        self.assertFalse(probe.matches_bash("Bash("))

    def test_non_string_matcher(self):
        for matcher in (1, [], {}, True):
            self.assertFalse(probe.matches_bash(matcher), matcher)


class CommandClassification(unittest.TestCase):
    def test_absolute_path_is_pinned(self):
        for command in ("/opt/homebrew/bin/rtk hook claude",
                        "/usr/local/bin/rtk hook claude"):
            self.assertEqual(probe.classify(command), "pinned", command)

    def test_bare_and_relative_are_both_bare(self):
        # A relative path depends on a working directory the hook cannot
        # predict, so it is no safer than the bare name.
        for command in ("rtk hook claude", "./rtk hook claude",
                        "bin/rtk hook claude", "../bin/rtk hook claude"):
            self.assertEqual(probe.classify(command), "bare", command)

    def test_other_commands_are_not_rtk(self):
        for command in ("rtk hook codex", "rtk", "rtk hook",
                        "/usr/bin/prettier --write", "rtkx hook claude", ""):
            self.assertIsNone(probe.classify(command), command)

    def test_unparseable_command(self):
        self.assertIsNone(probe.classify('rtk hook claude "unclosed'))


class EndToEnd(unittest.TestCase):
    """Run the probe as the guard runs it: as a process, on a real file."""

    def run_probe(self, settings):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "settings.json")
            with open(path, "w", encoding="utf-8") as handle:
                if isinstance(settings, str):
                    handle.write(settings)
                else:
                    json.dump(settings, handle)
            result = subprocess.run(
                [sys.executable, os.path.join(os.path.dirname(
                    os.path.abspath(__file__)), "rtk-hook-probe.py"), path],
                capture_output=True, text=True, check=True)
            return result.stdout.strip()

    def test_pinned(self):
        self.assertEqual(
            self.run_probe(registration("/opt/homebrew/bin/rtk hook claude")),
            "pinned")

    def test_bare(self):
        self.assertEqual(self.run_probe(registration("rtk hook claude")),
                         "bare")

    def test_wrong_event(self):
        self.assertEqual(
            self.run_probe(registration("/usr/bin/rtk hook claude",
                                        event="PostToolUse")),
            "missing")

    def test_wrong_matcher(self):
        self.assertEqual(
            self.run_probe(registration("/usr/bin/rtk hook claude",
                                        matcher="Edit")),
            "missing")

    def test_stray_text_is_not_a_hook(self):
        self.assertEqual(self.run_probe({"env": {"NOTE": "rtk hook claude"}}),
                         "missing")

    def test_bare_wins_over_pinned(self):
        # Two registrations, one fragile: report the one that fails silently.
        settings = {"hooks": {"PreToolUse": [
            {"matcher": "Bash", "hooks": [
                {"type": "command", "command": "/usr/bin/rtk hook claude"}]},
            {"matcher": "Bash", "hooks": [
                {"type": "command", "command": "rtk hook claude"}]}]}}
        self.assertEqual(self.run_probe(settings), "bare")

    def test_malformed_files(self):
        for settings in ("not json", "[]", '"a string"', "{}",
                         '{"hooks": null}', '{"hooks": {"PreToolUse": {}}}'):
            self.assertEqual(self.run_probe(settings), "missing", settings)

    def program(self, settings):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "settings.json")
            with open(path, "w", encoding="utf-8") as handle:
                json.dump(settings, handle)
            result = subprocess.run(
                [sys.executable, os.path.join(os.path.dirname(
                    os.path.abspath(__file__)), "rtk-hook-probe.py"),
                 "--program", path],
                capture_output=True, text=True, check=True)
            return result.stdout.strip()

    def test_program_reports_the_selected_path(self):
        # The caller checks this path still exists; a pin to a path that has
        # gone away fails as silently as never pinning.
        self.assertEqual(
            self.program(registration("/opt/homebrew/bin/rtk hook claude")),
            "/opt/homebrew/bin/rtk")
        self.assertEqual(self.program(registration("rtk hook claude")), "rtk")

    def test_program_is_empty_when_no_hook(self):
        self.assertEqual(self.program({"env": {"NOTE": "x"}}), "")
        self.assertEqual(
            self.program(registration("/usr/bin/rtk hook claude",
                                      matcher="Edit")), "")

    def test_program_agrees_with_the_state_it_reported(self):
        # Both modes must select the same registration, or the guard would
        # check the existence of a path it did not classify.
        settings = {"hooks": {"PreToolUse": [
            {"matcher": "Bash", "hooks": [
                {"type": "command", "command": "/usr/bin/rtk hook claude"}]},
            {"matcher": "Bash", "hooks": [
                {"type": "command", "command": "rtk hook claude"}]}]}}
        self.assertEqual(self.run_probe(settings), "bare")
        self.assertEqual(self.program(settings), "rtk")

    def test_absent_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = subprocess.run(
                [sys.executable, os.path.join(os.path.dirname(
                    os.path.abspath(__file__)), "rtk-hook-probe.py"),
                 os.path.join(tmp, "nope.json")],
                capture_output=True, text=True, check=True)
            self.assertEqual(result.stdout.strip(), "missing")


if __name__ == "__main__":
    unittest.main(verbosity=2)
