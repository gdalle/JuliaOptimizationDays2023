### A Pluto.jl notebook ###
# v0.19.29

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ c5b86a90-5c8f-11ee-1d60-65cfc67e3948
begin
	using BenchmarkTools
	using FillArrays
	using Graphs
	using GraphPlot
	import GridGraphs
	import SimpleWeightedGraphs
	import MetaGraphs
	import MetaGraphsNext
	using Pluto
	using PlutoUI
	using PlutoTeachingTools
end

# ╔═╡ 9f16b4c8-358e-46fe-b07d-10e3990df177
imgfolder = abspath(joinpath("..", "..", "images"))

# ╔═╡ 22d3b3fc-4c88-40f9-aa9a-583a124d2d50
TableOfContents(depth=1)

# ╔═╡ 00ab89f9-698b-4a55-a5e2-214ae934a6e7
md"""
# Graphs in Julia

_On the edge of glory_

Guillaume Dalle (EPFL)
"""

# ╔═╡ b4a156ab-3a55-40ec-9726-856dba595d56
present_button()

# ╔═╡ 9470b6c5-ac11-4682-86f4-a5cc766c5231
md"""
# Introduction
"""

# ╔═╡ b337eab8-18ac-4997-9171-6dd16840eda4
md"""
## Graphs are everywhere
"""

# ╔═╡ 653ceebf-b2b8-4cc8-90b6-5b0e971930d1
TwoColumn(
md"""
- transportation systems
- molecular structures
- social networks
""",
Resource("https://i.imgur.com/LGwNqA1.jpg")
)

# ╔═╡ 2375cd79-75df-4e54-baf7-424b85b75d99
md"""
## Julia is great for graphs
"""

# ╔═╡ e9dfc240-2981-416f-b1fc-190646dbb9da
md"""
- it is fast
- it is generic
- it has [JuMP.jl](https://github.com/jump-dev/JuMP.jl)
- it makes us happy
"""

# ╔═╡ a2c9ffd4-f28c-4862-817a-72c0dfc5e944
md"""
# A graph interface
"""

# ╔═╡ 39758663-9e86-4469-ac37-793652be4b85
md"""
## Graph definition
"""

# ╔═╡ 03d43132-bba7-432b-a891-b88a0a7c985e
md"""
- a set of vertices $v \in \mathcal{V}$
- and a set of edges $e \in \mathcal{E}$
- and maybe some edge weights $w \in \mathbb{R}^{\mathcal{E}}$
"""

# ╔═╡ bf3459a8-15d8-4aaf-b0c4-f0da62ee6aa9
md"""
## Assumptions matter
"""

# ╔═╡ 13ba3456-7f4f-43b1-b7bc-3b146297a7a7
begin
	family_selector = @bind family Select([:path, :cycle, :complete])
	nb_vertices_selector = @bind nb_vertices Slider(3:10; show_value=true)
	TwoColumn(family_selector, md"""size: $nb_vertices_selector""")
end

# ╔═╡ fa19a5eb-a357-43a1-86a7-82ec85125bba
if family == :path
	gplot(path_graph(nb_vertices))
elseif family == :cycle
	gplot(cycle_graph(nb_vertices))
elseif family == :complete
	gplot(complete_graph(nb_vertices))
end

# ╔═╡ 2f10e310-04bf-4259-bae9-efba6935fd91
md"""
## Graph storage
"""

# ╔═╡ b8838d3e-210a-456d-989c-bf356dd933bc
md"""
Adjacency list $$v \in L[u] \iff (u, v) \in \mathcal{E}$$
"""

# ╔═╡ 42554184-5910-4d99-8dbf-c9bb31e6a60c
path_graph(3).fadjlist

# ╔═╡ 26544e30-2184-484d-9061-472df17487bd
md"""
Adjacency matrix $$A_{u,v} = 1 \iff (u, v) \in \mathcal{E}$$
"""

# ╔═╡ 4f5ce53f-a5bb-4d0e-ae27-40ed5a0bae12
adjacency_matrix(path_graph(3)) |> Matrix

# ╔═╡ bc7ef0eb-b365-4d54-a231-8acf44e07ed9
md"""
## Graph storage in real life
"""

# ╔═╡ 91881f4a-fbd2-448c-bdb8-d111ebd66aa9
md"""
- Directed vs. undirected
- Sparse vs. dense
- What about edge weights?
- What about other metadata?
- What about self-loops?
- What about multiple edges?
"""

