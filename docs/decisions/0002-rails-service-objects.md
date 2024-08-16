---
ID: archelon-0002
Status: Active
Date: 2024-02-19

---
# Rails service objects

## Context

There is an established pattern in the Rails community for creating
*service objects*; i.e., objects that encapsulate some functionality that
should be located outside of a controller or model class, but is still
strongly associated with the application.

Jared Norman has an in-depth discussion of this pattern in his article
["Service Objects"](https://jardo.dev/rails-service-objects), including
links to many additional articles, both in favor of, and in oppostion to,
the service object pattern.

The basic definition of this Rails-style service object is a single-use
object (i.e., it is instantiated and is called all withing the course of,
at most, a single request, and usually is only extant for a single method
call in the controller). Other features of a service object are:

* has a constructor
* has a single public method, usually named `call`
* implements a single business process

Our intended use of service objects would be to:

* encapsulate single operations within our problem domain (e.g.,
  publish a resource, send an email, retrieve metadata)
* deal with external services (e.g., an HTTP API, a STOMP server)
  that may be expensive or difficult to use during unit testing,
  in such a way that we can easily inject mock objects for them
  during testing

## Pros

1. Increase separation of concerns between controllers and
   business logic
2. Improve testability by allowing substitution of mock service
   objects for external services

## Cons

1. Increases the number of classes, and therefore files, since each
   class now implements just one function
2. Without careful planning, could lead to isolated pieces of code
   that are not communicating (even when they should), or are hard
   to understand as a whole system; see also ["lasagna" or "ravioli" code]

## Decision

Proceed with implementing new functions that communicate with external
services as Rails-style service objects. The first will use be in the
Publication Workflow implementation. Specifically, the HTTP calls to the
Plastron HTTP service to publish and unpublish individual items, will
make use of a set of service objects representing the activities
"Publish", "Publish Hidden", and "Unpublish".



Based on our experience with this implementation, we will decide whether
to expand our use of this service object pattern, including refactoring
existing code in the `app/services` directory to match this pattern, or
to return to directly using procedures and functions.

## Consequences

The intended positive consequences are:

1. Increased code readability, especially in the controllers
2. Increased testability
3. Identification of common code patterns that can be extracted into their
   own service objects

Possible negative consequences are:

1. More time required to design the right service encapsulation
2. More individual code files


["lasagna" or "ravioli" code]: https://www.techtarget.com/searchsoftwarequality/tip/Fix-spaghetti-code-and-other-pasta-theory-antipatterns
