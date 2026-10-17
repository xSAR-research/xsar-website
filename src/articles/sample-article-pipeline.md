---
title: "Sample: How xSAR Articles Are Built"
date: 2026-10-18
slug: sample-article-pipeline
summary: "A test article that exercises every Markdown feature the xSAR article pipeline supports, including build-time maths."
# Optional: link back to the X Article this page mirrors.
# x_url: https://x.com/xSAR_Research/status/0000000000000000000
---

This page is a **sample**. It exists to prove the pipeline end to end: Markdown in, a standard HTML5 page out, with *no JavaScript* needed for the maths and [an underline]{.underline} where it helps.

## Why search theory needs maths

A classic result in search theory is Koopman's *random search* formula. With sweep width $W$, track length $L$ and search area $A$, the coverage is $c = \frac{WL}{A}$ and the probability of detection is:

$$
\mathrm{POD} = 1 - e^{-WL/A}
$$

Summing over segments $i$, the overall probability of success is

$$
\mathrm{POS} = \sum_{i=1}^{n} \mathrm{POA}_i \times \mathrm{POD}_i
$$

---

### Supported formatting

| Feature | Markdown | Result |
|---|---|---|
| Bold | `**bold**` | **bold** |
| Italics | `*italics*` | *italics* |
| Underline | `[text]{.underline}` | [text]{.underline} |
| Link | `[xSAR](https://xsar.com.au/)` | [xSAR](https://xsar.com.au/) |
| Inline maths | `$e^{i\pi} + 1 = 0$` | $e^{i\pi} + 1 = 0$ |

#### An image

![The xSAR logo](../images/xsar-logo.png){width=140}

That's everything: headers, a horizontal rule, **bold**, *italics*, [underline]{.underline}, [links](https://x.com/xSAR_Research), a table, an image, inline maths like $\alpha + \beta$ and display maths.