# ╔═╡ 6cf5962b-4142-458c-b12e-1292a103453b
md"""
## Graph functions
"""

# ╔═╡ efbb5eed-a512-4da8-8738-96fc7f162380
md"""

- End goal: algorithms like `dijkstra(g, v)`.
- Basic ingredients: functions like `neighbors(g, v)`

!!! info "Key idea"
	The interface is independent from the storage mode (kind of)
"""

# ╔═╡ fc51506b-63ac-464d-a309-696679757675
md"""
## The common interface
"""

# ╔═╡ 97df57d2-ae31-4e72-a10b-7588bd604876
md"""

A [handful of functions](https://juliagraphs.org/Graphs.jl/stable/ecosystem/interface/) on which all algorithms rely

- enumerate vertices and edges
- enumerate neighbors

!!! warning "Assumptions"
    - contiguous integer vertices from $1$ to $n$
    - no self-loops?
    - neighbors listed in increasing order?

"""

# ╔═╡ f6688d6f-54c5-4405-a441-b3c951ab5fe2
md"""
# The JuliaGraphs organization
"""

# ╔═╡ 2e3502ec-5f53-45c0-a855-a799f2f86fa1
md"""
## LightGraphs or Graphs?
"""

# ╔═╡ fcc26a2b-708e-4fd9-af88-f3f5f9f85213
TwoColumn(
md"""
- [OldGraphs.jl](https://github.com/JuliaAttic/OldGraphs.jl): the very first attempt, now archived
- [LightGraphs.jl](https://github.com/sbromberger/LightGraphs.jl): the default for a while, now archived
- [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl): the current default, actively maintained
""",
Resource("https://i.imgur.com/2ETv2DZ.jpg")
)

# ╔═╡ 27741e2b-b4b6-41ab-9ddb-5e71933fc1da
md"""
## [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl)
"""

# ╔═╡ dba5f428-e7e8-4343-b078-52402278f3cb
md"""
- adjacency list
- no edge weights
"""

# ╔═╡ 4ac57a1d-7047-4eb8-b4f5-2fe02af80fc3
let
	sg = path_graph(3)
	zip(fieldnames(typeof(sg)), fieldtypes(typeof(sg))) |> collect
end

# ╔═╡ f20400a5-98a9-4ad8-96a6-dabe76c1a1c6
md"""
## [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl)
"""

# ╔═╡ 42cf6901-07f8-4e8b-9387-cee7fbe37e35
md"""
- adjacency matrix
- real edge weights
"""

# ╔═╡ 2368ed40-6090-4a23-8a63-8d06514cd4dd
let
	swg = SimpleWeightedGraphs.SimpleWeightedGraph(path_graph(3))
	zip(fieldnames(typeof(swg)), fieldtypes(typeof(swg))) |> collect
end

# ╔═╡ f38173af-966d-4a64-a170-82a132a7f0d8
md"""
## [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl)
"""

# ╔═╡ fd7d22d0-a6b2-4e40-8585-4b6dbcfbc8e6
md"""
- arbitrary graph storage
- (type-unstable) vertex, edge and graph metadata
"""

# ╔═╡ c0913071-ee2e-42c6-944c-23d055ae34cc
let
	mg = MetaGraphs.MetaGraph(path_graph(3))
	zip(fieldnames(typeof(mg)), fieldtypes(typeof(mg))) |> collect
end

# ╔═╡ ed7c27c1-c0ff-4a00-8f7e-76652749b153
md"""
## [MetaGraphsNext.jl](https://github.com/JuliaGraphs/MetaGraphsNext.jl)
"""

# ╔═╡ 4aadb25b-5d67-4c13-ba99-f7029793df63
md"""
- arbitrary graph storage
- (type-stable) vertex, edge and graph metadata
"""

# ╔═╡ 425dfdd4-8312-4c40-8644-21995343ec1d
let
	mgn = MetaGraphsNext.MetaGraph(
	    path_graph(0),
	    label_type=Integer,
	    vertex_data_type=String,
	    edge_data_type=Float32,
	)
	zip(fieldnames(typeof(mgn)), fieldtypes(typeof(mgn))) |> collect
end

# ╔═╡ a22c24a7-277b-458b-99df-9b97b39d3daa
md"""
## A little benchmark
"""

# ╔═╡ f4863835-2004-4b85-9dd6-ca7f807f41c5
md"""
Listing neighbors on a grid graph
"""

# ╔═╡ 444baa8c-1872-419f-aa04-689401a0cddc
gplot(Graphs.grid((3, 3)))

