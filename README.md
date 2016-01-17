# repl-lite package

This package is a stripped down version of [Jason Gilman's Proto REPL package](https//www.github.com/jasongilman/proto-repl).

Most of the stripping down is done in service of the ability to get into a ClojureScript REPL. (Proto-REPL has features
  which wrap code sent to the REPL in Clojure-only functions.)

So why not contribute to the original project?

1. I don't think going in and deleting a bunch of stuff is a good way to contribute.
2. I don't yet have a firm grasp of Atom package development, so I wanted to start from scratch.

I think this package does contribute one thing, which I will try to add to the original, and that's the ability
to report the correct current namespace of the REPL environment.
