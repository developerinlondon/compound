# TODO

* We can add machines to different networks because even though we require
  `10.8.*`, the networks created are `/24`'s. These should either be `/16`
  to avoid surprises, or we should make the CIDR configurable, or we should
  give an example showing this behaviour.

* Tests. So ironic that a testing tool has no tests. For release 1.0.0 we
  need tests.

* We should support the ansible remote user attributes in the inventory, for
  each host.

* Rewrite the InventoryParser so it's understandable!

* Make command timeouts customiseable.

* Stop paying attention to `~/.ssh/known_hosts` inside the tests. If these
  host keys exist we end up with test failures, even though we _do_ expected
  these to change.
