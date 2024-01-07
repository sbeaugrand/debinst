# Mermaid diagram class example
```mermaid
%% Mermaid diagram class example
classDiagram
class AbstractStubServer {
	+status()* string
	+quit()* void
}
class Server {
	+status() string
	+quit() void
}
AbstractStubServer <|-- Server
A *-- B
C o-- "*" D
namespace nspace {
	class E
	class F
}
C o-- E
C o-- F
G --> H : Association
I -- J : Link(Solid)
K ..> L : Dependency
M ..|> N : Realization
O .. P : Link(Dashed)
```
