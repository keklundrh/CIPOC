# CIPOC pipeline image — runs the LangGraph orchestrator as a batch job.
#
# Build context is the REPO ROOT (not a package subdir), so the BuildConfig
# for this image must set contextDir: "." — unlike the workbench image.
#
# Base: UBI9 Python 3.12 — same family as the workbench image, RHEL-compatible
# for OpenShift, and closer to the Databricks Runtime target than Debian slim.
#
# documents/ (NAACCR dictionaries) is deliberately NOT baked in: it is
# gitignored and may hold restricted reference data. Mount it at /app/documents
FROM registry.access.redhat.com/ubi9/python-312:latest
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# UBI images default to uid 1001 (`default`); pip install needs root to write
# egg-info during the build, so switch to root explicitly (workbench pattern).
USER 0

# Copy the package definition first for layer caching: dependency layer only
# rebuilds when pyproject.toml changes.
COPY pyproject.toml README.md ./
COPY src ./src
COPY config ./config

# scripts/ is needed for `python -m scripts.run_case_state` (the Job entrypoint).
COPY scripts ./scripts

RUN pip install --no-cache-dir .

# Run as an arbitrary non-root UID (OpenShift SCC-friendly): the pod gets a
# random UID in group 0, so group-writable beats chown-to-nobody.
RUN mkdir -p /data && chmod 775 /data

USER 1001

# Default command matches the batch entrypoint; the Job supplies --notes/--output
# args. Override the whole command+args in the Job when invoking other modules.
CMD ["python", "-m", "scripts.run_case_state"]
