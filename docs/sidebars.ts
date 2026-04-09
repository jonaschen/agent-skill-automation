import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'intro',
    'architecture',
    'autoresearch',
  ],
  agentsSidebar: [
    {
      type: 'category',
      label: 'Agents',
      items: [
        'agents/core-pipeline',
        'agents/steward-agents',
        'agents/project-reviewer',
        'agents/all-agents',
      ],
    },
  ],
  operationsSidebar: [
    {
      type: 'category',
      label: 'Operations',
      items: [
        'operations/nightly-fleet',
        'operations/eval-infrastructure',
        'operations/roadmap',
      ],
    },
  ],
};

export default sidebars;
