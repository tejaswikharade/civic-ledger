import { useState } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'

const proposals = [
  { id: '01', title: 'Plant trees on Market Street', body: 'A shaded walk for the school run.', for: 68, against: 12, status: 'Open' },
  { id: '02', title: 'Repair the library roof', body: 'Keep a beloved public room open.', for: 94, against: 8, status: 'Open' },
  { id: '03', title: 'Publish the mobility plan', body: 'A readable map for every resident.', for: 122, against: 24, status: 'Ready' },
]

function App() {
  const [selected, setSelected] = useState(null)
  const [notice, setNotice] = useState('')

  function choose(proposal, direction) {
    setSelected(`${proposal.id}-${direction}`)
    setNotice(`Your ${direction} vote for “${proposal.title}” is ready to sign.`)
  }

  return <main>
    <nav className="nav"><a className="brand" href="#top"><span>✦</span> CivicLedger</a><div><a href="#process">How it works</a><a href="#proposals">Proposals</a><button onClick={() => document.querySelector('#proposals').scrollIntoView({ behavior: 'smooth' })}>View the ledger</button></div></nav>

    <section id="top" className="hero">
      <div className="hero-copy"><p className="eyebrow">A PUBLIC RECORD FOR PUBLIC GOOD</p><h1>Local decisions,<br /><em>open to all.</em></h1><p className="lede">CivicLedger gives neighbourhood ideas a clear path: propose, deliberate, vote, and keep the result in the open.</p><button className="primary" onClick={() => document.querySelector('#proposals').scrollIntoView({ behavior: 'smooth' })}>Explore proposals <span>→</span></button></div>
      <div className="seal" aria-label="CivicLedger emblem"><div className="seal-inner"><span>THE COMMON</span><strong>CL</strong><span>LEDGER · 2025</span></div></div>
      <p className="margin-note">Built for the conversations<br />that shape a place.</p>
    </section>

    <section id="process" className="process"><p className="eyebrow">THE CIVIC LOOP</p><div className="process-grid">{[['01', 'Propose', 'Put a practical idea on the public record.'], ['02', 'Deliberate', 'Give neighbours a clear window to weigh in.'], ['03', 'Decide', 'One address. One vote. A visible outcome.']].map(([n, h, p]) => <article key={n}><span>{n}</span><h2>{h}</h2><p>{p}</p></article>)}</div></section>

    <section id="proposals" className="ledger"><div className="ledger-heading"><div><p className="eyebrow">THE LEDGER</p><h2>Ideas in motion</h2></div><p>Live proposals from the civic square.<br />Your voice has a place here.</p></div><div className="proposal-list">{proposals.map(p => <article className="proposal" key={p.id}><div className="proposal-number">{p.id}</div><div className="proposal-title"><span className={`status ${p.status.toLowerCase()}`}>{p.status}</span><h3>{p.title}</h3><p>{p.body}</p></div><div className="vote-count"><strong>{p.for}</strong><span>FOR</span><i style={{ width: `${Math.round(p.for / (p.for + p.against) * 100)}%` }} /></div><div className="vote-actions"><button className={selected === `${p.id}-for` ? 'selected' : ''} onClick={() => choose(p, 'for')}>For</button><button className={selected === `${p.id}-against` ? 'selected' : ''} onClick={() => choose(p, 'against')}>Against</button></div></article>)}</div>{notice && <p className="notice">✦ {notice}</p>}</section>

    <footer><a className="brand" href="#top"><span>✦</span> CivicLedger</a><p>Open governance, held in common.</p><a href="https://github.com" target="_blank" rel="noreferrer">View source ↗</a></footer>
  </main>
}

createRoot(document.getElementById('root')).render(<App />)
