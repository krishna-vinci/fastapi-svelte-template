<script lang="ts">
  import { onMount } from 'svelte';

  type StatusResponse = {
    backend: string;
    database: {
      status: string;
      latency_ms?: number;
      message?: string;
    };
  };

  let status: StatusResponse | null = null;
  let error: string | null = null;
  let loading = true;

  const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:8000';

  onMount(async () => {
    try {
      const res = await fetch(`${API_URL}/api/status`);
      if (!res.ok) {
        throw new Error(`Request failed with status ${res.status}`);
      }
      status = await res.json();
    } catch (err) {
      error = err instanceof Error ? err.message : 'Unknown error';
    } finally {
      loading = false;
    }
  });
</script>

<main class="mx-auto max-w-2xl space-y-6">
  <section class="space-y-2 text-center">
    <h1 class="text-3xl font-semibold">FastAPI + Svelte Template</h1>
    <p class="text-muted-foreground">Deploy-ready stack with database integration.</p>
  </section>

  {#if loading}
    <div class="rounded-lg border p-4 text-center">
      Checking backend connectivity...
    </div>
  {:else if error}
    <div class="rounded-lg border border-red-500 bg-red-50 p-4 text-red-700">
      <p class="font-semibold">Connectivity check failed</p>
      <p>{error}</p>
    </div>
  {:else if status}
    <div class="rounded-lg border p-4 space-y-3">
      <div class="flex items-center justify-between">
        <span class="font-semibold">Backend</span>
        <span class={status.backend === 'ok' ? 'text-green-600' : 'text-yellow-600'}>
          {status.backend === 'ok' ? 'Reachable ✅' : 'Degraded ⚠️'}
        </span>
      </div>

      <div class="flex items-center justify-between">
        <span class="font-semibold">Database</span>
        {#if status.database.status === 'ok'}
          <span class="text-green-600">
            Connected in {status.database.latency_ms} ms ✅
          </span>
        {:else}
          <span class="text-red-600">
            Error: {status.database.message}
          </span>
        {/if}
      </div>
    </div>
  {/if}

  <section class="rounded-lg border p-4 space-y-2">
    <h2 class="text-xl font-semibold">Next steps</h2>
    <ul class="list-disc pl-5 text-sm text-muted-foreground space-y-1">
      <li>Update backend routes in <code>backend/main.py</code></li>
      <li>Add your UI pages using shadcn-svelte components</li>
      <li>Run <code>./dev.sh</code> for hot reload in Docker</li>
    </ul>
  </section>
</main>