# ╔═╡ 55e1e8eb-8589-4768-9f05-99b5e813a991
md"""
## A little benchmark (2)
"""

# ╔═╡ 97c41a2f-5c4d-4ff3-a8b3-c65fdb41ab4b
md"""
The basic `SimpleGraph` is fastest
"""

# ╔═╡ 59fc2616-16f3-405c-8e35-6d8ae6324052
let
	grid1 = Graphs.grid((8, 8))
	println("Size: ", Base.summarysize(grid1))
	@btime inneighbors($grid1, 1);
	@btime outneighbors($grid1, 1);
end;

# ╔═╡ 81a03dc8-e2a9-4416-9afc-76eeae6ab8a9
md"""
## A little benchmark (3)
"""

# ╔═╡ f16e510b-417c-423f-ba76-277ff2747d9b
md"""
The `SimpleWeightedGraph` is slower, especially for `inneighbors`
"""

# ╔═╡ da13690d-f84e-4391-9c77-fc0b245387e6
let
	grid2 = SimpleWeightedGraphs.SimpleWeightedDiGraph(Graphs.grid((8, 8)))
	println("Size: ", Base.summarysize(grid2))
	@btime inneighbors($grid2, 1);
	@btime outneighbors($grid2, 1);
end;

# ╔═╡ f7b12509-6d70-469f-b7b9-694cd284841c
md"""
## A little benchmark (4)
"""

# ╔═╡ a49322d8-35bb-4096-bf4f-0e3bfed2d352
md"""
If you know about the grid structure, you can generate neighbors on the fly with no memory footprint
"""

# ╔═╡ ccdafc4e-502d-4e40-b462-4680016fcb80
let
	grid3 = GridGraphs.GridGraph(Ones(8, 8); directions=GridGraphs.ROOK_DIRECTIONS)
	println("Size: ", Base.summarysize(grid3))
	@btime inneighbors($grid3, 1);
	@btime outneighbors($grid3, 1);
end;

# ╔═╡ 23ba33a6-c9b9-4022-b94f-ae0ca6be0525
md"""
A custom format like `GridGraph` can be the best solution
"""

# ╔═╡ ad85609f-9554-4279-bf02-f77e2756de67
md"""
## Graph algorithms
"""

# ╔═╡ 79ca68fc-d60c-4ccb-9aab-819565de92a7
md"""
- [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl): a little bit of everything
- [GraphsOptim.jl](https://github.com/JuliaGraphs/Graphs.jl): algorithms based on mathematical programming
"""

# ╔═╡ 0738f051-1b85-4329-b8e1-bba68c72f12a
md"""
## Miscellaneous
"""

# ╔═╡ 7e900874-fd5f-44ac-9b27-6fba66db77e7
md"""
- [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl): read and write graph files
- [GraphPlot.jl](https://github.com/JuliaGraphs/GraphPlot.jl): plot graphs with automatic layout
"""

# ╔═╡ b20ccc5a-b260-41c4-bb70-a28c224e6a8a
md"""
# Beyond JuliaGraphs
"""

# ╔═╡ 3c73309f-cfa9-4eb5-b34d-0d5d79576178
md"""
## A thriving ecosystem
"""

# ╔═╡ d20d13eb-eddb-4744-91bc-5524df4de8f2
Resource("https://i.imgur.com/afI4sp8.jpg")

# ╔═╡ 961a3381-6362-4c62-a07d-4dbcbe563bb2
md"""
## The Great Census of 2023
"""

# ╔═╡ 48d5efbd-01a8-4b43-8320-0fe247bbb535
md"""
The discourse post ["The graphs ecosystem"](https://discourse.julialang.org/t/the-graphs-ecosystem/99463) found

- 3 packages defining a broad interface
- 15 packages for graphs with metadata
- 4 packages for multigraphs and hypergraphs
- 8 packages for graphs with special structure
"""

# ╔═╡ 1ebcf908-ec65-431c-8d90-76d5b98304d0
md"""
## Other paradigms
"""

# ╔═╡ 7ec617f0-e662-41f4-b0e0-0e70e48237df
md"""
- [SimpleGraphs.jl](https://github.com/scheinerman/SimpleGraphs.jl): non-integer vertices, more theory-focused
- [SuiteSparseGraphBLAS.jl](https://github.com/JuliaSparse/SuiteSparseGraphBLAS.jl): express graph algorithms as linear algebra with suitable operations
"""

