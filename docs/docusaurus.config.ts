import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Agent Skill Automation',
  tagline: 'Autonomous pipeline for designing, validating, optimizing, and deploying Claude Code Agent Skills',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://agent-skill-automation.example.com',
  baseUrl: '/',

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: 'docs',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Agent Skill Automation',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          type: 'docSidebar',
          sidebarId: 'agentsSidebar',
          position: 'left',
          label: 'Agents',
        },
        {
          type: 'docSidebar',
          sidebarId: 'operationsSidebar',
          position: 'left',
          label: 'Operations',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {label: 'Getting Started', to: '/docs/intro'},
            {label: 'Architecture', to: '/docs/architecture'},
            {label: 'AutoResearch Pattern', to: '/docs/autoresearch'},
          ],
        },
        {
          title: 'Agents',
          items: [
            {label: 'Core Pipeline', to: '/docs/agents/core-pipeline'},
            {label: 'Steward Agents', to: '/docs/agents/steward-agents'},
            {label: 'Project Reviewer', to: '/docs/agents/project-reviewer'},
          ],
        },
        {
          title: 'Operations',
          items: [
            {label: 'Nightly Fleet', to: '/docs/operations/nightly-fleet'},
            {label: 'Eval Infrastructure', to: '/docs/operations/eval-infrastructure'},
            {label: 'Roadmap', to: '/docs/operations/roadmap'},
          ],
        },
      ],
      copyright: `Copyright \u00a9 ${new Date().getFullYear()} Agent Skill Automation. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'json', 'yaml', 'python'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
