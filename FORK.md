# NymphAI Goblins fork

This is NymphAI's independently maintained fork of Spritely Goblins. Upstream
is https://codeberg.org/spritely/goblins. This repository is not an upstream
Spritely release. Original copyright notices, authorship, and the Apache 2.0
license in COPYING and LICENSE.txt are retained.

The base is upstream 0.18.0, commit
`d42d3a4ff560ecd2a1ac8ef0e44e52ad9e20bdb6`. The native CapTP correction and its
regression tests are commits in this repository, not patches applied by a
consumer during its build.

## Maintained change

Unanswered native questions break when their CapTP session severs. Their
handlers live on the existing weak question finders and are cleared on
settlement. Handlers hold weak promise/resolver references; late fulfillment
and registration racing teardown are handled without overwriting accepted
results or severing an already completed third-party handoff.

This changes no wire operation. It preserves 0.18 framing and does not import
upstream main's later framing changes. The fixed runtime returns the existing
`captp-session-severed` condition. Connection loss does not establish whether a
remote effect occurred and must not trigger an automatic retry.

## Validation and maintenance

The native source change passed 145 upstream unit checks, 24 matching OCapN
wire tests, and abrupt-death plus explicit-abort TCP/TLS tests in an isolated
BuildBuddy run:
https://app.buildbuddy.io/invocation/8d6ee8b1-918b-4f22-92ac-38673c6720c2

That receipt precedes the fork's documentation and modification notices.
Consumers should pin the tested fork commit and archive hash, and verify the
published archive through the same tests before promotion. Fabric's manual
proof lives under `fabric/experiments/reply-capabilities` in its monorepo.
No scheduled or broad automatic CI pipeline is added by this fork.

- Preserve upstream history. `upstream/0.18` names the imported release base;
  the local `upstream` remote points to Codeberg.
- Land native fixes through feature branches and pull requests. Keep changes
  narrow and retain regressions with them.
- Update to new upstream releases deliberately through a pull request with
  source and protocol compatibility reviewed. Pin matching OCapN suite
  revisions; do not translate bytes merely to satisfy mismatched versions.
- Keep existing HACKING/build instructions. For 0.18 the compatible wire suite
  is `74db78f08a40efba1e2b975d809374ff0e7acf60`; later upstream suite commits
  changed framing while retaining the same advertised version string.
- Application deadlines, durable settlement and offered-action cancellation
  remain application responsibilities.

## Contributions

AI-assisted contributions are permitted in this fork, subject to review,
correct attribution and executable evidence. Upstream's contribution policy
still governs submissions to Codeberg; this fork does not submit generated
patches or reports there or represent them as upstream-approved work.
