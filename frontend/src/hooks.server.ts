import type { Handle } from '@sveltejs/kit';

const API_BASE_URL = process.env.API_BASE_URL || 'http://backend:8000';

export const handle: Handle = async ({ event, resolve }) => {
	if (event.url.pathname.startsWith('/api')) {
		const targetUrl = `${API_BASE_URL}${event.url.pathname}${event.url.search}`;
		const response = await fetch(new Request(targetUrl, { ...event.request }));
		return new Response(response.body, { status: response.status, headers: response.headers });
	}
	return resolve(event);
};
