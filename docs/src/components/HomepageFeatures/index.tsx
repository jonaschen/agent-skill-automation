import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  description: ReactNode;
  icon: string;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Meta-Agent Factory',
    icon: '\u2699\uFE0F',
    description: (
      <>
        Generate format-compliant, permission-correct SKILL.md files from
        natural language requirements. Three-layer architecture with progressive
        disclosure minimizes token consumption.
      </>
    ),
  },
  {
    title: 'AutoResearch Optimizer',
    icon: '\uD83D\uDD2C',
    description: (
      <>
        Unattended Skill improvement using Karpathy&apos;s AutoResearch pattern.
        Bayesian scoring with credible intervals ensures only statistically
        significant improvements are committed.
      </>
    ),
  },
  {
    title: 'Autonomous Nightly Fleet',
    icon: '\uD83C\uDF19',
    description: (
      <>
        Seven agents run nightly via cron: an AI researcher, four project
        stewards, a factory self-improver, and a tech-lead reviewer. They form a
        self-correcting cycle with steering notes.
      </>
    ),
  },
  {
    title: 'Binary Eval + CI/CD Gate',
    icon: '\u2705',
    description: (
      <>
        54-prompt test suite with train/validation split. Bayesian posterior must
        reach 0.90 mean with 0.80 CI lower bound to pass deployment gate. No
        partial credit, no subjective scoring.
      </>
    ),
  },
  {
    title: 'Mutually Exclusive Permissions',
    icon: '\uD83D\uDD12',
    description: (
      <>
        Review agents cannot write. Execution agents cannot delegate. Permission
        boundaries are enforced statically and verified by automated checks
        before every deployment.
      </>
    ),
  },
  {
    title: 'Seven-Phase Roadmap',
    icon: '\uD83D\uDDFA\uFE0F',
    description: (
      <>
        From single-agent automation (Phases 1&ndash;4) through multi-agent
        orchestration (Phase 5), edge deployment (Phase 6), to commercial
        Agent-as-a-Service (Phase 7).
      </>
    ),
  },
];

function Feature({title, icon, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center" style={{fontSize: '3rem'}}>
        {icon}
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
