import fm from 'front-matter';

export interface NewsAttributes {
  title: string;
  date: string;
  author: string;
  summary: string;
  latest?: boolean;
}

export interface MemberAttributes {
  name: string;
  role: string;
  avatar: string;
  skills: string;
}

export interface ReleaseAttributes {
  title: string;
  date: string;
  publisher: string;
  summary: string;
  latest?: boolean;
  pdf_url?: string;
  github_url?: string;
}

export function parseFrontMatter<T>(raw: string) {
  return fm<T>(raw);
}