# ╔═╡ 9b822197-5f5e-4222-9349-cbe9eacac13c
md"""
## Cool applications
"""

# ╔═╡ 0215d6ff-3347-4b2d-9980-961b9931e1cb
md"""
- [Agents.jl](https://github.com/JuliaDynamics/Agents.jl): simulate interacting particles
- [GraphNeuralNetworks.jl](https://github.com/CarloLucibello/GraphNeuralNetworks.jl): machine learning for graph-structured data
- [ModelingToolkit.jl](https://github.com/SciML/ModelingToolkit.jl): bridge the gap between symbolic and numeric modeling
"""

# ╔═╡ d80e869d-4934-417c-8814-5b16963ac061
md"""
# Challenges and perspectives
"""

# ╔═╡ 5d9d095a-b29c-4bbf-9120-ccafe730762a
md"""
## Open source maintenance
"""

# ╔═╡ 6d050e68-86ee-4b09-9113-01c937f3b0cd
Resource("https://i.imgur.com/fUV85nc.jpg")

# ╔═╡ ed56c81d-9ba1-41c8-ae55-54a0b6480b35
md"""
## [GraphsBase.jl](https://github.com/JuliaGraphs/GraphsBase.jl)
"""

# ╔═╡ 54aa994b-a9fd-4217-8909-847900d1edae
md"""
!!! tip "Goal"
	Rewrite the interface to accommodate
	- edge and vertex metadata
	- multiple edges

Will be the foundation of Graphs.jl v2.0:

- breaking in principle
- but we want most algorithms to keep working

Still very much a work in progress
"""

# ╔═╡ 5579e8e0-c32e-44a9-860a-b065ab9d7655
md"""
## You wanna help?
"""

