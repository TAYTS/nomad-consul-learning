# Local Setup for Nomad Consul

1. Install Vagrant, VirtualBox and Nomad on local machine
2. Setup Nomad cluster
   ```bash
   # Create the VM
   vagrant up
   # Access the VM terminal
   vagrant ssh
   # On the VM terminal
   sudo nomad agent -dev-connect -bind 0.0.0.0 -log-level INFO
   ```
3. Deploy Counting Dashboard
   ```bash
   nomad job run service-mesh.nomad
   ```
4. Access Nomad UI on host machine at `http://localhost:4646/ui`
5. Access Counting dashboard at `http://localhost:9002`
