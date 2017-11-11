hs-venture
==========

`hs-venture` is a partial Haskell implementation of the Venture language.

`hs-venture` is
- An inference dsl embedded in Haskell (cabal library, Venture.hs and
  dependencies),
- An interpreter for a standalone inference language compatible with
  VenChurch (up to available names), with
- An http server listening for commands and executing them (cabal
  executable "venture-server"), and
- A (small) test suite ("tests" in cabal)

`hs-venture` runs, and passes a tiny sanity check suite (which includes
some tests of statistical correctness).

The first substantial architectural difference between `hs-venture` and
Ventures 0.1.x and 0.2 is that the Traces in `hs-venture` are
pure-functional.  This should make particle methods much easier to
implement, and keep the code for operating on a Trace much simpler and
easier to understand; at the cost of some additional complexity
plumbing Traces, and at the threat that the extra layer of indirection
will come back and bite the program's performance.

The second substantial difference is that `hs-venture`'s inference
programming language is (meant to be) a clean embedding in Haskell
with an optional additional interpreter on top, whereas the inference
language in the late 0.2 series is explicitly interpreted.

Potential uses for hs-venture
-----------------------------

- Expository implementation (this would require some considerable
  massaging and beautifying)
- Testbed for clearly stating and checking implementation invariants
- Quasi-independent Venture implementation for cross-checking
  (especially HMC, which in `hs-venture` should be implementable with a
  good third-party AD library instead of by hand; see non-compiling
  draft in Gradient*.hs)

Developing hs-venture into a full implementation of Venture 0.2
---------------------------------------------------------------

Would be a Simple Matter of Programming.  The punch list for that job,
in broad strokes, is:

- Finish the inference interpreter and server, so that the test suite
  of 0.2 can execute against `hs-venture` over a TCP connection
- Implement a few more inference primitives, like particle gibbs,
  slice sampling, and HMC
- Round out the set of built-in Venture-level value types to match 0.2
- Round out the set of built-in SPs
- Implement the rest of "children absorb at applications"
    - Collecting statistics works
    - Exchangeably coupled collapsed models work
    - Implement Gibbs steps for uncollapsed models
    - Implement absorbing hyperparameter changes at collapsed models
- Implement a library for SMC-style with a weighted set of traces
  on top of the embedding
    - Possible hack: make a typeclass for reasonable things to use to
      represent model distributions and implement it for, e.g., [Model].
- Implement separate tracking of the constraints that observations
  impose and the appropriate model of propagating them
- Debug thoroughly and pass the 0.2 test suite
- Does anything actually require detach-regen order symmetry?  It may
  be necessary to rewrite detach to enforce it (do the
  insertion-ordered sets already do that?).
- Will need to implement scopes and blocks or something somehow
- [Techincally] Add latent simulation requests and latent simulation
  kernels, neither of which are widely used or understood in Venture
  0.2
- FIXME: with local kernels, all parts of regen, eval, evalRequests,
  and detach may produce contributions to the weight.
- [Optional] Use the Haskell-C interface to be able to call Python
  Venture SPs
- [Optional] Use the Haskell-C interface to allow the Python stack to
  run `hs-venture` in-process (presumably by overriding CoreSivm or
  the stack's Engine)

History
-------

The initial development occurred between 11/21/13 and 12/16/13.  This
was around the 0.1.x releases; so the initial mental model stems from
that period.

Work toward a server understanding the Venture wire protocol occurred
4/5/14-4/9/14, and then 5/13/14.

Around 1/25/15-1/28/15, reworked into a mental model where the
inference language is embedded into Haskell (in the Venture module),
with an additional layer interpreting the surface syntax of Venture as
a server (whose surface was not upgraded since 5/13/14).