# ╔═╡ 2df902d6-e245-4657-aceb-fe1ec616ef55
md"""
- Join the `#graphs` channel on Slack or Zulip
- Take part in the new [community calls](https://discourse.julialang.org/t/launching-the-graphs-community-calls/103880)
- Weigh in on some GraphsBase.jl design [issues](https://github.com/JuliaGraphs/GraphsBase.jl/issues)
- Open simple PRs fixing Graphs.jl new feature or bug [issues](https://github.com/JuliaGraphs/Graphs.jl/issues)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
FillArrays = "1a297f60-69ca-5386-bcde-b61e274b549b"
GraphPlot = "a2cc645c-3eea-5389-862e-a155d0052231"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
GridGraphs = "dd2b58c7-5af7-4f17-9e46-57c68ac813fb"
MetaGraphs = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
MetaGraphsNext = "fa8bd995-216d-47f1-8a91-f3b68fbeb377"
Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"

[compat]
BenchmarkTools = "~1.3.2"
FillArrays = "~0.13.11"
GraphPlot = "~0.5.2"
Graphs = "~1.8.0"
GridGraphs = "~0.9.1"
MetaGraphs = "~0.7.2"
MetaGraphsNext = "~0.6.0"
Pluto = "~0.19.28"
PlutoTeachingTools = "~0.2.13"
PlutoUI = "~0.7.52"
SimpleWeightedGraphs = "~1.4.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "379ba91935a7d2890892bc83d4f5301230fa8fa9"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "a1296f0fe01a4c3f9bf0dc2934efbf4416f5db31"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "bf6570a34c850f99407b494757f5d7ad233a7257"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.5"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "5372dbbf8f0bdb8c700db5367132925c0771ef7e"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.1"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "434f446dbf89d08350e83bf57c0fc86f5d3ffd4e"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.5"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.ExproniconLite]]
deps = ["Pkg", "TOML"]
git-tree-sha1 = "d80b5d5990071086edf5de9018c6c69c83937004"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.10.3"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "299dc33549f68299137e51e6d49a13b5b1da9673"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "7072f1e3e5a8be51d525d64f63d3ec1287ff2790"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.11"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "001bd0eefc8c532660676725bed56b696321dfd2"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.5.2"

[[deps.GraphPlot]]
deps = ["ArnoldiMethod", "ColorTypes", "Colors", "Compose", "DelimitedFiles", "Graphs", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "5cd479730a0cb01f880eff119e9803c13f214cab"
uuid = "a2cc645c-3eea-5389-862e-a155d0052231"
version = "0.5.2"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "1cf1d7dcb4bc32d7b4a5add4232db3750c27ecb4"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.8.0"

[[deps.GridGraphs]]
deps = ["DataStructures", "FillArrays", "Graphs", "SparseArrays"]
git-tree-sha1 = "858b2a7a7798e649dc5612792969541e3a88379a"
uuid = "dd2b58c7-5af7-4f17-9e46-57c68ac813fb"
version = "0.9.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "Pkg", "Printf", "Reexport", "Requires", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "c11d691a0dc8e90acfa4740d293ade57f68bfdbb"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.35"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "81dc6aefcbe7421bd62cb6ca0e700779330acff8"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.25"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "410fe4739a4b092f2ffe36fcb0dcc3ab12648ce1"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.2.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "0d097476b6c381ab7906460ef1ef1638fbce1d91"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.2"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "60168780555f3e663c536500aa790b6368adc02a"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Malt]]
deps = ["Distributed", "Logging", "RelocatableFolders", "Serialization", "Sockets"]
git-tree-sha1 = "33db2f057c2361d1c6701359696be8228795aa0b"
uuid = "36869731-bdee-424d-aa32-cab38c994e3b"
version = "1.0.3"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "1130dbe1d5276cb656f6e1094ce97466ed700e5a"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.2"

[[deps.MetaGraphsNext]]
deps = ["Graphs", "JLD2", "SimpleTraits"]
git-tree-sha1 = "8dd4f3f8a643d53e61ff9115749f522c35a38f3f"
uuid = "fa8bd995-216d-47f1-8a91-f3b68fbeb377"
version = "0.6.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "fc8c15ca848b902015bd4a745d350f02cf791c2a"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.2.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ceeda72c9fd6bbebc4f4f598560789145a8b6c4c"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.11+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.Pluto]]
deps = ["Base64", "Configurations", "Dates", "FileWatching", "FuzzyCompletions", "HTTP", "HypertextLiteral", "InteractiveUtils", "Logging", "LoggingExtras", "MIMEs", "Malt", "Markdown", "MsgPack", "Pkg", "PrecompileSignatures", "PrecompileTools", "REPL", "RegistryInstances", "RelocatableFolders", "Scratch", "Sockets", "TOML", "Tables", "URIs", "UUIDs"]
git-tree-sha1 = "544316ac08be39e735d5372a1ac2da86ce42e606"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.19.28"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "542de5acb35585afcf202a6d3361b430bc1c3fbd"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.13"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PrecompileSignatures]]
git-tree-sha1 = "18ef344185f25ee9d51d80e179f8dad33dc48eb1"
uuid = "91cefc8d-f054-46dc-8f8c-26e11d7c5411"
version = "3.0.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "7364d5f608f3492a4352ab1d40b3916955dc6aec"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.5"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "4b33e0e081a825dbfaf314decf58fa47e53d6acb"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.4.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore"]
git-tree-sha1 = "d5fb407ec3179063214bc6277712928ba78459e2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.6.4"
weakdeps = ["Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a1f34829d5ac0ef499f6d84428bd6b4c71f02ead"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═c5b86a90-5c8f-11ee-1d60-65cfc67e3948
# ╠═9f16b4c8-358e-46fe-b07d-10e3990df177
# ╠═22d3b3fc-4c88-40f9-aa9a-583a124d2d50
# ╟─00ab89f9-698b-4a55-a5e2-214ae934a6e7
# ╟─b4a156ab-3a55-40ec-9726-856dba595d56
# ╟─9470b6c5-ac11-4682-86f4-a5cc766c5231
# ╟─b337eab8-18ac-4997-9171-6dd16840eda4
# ╟─653ceebf-b2b8-4cc8-90b6-5b0e971930d1
# ╟─2375cd79-75df-4e54-baf7-424b85b75d99
# ╟─e9dfc240-2981-416f-b1fc-190646dbb9da
# ╟─a2c9ffd4-f28c-4862-817a-72c0dfc5e944
# ╟─39758663-9e86-4469-ac37-793652be4b85
# ╟─03d43132-bba7-432b-a891-b88a0a7c985e
# ╟─bf3459a8-15d8-4aaf-b0c4-f0da62ee6aa9
# ╟─13ba3456-7f4f-43b1-b7bc-3b146297a7a7
# ╟─fa19a5eb-a357-43a1-86a7-82ec85125bba
# ╟─2f10e310-04bf-4259-bae9-efba6935fd91
# ╟─b8838d3e-210a-456d-989c-bf356dd933bc
# ╠═42554184-5910-4d99-8dbf-c9bb31e6a60c
# ╟─26544e30-2184-484d-9061-472df17487bd
# ╠═4f5ce53f-a5bb-4d0e-ae27-40ed5a0bae12
# ╟─bc7ef0eb-b365-4d54-a231-8acf44e07ed9
# ╟─91881f4a-fbd2-448c-bdb8-d111ebd66aa9
# ╟─6cf5962b-4142-458c-b12e-1292a103453b
# ╟─efbb5eed-a512-4da8-8738-96fc7f162380
# ╟─fc51506b-63ac-464d-a309-696679757675
# ╟─97df57d2-ae31-4e72-a10b-7588bd604876
# ╟─f6688d6f-54c5-4405-a441-b3c951ab5fe2
# ╟─2e3502ec-5f53-45c0-a855-a799f2f86fa1
# ╟─fcc26a2b-708e-4fd9-af88-f3f5f9f85213
# ╟─27741e2b-b4b6-41ab-9ddb-5e71933fc1da
# ╟─dba5f428-e7e8-4343-b078-52402278f3cb
# ╠═4ac57a1d-7047-4eb8-b4f5-2fe02af80fc3
# ╟─f20400a5-98a9-4ad8-96a6-dabe76c1a1c6
# ╟─42cf6901-07f8-4e8b-9387-cee7fbe37e35
# ╠═2368ed40-6090-4a23-8a63-8d06514cd4dd
# ╟─f38173af-966d-4a64-a170-82a132a7f0d8
# ╟─fd7d22d0-a6b2-4e40-8585-4b6dbcfbc8e6
# ╠═c0913071-ee2e-42c6-944c-23d055ae34cc
# ╟─ed7c27c1-c0ff-4a00-8f7e-76652749b153
# ╟─4aadb25b-5d67-4c13-ba99-f7029793df63
# ╠═425dfdd4-8312-4c40-8644-21995343ec1d
# ╟─a22c24a7-277b-458b-99df-9b97b39d3daa
# ╟─f4863835-2004-4b85-9dd6-ca7f807f41c5
# ╟─444baa8c-1872-419f-aa04-689401a0cddc
# ╟─55e1e8eb-8589-4768-9f05-99b5e813a991
# ╟─97c41a2f-5c4d-4ff3-a8b3-c65fdb41ab4b
# ╠═59fc2616-16f3-405c-8e35-6d8ae6324052
# ╟─81a03dc8-e2a9-4416-9afc-76eeae6ab8a9
# ╟─f16e510b-417c-423f-ba76-277ff2747d9b
# ╠═da13690d-f84e-4391-9c77-fc0b245387e6
# ╟─f7b12509-6d70-469f-b7b9-694cd284841c
# ╟─a49322d8-35bb-4096-bf4f-0e3bfed2d352
# ╠═ccdafc4e-502d-4e40-b462-4680016fcb80
# ╟─23ba33a6-c9b9-4022-b94f-ae0ca6be0525
# ╟─ad85609f-9554-4279-bf02-f77e2756de67
# ╟─79ca68fc-d60c-4ccb-9aab-819565de92a7
# ╟─0738f051-1b85-4329-b8e1-bba68c72f12a
# ╟─7e900874-fd5f-44ac-9b27-6fba66db77e7
# ╟─b20ccc5a-b260-41c4-bb70-a28c224e6a8a
# ╟─3c73309f-cfa9-4eb5-b34d-0d5d79576178
# ╟─d20d13eb-eddb-4744-91bc-5524df4de8f2
# ╟─961a3381-6362-4c62-a07d-4dbcbe563bb2
# ╟─48d5efbd-01a8-4b43-8320-0fe247bbb535
# ╟─1ebcf908-ec65-431c-8d90-76d5b98304d0
# ╟─7ec617f0-e662-41f4-b0e0-0e70e48237df
# ╟─9b822197-5f5e-4222-9349-cbe9eacac13c
# ╟─0215d6ff-3347-4b2d-9980-961b9931e1cb
# ╟─d80e869d-4934-417c-8814-5b16963ac061
# ╟─5d9d095a-b29c-4bbf-9120-ccafe730762a
# ╟─6d050e68-86ee-4b09-9113-01c937f3b0cd
# ╟─ed56c81d-9ba1-41c8-ae55-54a0b6480b35
# ╟─54aa994b-a9fd-4217-8909-847900d1edae
# ╟─5579e8e0-c32e-44a9-860a-b065ab9d7655
# ╟─2df902d6-e245-4657-aceb-fe1ec616ef55
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
