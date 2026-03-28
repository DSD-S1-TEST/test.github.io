/// <reference types="vite/client" />

declare module 'front-matter' {
    function fm<T>(content: string): { attributes: T; body: string; frontmatter: string };
    export = fm;
}
