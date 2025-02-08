Adding component -> O(n), n = number of archetypes (usually 0)
Querrying archetype -> O(1)
Querrying component type -> O(1)
Removing entity -> O(n^2), entity needs to unregister n1 components that are a member of n2 archetypes