# Gossip and Push-Sum Algorithm for Distributed Systems

## Project Description
This project aims to implement and analyze the convergence of Gossip and Push-Sum algorithms for group communication and sum computation respectively. The implementation is built using the actor model in Pony programming language, utilizing its asynchronous features.

## What is Working
- **Algorithm Implementations**: Both Gossip and Push-Sum algorithms are fully implemented and functional.
  - Gossip algorithm successfully propagates rumors until all nodes have received the message a specified number of times.
  - Push-Sum algorithm effectively distributes the sum and computes the ratio, achieving convergence when stability criteria are met.
- **Topology Setup**: The following topologies are supported and successfully built:
  - **Full Network**
  - **3D Grid**
  - **Line**
  - **Imperfect 3D Grid**
- **Performance Metrics**: Convergence times are measured for each combination of algorithm and topology. The results are printed in nanoseconds.

## Largest Networks Handled
- **Full Network**: Successfully tested with up to 500 nodes.
- **3D Grid**: Maximum size tested was 729 nodes (equivalent to a 9x9x9 grid).
- **Line Topology**: Handled networks with up to 1000 nodes.
- **Imperfect 3D Grid**: Tested with up to 512 nodes, providing efficient convergence compared to the standard 3D grid.

## Running the Project
To run the project, use the following command-line structure:
```bash
project2 numNodes topology algorithm
```
- `numNodes` - Number of nodes in the network.
- `topology` - One of `full`, `3D`, `line`, `imp3D`.
- `algorithm` - Either `gossip` or `push-sum`.

### Example
```bash
project2 100 line gossip
```
This command runs the Gossip algorithm with 100 nodes arranged in a line topology.

## Findings Summary
- **Gossip Algorithm**: 
  - The convergence time varied significantly based on the topology.
  - The **Full Network** showed unpredictability due to the overhead of maintaining connectivity.
  - **3D Grid** and **Imperfect 3D Grid** had more predictable convergence, with imperfections providing beneficial shortcuts.
- **Push-Sum Algorithm**: 
  - The **Full Network** topology also experienced challenges with unpredictable convergence.
  - The **Line Topology** exhibited the slowest convergence, while **Imperfect 3D Grid** showed improved performance compared to the regular 3D grid.

## Future Improvements
- Experiment with additional failure models, such as nodes or connections failing randomly, to further evaluate algorithm robustness.
- Consider more complex topologies or hybrid approaches to further optimize convergence times.

## Contact
For questions or further information, please contact:
- Abhinav Reddy Pannala: pannala.abhinav@example.com
