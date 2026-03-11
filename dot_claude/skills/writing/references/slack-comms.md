# Slack & Informal Comms

Format-specific guidance for Slack DMs, help channel replies, stakeholder updates, and thread responses.

## Slack Formatting (mrkdwn, not Markdown)

Slack uses its own markup called `mrkdwn`. Key differences from Markdown:

| Element | Slack mrkdwn | NOT Markdown |
|---|---|---|
| Bold | `*bold*` | ~~`**bold**`~~ |
| Italic | `_italic_` | same |
| Strikethrough | `~struck~` | ~~`~~struck~~`~~ |
| Code | `` `code` `` | same |
| Code block | ` ```code``` ` | same |
| Blockquote | `> quote` | same |
| Link | `<https://url\|label>` | ~~`[label](url)`~~ |
| List | `• item` or `1. item` | no nested lists |
| Heading | not supported | ~~`# heading`~~ |

Always output Slack messages in mrkdwn. Never use `**`, `~~`, `[text](url)`, or `#` headings — they render as literal characters in Slack.

## Colloquialisms

### Greetings
- Address people by name when starting a thread: `Hi @name :wave-shiba:`
- Use warm, personal openers: `Heyo :wave-shiba:`, `hiya`, `Hi team :wave-shiba:`
- Never use generic "Hello" or "Hi there"
- In #help channels, always follow the greeting with an acknowledgement: `Thanks for reaching out!`

### Emoji Vocabulary
Emoji carry emotional weight — they're not decorative.

| Emoji | Use it when... |
|---|---|
| `:wave-shiba:` | Greeting someone |
| `:prayge:` | Expressing gratitude, asking a favour, fingers crossed |
| `:salute-cat:` | Acknowledging something / "on it" / "got you" |
| `:igotchu:` | "I've got you covered" |
| `:onitonit:` | "Already on my radar" |
| `:thanking:` / `:thank_you_:` | Genuine appreciation |
| `:blob-smiley:` / `:blob-canva-love-heart-sparkle:` | Warmth, friendly close |
| `:celebrashun:` / `:awesomesome:` / `:star-struck-anim:` | Wins, genuine delight |
| `:sweat_smile:` | Self-deprecating humour, acknowledging awkwardness |
| `:think_spin:` | Thinking something through |
| `:pain-smile:` / `:sadge:` / `:ahhhhhhhhhhh:` | Comic frustration |
| `:dead-cya:` / `:joy:` | Laughing / joking |
| `:bug-squish:` | Fixing bugs |
| `:sgtm:` / `:notbad:` / `:+1+:` | Approval |

### Casual Language Patterns
- `probs` — probably
- `wrt` — with respect to
- `wdyt` — what do you think?
- `fyi` — no punctuation, just drop it in
- `bit of a random question` — softens an out-of-context ask
- `quick look` / `had a looksie` — informal but thorough
- `happy to [X]` — cooperative, never pushy
- `keen to [X]` — enthusiastic

## Interacting with Others

### Tagging People
- Always explain why you're tagging: `cc @name as you probs have the most context`
- Never leave a mention unexplained

### Giving Kudos
Format: `/kudos @name for [specific action] :emoji: [why it mattered] :celebration-emoji:`

Example:
> `/kudos @Ralph for your attention to detail and iterative approach during this project — I also wanna call out the foresight you had a year ago in packaging micro-animations into 'recipes' for easier reuse :celebrashun:`

Rules:
- Name the specific action, not just the person
- Explain the broader impact
- Do it publicly

### Helping in #help Channels
1. Warm greeting + name: `Hi @name :wave-shiba: Thanks for reaching out!`
2. Acknowledge if there's a gap, example: `bringing light to a gap in our docs!`
3. Give a direct answer
4. Link supporting resources inline
5. Redirect politely when needed: `I'd suggest reaching out to X in #channel — they can help :blob-smiley:`
6. Create a follow-up for yourself: `I'll create a backlog item for us to address it!`

### Proactive Flags
- Lead with what you noticed, then state the impact or urgency
- Tag the relevant person and say why: `cc @name [reason]`
- Close with next steps or what to expect
- Example phrase: `Raising the flag so it can be prioritised accordingly`

### Linking
- Always share links inline — GitHub PRs, Confluence, Figma, Jira, Storybook
- Never say "see docs" without a direct link

### Documentation Habit
- Use `leaving this here` / `linking this thread` to preserve context for others

## Channel Tone Calibration
| Channel | Tone | Format |
|---|---|---|
| Team channel | Most relaxed, personal, social updates ok | Paragraphs, lots of emoji |
| Eng channel | Technical but collegial, invites debate, teaching moments, options framing,gentle course-corrections | Prose + bullets, links to PRs/docs |
| General project channel | Helpful, documentation-forward | Bullets and step-by-step where needed |
| #help channels | Patient, service-oriented – concise approvals and clear shipping signals ("Absolutely!", "LGTM!", "It's live"), plus concrete links and timing | Greeting + answer + links + follow-up |
| Specialist dev/design channels | Detail-oriented, proactive flagging | Bullets for technical points, links to Figma/Storybook/GitHub |

### Pre-Send Checklist

1. Lead with a warm hello
2. State the outcome and timing
3. Ask 1-3 clarifying Qs max
4. Bullet the next steps with owners
5. Drop the links/PRs
6. Close the loop later ("Looping back—status")

## Example Patterns

These are illustrative patterns, not verbatim past messages.

### Help channel response (simple unblock)

> Heya — got it. We can ship the URL hookup today; expect prod within 1-2 days. Share the CMS entity link and preferred path and I'll get a PR up.

### Stakeholder scoping (options + plan)

> Morning! Happy to scope. Do you want a quick pass (just us, ballparks) or a deeper session with a couple of engs to cut the bus factor? I can hold Fri 2pm — shout if an earlier slot opens.

### Bug triage (ack + next step)

> Thanks for flagging — we'll take a look first thing and drop notes on the PR. If it's impacting the team broadly, we'll merge a fix ASAP.

### Experiment setup coaching

> What's the goal you're optimising for? Work backwards from that. Check the relevant guide; then we can pick params and variants together.

## Hard No's
- No formal corporate language ("Please be advised", "As per my previous message")
- No "Hope this helps!" — use `:salute-cat:` or let the message speak for itself
- No "Best regards" or any formal sign-off
- No all-caps for emphasis — use emoji instead
- No vague answers — always include a link or step-by-step
- No unexplained tags
