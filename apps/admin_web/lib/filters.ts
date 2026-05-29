export type SearchValue = string | string[] | undefined;
export type SearchMap = Record<string, SearchValue>;
export type SearchInput = SearchMap | Promise<SearchMap> | undefined;

export async function resolveSearch(input: SearchInput): Promise<SearchMap> {
  if (!input) return {};
  return await input;
}

export function queryString(value: SearchValue): string {
  if (Array.isArray(value)) return value[0] ?? '';
  return value ?? '';
}

export function normalizedDay(value: string, fallback = '2026-03-09'): string {
  if (!value) return fallback;
  return /^\d{4}-\d{2}-\d{2}$/.test(value) ? value : fallback;
}

export function containsQuery(value: string, query: string): boolean {
  if (!query) return true;
  return value.toLowerCase().includes(query.toLowerCase());
}
