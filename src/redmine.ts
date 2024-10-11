export interface News {
  id: number;
  title: string;
  summary: string;
  description: string;
  created_on: string; // ISO date string
  comments_count: number;
  project: Project | null;
  author: Author;
}

export interface Project {
  id: number;
  name: string;
  identifier: string;
}

export interface Author {
  id: number;
  login: string;
  firstname: string;
  lastname: string;
}
