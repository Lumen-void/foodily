const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL ?? 'http://localhost:8080/v1';

export async function apiFetch<T>(path: string): Promise<T | null> {
  try {
    const response = await fetch(`${API_BASE}${path}`, {
      headers: {
        Authorization:
          process.env.NEXT_PUBLIC_ADMIN_TOKEN ?? 'Bearer replace_me',
        'x-role': 'ADMIN',
      },
      cache: 'no-store',
    });

    if (!response.ok) {
      return null;
    }

    const payload = (await response.json()) as {
      success?: boolean;
      data?: T;
    };

    if (payload.success === false) {
      return null;
    }

    if (payload.success === true && payload.data) {
      return payload.data;
    }

    return payload as unknown as T;
  } catch {
    return null;
  }
}
