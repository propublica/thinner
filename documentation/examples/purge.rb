# The urls in this array are purged in order, so you'll want to structure it
# according to usage.
arr << ["/some_route", "/some_route/with.*", "/"]

Thinner.purge! arr