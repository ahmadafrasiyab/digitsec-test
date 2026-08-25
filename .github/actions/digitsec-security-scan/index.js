const fs = require('fs');

function getInput(name) {
  // GitHub Actions only replaces spaces with underscores when building the
  // INPUT_* env var name - hyphens are preserved as-is (matching @actions/core's
  // getInput), so 's4-api-token' becomes INPUT_S4-API-TOKEN, not INPUT_S4_API_TOKEN.
  const key = 'INPUT_' + name.replace(/ /g, '_').toUpperCase();
  return process.env[key] || '';
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const apiToken = getInput('s4-api-token');
  const orgId = getInput('s4-org-id');
  let baseUrl = getInput('s4-base-url') || 'https://app.digitsec.com/';
  if (!baseUrl.endsWith('/')) baseUrl += '/';
  const pollIntervalSeconds = parseInt(getInput('poll-interval-seconds') || '15', 10);
  const pollTimeoutMinutes = parseInt(getInput('poll-timeout-minutes') || '30', 10);

  if (!apiToken || !orgId) {
    console.error('s4-api-token and s4-org-id are required inputs.');
    process.exitCode = 1;
    return;
  }

  const eventPath = process.env.GITHUB_EVENT_PATH;
  if (!eventPath || !fs.existsSync(eventPath)) {
    console.error('Could not find the GitHub event payload. This action must run on a pull_request event.');
    process.exitCode = 1;
    return;
  }
  const event = JSON.parse(fs.readFileSync(eventPath, 'utf8'));
  const pr = event.pull_request;
  if (!pr) {
    console.error('No pull_request object found in the event payload. This action only supports pull_request events (opened, reopened, synchronize).');
    process.exitCode = 1;
    return;
  }

  const [owner, repo] = process.env.GITHUB_REPOSITORY.split('/');
  const body = {
    orgId: orgId,
    owner: owner,
    repo: repo,
    pr_number: pr.number,
    head_sha: pr.head.sha,
    base_sha: pr.base.sha,
    ref: pr.head.ref,
  };

  console.log(`Starting DigitSec security scan for ${owner}/${repo}#${pr.number} (${pr.head.sha})`);

  const startResp = await fetch(baseUrl + 'api/github-action/scan', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-access-token': apiToken,
    },
    body: JSON.stringify(body),
  });

  if (!startResp.ok) {
    console.error(`Failed to start scan: ${startResp.status} ${await startResp.text()}`);
    process.exitCode = 1;
    return;
  }
  const { scanId, gateUrl } = await startResp.json();
  console.log(`Scan started: ${scanId}`);
  console.log(`Track progress, or bypass a failed gate (Admin/Workspace Manager only), at: ${gateUrl}`);

  const deadline = Date.now() + pollTimeoutMinutes * 60 * 1000;
  const statusUrl = `${baseUrl}api/github-action/scan/${scanId}?orgId=${encodeURIComponent(orgId)}`;

  while (Date.now() < deadline) {
    await sleep(pollIntervalSeconds * 1000);

    const statusResp = await fetch(statusUrl, {
      headers: { 'x-access-token': apiToken },
    });
    if (!statusResp.ok) {
      console.log(`Status check failed with ${statusResp.status}, retrying...`);
      continue;
    }
    const scan = await statusResp.json();
    console.log(`Scan status: ${scan.status}`);

    if (scan.status === 'completed') {
      if (scan.isSecurityGatePassed === true) {
        console.log('Security gate passed.');
        return;
      } else if (scan.isSecurityGatePassed === false) {
        console.error(`Security gate FAILED. Critical: ${scan.Critical}, High: ${scan.High}, Medium: ${scan.Medium}, Low: ${scan.Low}`);
        console.error(`To bypass (Admin/Workspace Manager only): ${scan.gateUrl}`);
        process.exitCode = 1;
        return;
      } else {
        console.log('Scan completed. No security gate configured for this workspace - treating as passed.');
        return;
      }
    } else if (scan.status === 'error') {
      console.error('The scan failed to complete.');
      process.exitCode = 1;
      return;
    }
  }

  console.error(`Timed out after ${pollTimeoutMinutes} minute(s) waiting for the scan to complete.`);
  process.exitCode = 1;
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
