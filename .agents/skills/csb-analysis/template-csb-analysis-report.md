```markdown
# <benchmark/run> CSB Analysis

## Summary
Insert a Bottom Line Up From summary here. Try to fit into 3-4 sentences.

Include information on:
- hypothesis;
- RFC Linux kernel patches;
- further investigation directions for user that are directly supported by evidence.

Do not include information on:
- actions that were carried out and finished successfully;
- further investigation directions not supported by directly available evidence.

## Result Identity
- run:
- benchmark:
- kernel:
- host/architecture:
- result artifacts:

## Performance Degradation
In benchmark `<name>` we observe that performance starts degrading when `<execution-unit>` is >= `<Y>`.

| execution units | <prime-metric> | vs baseline | vs peak | success | latency | notes |
| --- | ---: | ---: | ---: | ---: | ---: | --- |

## Monitor Correlation
Monitor values that inversely increase as performance degrades:

| monitor | baseline | peak | degradation point | largest count | relation | interpretation |
| --- | ---: | ---: | ---: | ---: | --- | --- |

Monitor values that directly decrease as performance degrades:

| monitor | baseline | peak | degradation point | largest count | relation | interpretation |
| --- | ---: | ---: | ---: | ---: | --- | --- |

Other monitor signals:

| monitor | movement | interpretation |
| --- | --- | --- |

## Widening Kernel Functions
These are the functions where more cycles/samples/wait appear as execution units increase:

| function | evidence | source path | local history | notes |
| --- | --- | --- | --- | --- |

## Kernel Change Artifacts
- `<function>`: `[kernel changes](<benchmark>-<function>-kernel-changes.md)`

## Kernel Commit Analysis
List commits in the Linux kernel, between Linux release (e.g. 6.6) used for benchmarking and the latest release, which affect the hot code paths of the benchmark run. The goal here is find commits that, if not already present, would yield better performance if backported. When scanning commits, don't look at merges, only consider individual change commits.

## Kernel Patch Artifact
- patch series:
- patch file:
- safety/implications:
- patch confidence:
- validation matrix:

## Hypothesis
State the likely bottleneck, confidence, and evidence limitations.

## Evidence Gaps
List missing artifacts, permissions, source trees, symbols, or follow-up data needed to confirm or reject the hypothesis.
```
