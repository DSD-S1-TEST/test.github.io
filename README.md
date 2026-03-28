# DSD-S1 Team Frontend Hub

This project is a completely Markdown-driven, decentralized static site built for the DSD-S1 team. It is designed so that non-developers can easily maintain the website contents intuitively using pure Markdown files, complete with metadata parsing (YAML front-matter) and automated dynamic data-visualization (Mermaid.js).

## 🛠 Technology Stack & Version Information

Below is the exhaustive list of the core technologies, libraries, and their respective versions used in this project:

### Framework & Build Tool
- **React**: `v19.2.4` (Core frontend library for building the UI components)
- **Vite**: `v8.0.1` (Next-generation frontend tooling and bundler)
- **TypeScript**: `~5.9.3` (Statically typed JavaScript to ensure type safety)

### Dependencies & Core Logic
- **React Router DOM**: `v7.13.2` (Handles routing and Single Page Application navigation)
- **React Markdown**: `v10.1.0` (Renders the core `.md` databases safely into React components)
- **Remark-GFM**: `v4.0.1` (Plugin for `react-markdown` to support GitHub Flavored Markdown features like tables and strikethroughs)
- **Front-Matter**: `^4.0.2` (Extracts YAML metadata block from Markdown files, used for content attributes like title, date, etc.)
- **Mermaid**: `v11.13.0` (JavaScript based diagram and charting tool, specifically used here to parse dynamic Markdown Gantt charts natively).

---

## 🚀 Local Environment Setup and Execution

To run, inspect, and modify this completely locally, follow the steps below:

### Prerequisites
Make sure you have `Node.js` installed on your local environment.
- **Node.js**: (Recommended `v18.0.0` or higher)
- **npm**: Comes directly with Node.js.

### 1. Clone the repository
Navigate to a proper folder on your system and clone the repository locally:
```bash
git clone git@github.com:DSD-S1-TEST/DSD-S1.github.io.git
cd DSD-S1.github.io
```

### 2. Install Dependencies
Install all the necessary backend scripts and React library dependencies listed above. Do not use `npm ci` unless you are matching the exact package-lock synchronization on CI/CD! For standard local installation, use:
```bash
npm install
```

### 3. Run the Local Development Server
To launch the Hot-Module-Replacement (HMR) local developer environment, run:
```bash
npm run dev
```
By default, the Vite server will expose the application on `http://localhost:5173/`. Open your browser and navigate to this URL to see the live site!

### 4. Build for Production
When making production releases manually, or testing the built distributables:
```bash
npm run build
```
This runs the typescript compiler (`tsc -b`) and bundles the static site dependencies to `/dist`. You can test this built bundle using `npm run preview`.

---

## 📝 Content Maintenance

You can easily modify what the site displays without reading a single line of React code!

- **HomePage Config**: Edit `src/content/home/index.md`.
- **Progress Tracking**: Edit `src/content/progress/gantt.md` (It directly renders Mermaid Gantt logic).
- **News/Updates**: Add `.md` files to `src/content/news/` containing proper YAML front-matter (`title`, `date`, `author`).
- **Team Members**: Add `.md` files to `src/content/members/` maintaining the structure for staff profiles and avatars.
