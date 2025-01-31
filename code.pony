use "collections"
use "random"
use "time"

actor Node
  let _id: USize
  let _main: Main tag
  var _neighbors: Array[Node tag]
  let _rand: Rand
  var _rumor_count: USize = 0
  let _max_rumors: USize = 10
  var _s: F64 = 0
  var _w: F64 = 1
  var _previous_ratio: F64 = 0
  var _unchanged_count: USize = 0
  let _algorithm: String
  let _env: Env
  
  new create(id: USize, main: Main tag, algorithm: String, env: Env) =>
    _id = id
    _main = main
    _neighbors = Array[Node tag]
    _rand = Rand
    _algorithm = algorithm
    _env = env

  fun get_id(): USize =>
    _id

  be add_neighbor(neighbor: Node tag) =>
    _neighbors.push(neighbor)

  be initialize_sum(value: F64) =>
    _s = value
    _w = 1

  be start_gossip() =>
      receive_rumor()

  be start_push_sum() =>
    push_sum()

  be receive_rumor() =>
    _rumor_count = _rumor_count + 1
    if _rumor_count <= _max_rumors then
      spread_rumor()
      if _rumor_count == _max_rumors then
        _main.node_converged()
      end
    end

  be push_sum() =>
    let half_s = _s / 2
    let half_w = _w / 2
    _s = half_s
    _w = half_w
    try
      let neighbor = _neighbors(_rand.int[USize](_neighbors.size()) % _neighbors.size())?
      neighbor.receive_sum(half_s, half_w)
    end
    check_push_sum_convergence()

  be receive_sum(s': F64, w': F64) =>
    _s = _s + s'
    _w = _w + w'
    check_push_sum_convergence()

  fun ref check_push_sum_convergence() =>
    let new_ratio = _s / _w
    if (_previous_ratio - new_ratio).abs() < 1e-10 then
      _unchanged_count = _unchanged_count + 1
      if _unchanged_count >= 3 then
        _main.node_converged()
                return
      end
    else
      _unchanged_count = 0
    end
    _previous_ratio = new_ratio
    push_sum()

  fun ref spread_rumor() =>
    try
      let neighbor = _neighbors(_rand.int[USize](_neighbors.size()) % _neighbors.size())?
      neighbor.receive_rumor()
    end


actor Main
  let _env: Env
  var _start_time: U64 = 0
  var _nodes: Array[Node tag] = Array[Node tag]
  var _converged_count: USize = 0
  var _total_nodes: USize = 0
  var _topology_start_time: U64 = 0
  var _protocol_start_time: U64 = 0

  new create(env: Env) =>
    _env = env

    let args = env.args
    if args.size() < 4 then
      _env.out.print("Usage: " + (try args(0)? else "project2" end) + " numNodes topology algorithm")
      return
    end

    try
      let num_nodes = args(1)?.usize()?
            let topology = args(2)?
      let algorithm = args(3)?

      _total_nodes = num_nodes

      // Capture the time before building the topology
      _topology_start_time = Time.nanos()

      // Create nodes
      for i in Range(0, num_nodes) do
        _nodes.push(Node(i, this, algorithm, _env))
      end

      // Build topology
      build_topology(topology)?

      // Capture the time before starting the protocol
      _protocol_start_time = Time.nanos()

      // Print the time it took to build the topology in nanoseconds
      _env.out.print("Topology built in (nanoseconds): " + (_protocol_start_time - _topology_start_time).string())

      // Start algorithm
      start_algorithm(algorithm)?
    else
      _env.out.print("Invalid arguments")
    end

  fun ref build_topology(topology: String) ? =>
    match topology
    | "full" => BuildFullTopology(_nodes)
    | "3D" => Build3DTopology(_nodes)
    | "line" => BuildLineTopology(_nodes)
    | "imp3D" => BuildImperfect3DTopology(_nodes)
    else
      _env.out.print("Invalid topology: " + topology)
            error
    end

  fun ref start_algorithm(algorithm: String) ? =>
    match algorithm
    | "gossip" => 
        _nodes(0)?.start_gossip()
    | "push-sum" =>
      for i in Range(0, _total_nodes) do
        _nodes(i)?.initialize_sum(i.f64())
      end
      _nodes(0)?.start_push_sum()
    else
      _env.out.print("Invalid algorithm: " + algorithm)
      error
    end

  be node_converged() =>
    _converged_count = _converged_count + 1

    // Only print the time when all nodes have converged
    if _converged_count == _total_nodes then
      let protocol_end_time = Time.nanos()
      _env.out.print("Protocol converged in (nanoseconds): " + (protocol_end_time - _protocol_start_time).string())
    end


primitive BuildFullTopology
  fun apply(nodes: Array[Node tag]) =>
    for i in Range(0, nodes.size()) do
      for j in Range(0, nodes.size()) do
        if i != j then
          try
            nodes(i)?.add_neighbor(nodes(j)?)
          end
        end
      end
    end

primitive Build3DTopology
  fun apply(nodes: Array[Node tag]) =>
    let size = nodes.size()
    let dim = (size.f64().pow(1.0/3).ceil()).usize()
    
    for i in Range(0, size) do
      let x = i / (dim * dim)
      let y = (i / dim) % dim
      let z = i % dim
      
      let neighbors = Array[USize]
      
      // Add all possible neighbors
      neighbors.push(((x+1) * dim * dim) + (y * dim) + z)
      if x > 0 then 
        neighbors.push(((x-1) * dim * dim) + (y * dim) + z)
      end
      neighbors.push((x * dim * dim) + ((y+1) * dim) + z)
      if y > 0 then
        neighbors.push((x * dim * dim) + ((y-1) * dim) + z)
              end
      neighbors.push((x * dim * dim) + (y * dim) + (z+1))
      if z > 0 then
        neighbors.push((x * dim * dim) + (y * dim) + (z-1))
      end
      
      for n in neighbors.values() do
        if n < size then
          try
            nodes(i)?.add_neighbor(nodes(n)?)
          end
        end
      end
    end

primitive BuildLineTopology
  fun apply(nodes: Array[Node tag]) =>
    for i in Range(0, nodes.size()) do
      if i > 0 then
        try nodes(i)?.add_neighbor(nodes(i-1)?) end
      end
      if i < (nodes.size() - 1) then
        try nodes(i)?.add_neighbor(nodes(i+1)?) end
      end
    end

primitive BuildImperfect3DTopology
  fun apply(nodes: Array[Node tag]) =>
    Build3DTopology(nodes)
    let rand = Rand
    
    for i in Range(0, nodes.size()) do
      try
        let random_node = nodes(rand.int[USize](nodes.size()) % nodes.size())?
        if random_node isnt nodes(i)? then
          nodes(i)?.add_neighbor(random_node)
        end
      end
    end